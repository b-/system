#!/usr/bin/env bash
set -eu

###
# settings

# set cachix user
CACHIX_USER="bri"

DEFAULT_ARCH=x86_64
DEFAULT_TARGET=server
DEFAULT_FORMAT=raw-efi
DEFAULT_OS=linux

# too lazy to write something better rn
_THISFILE(){
  printf %s '/home/bri/system/build.sh'
}

# server to scp artifacts to
UPLOAD_SERVER=ci-upload.ibeep.com
UPLOAD_USER=ci-upload
IMAGE_BUILD_FLAGS+=( -v --print-out-paths --show-trace --accept-flake-config )
# hashtable of destdirs
declare -A DESTDIRS=(
  [proxmox]="dump/"
  [raw-efi]="images/"
  [iso]="template/iso/"
)

DEFAULT_TARGETS=(
  "server"
  "bri"
)
TARGETS="${TARGETS-${DEFAULT_TARGETS}}"
DEFAULT_FORMATS=(
  "proxmox"
  "raw-efi"
  "iso"
)
FORMATS="${FORMATS-${DEFAULT_FORMATS}}"
declare -A EXTENSIONS=(
  [raw-efi]="img"
  [proxmox]="vma.zst"
  [iso]="iso"
)

# filename prefixes (only proxmox needs this)
_PREFIX(){
  case "${FORMAT}" in
    "proxmox")
      local PREFIX="vzdump-qemu-"
    ;;
    *)
      local PREFIX="" # null
  esac
  printf '%s' "${PREFIX}"
}

_NAME(){
    printf 'build_image_%s@%s-%s_%s' \
      "$(_TARGET)" \
      "$(_ARCH)" \
      "$(_OS)" \
      "$(_FORMAT)" \
    ;
}

###
# Helper string functions

_TARGET(){
  printf '%s' "${TARGET-${DEFAULT_TARGET}}"
}

_ARCH(){
  printf '%s' "${ARCH-${DEFAULT_ARCH}}"
}

_OS(){
  printf '%s' "${OS-${DEFAULT_OS}}"
}

_FORMAT(){
  printf '%s' "${FORMAT-${DEFAULT_FORMAT}}"
}

_println(){
  printf "%s\n" "${*}"
}

_die(){
  set +x
  exit_code=254
  if [[ "${1}" =~ ^[0-9]+$ ]] ; then
    exit_code="${1}"
    shift
  fi
  exit "${exit_code}"
}

_LIST(){
  KEEP_FUNCS='/(){/!d' # bug in bash lsp syntax highlighting
  FMT_FUNCS='s/(){//'
  LIST="$(<"$(_THISFILE)" sed -e '/^_/d' -e '/^ /d' -e "${KEEP_FUNCS}" -e "${FMT_FUNCS}")"
  _println "Targets:"
  _println "${LIST}" | sed -e's/^/  /'
}

INSTALL_CACHIX(){ # INSTALL_CACHIX
    nix profile install github:nixos/nixpkgs/nixpkgs-unstable#cachix --impure && cachix use $CACHIX_USER
}

WITH_CACHIX(){ # Run a command with Cachix
  cachix watch-exec "${CACHIX_USER}" -- "${@}"
}

BUILD_IMAGE(){ # Build image
    mkdir -p build
    ARCH="$(_ARCH)"
    BUILD_FILE="$(nix build ".#nixosConfigurations.$(_TARGET)@${ARCH//arm/aarch}-$(_OS).config.formats.$(_FORMAT)" "${IMAGE_BUILD_FLAGS[@]}")"
    BASE_FILE="$(basename "${BUILD_FILE}")"
    CUT_FILE="$(cut -d- -f2- <<<"${BASE_FILE}")"
    HASH=$(cut -b-5 <<<"${BASE_FILE}")
    OUTNAME="build/$(_PREFIX)${HASH}-$(date -I)_${TARGET}_${CUT_FILE}"
    export OUTNAME
    #cp --sparse "${BUILD_FILE}" "${OUTNAME}"
    ln -fvs "${BUILD_FILE}" "${OUTNAME}"
    printf %s "${OUTNAME}"
}

SAVE_SSH_KEY(){
    <<< "${UPLOAD_SSH_KEY_BASE64// /$'\n'}" base64 -d > /tmp/ci-upload.key
}

UPLOAD_ARTIFACTS(){
    SSH_OPTIONS=(
        "-i/tmp/ci-upload.key"
        "-oStrictHostKeyChecking=no"
        "-oport=222"
        "-oidentitiesonly=true"
        "-oPasswordAuthentication=no"
        "-oUser=${UPLOAD_USER}"
        )

    # ssh refuses to use a key with open permissions
    chmod 600 /tmp/ci-upload.key
    chmod -R 755 build

    # TODO: document what these flags do
    rsync \
      -auvLzt \
      --chmod=D2775,F664 -p \
      -e "ssh ${SSH_OPTIONS[*]}" \
      --info=progress2 \
      "${OUTNAME}" \
      "${UPLOAD_USER}@${UPLOAD_SERVER}:${DESTDIRS[$(_FORMAT)]}"
}

###
# META TARGETS
CLEAN(){
  rm -fR build result
}
# tasks to build an image
BUILD_IMAGE_TASKS(){
  #INSTALL_CACHIX
  #WITH_CACHIX BUILD_IMAGE
  BUILD_IMAGE
}

# tasks to run for upload
UPLOAD_TASKS(){
  SAVE_SSH_KEY
  UPLOAD_ARTIFACTS
}

# build and upload an image
BUILD_AND_UPLOAD(){
  INVOCATION_NAME="$(_TARGET).$(_FORMAT).$(date -I).$(date +"%H-%M")"
  time BUILD_IMAGE_TASKS 2>&1 | tee "build_${INVOCATION_NAME}.log"
  time UPLOAD_TASKS 2>&1 | tee "upload_${INVOCATION_NAME}.log"
}

BUILD_IMAGES(){
for FORMAT in "${FORMATS[@]}"; do
  for TARGET in "${TARGETS[@]}"; do
    echo '{'
    echo '"TARGET": "'"$(_TARGET)"'",'
    echo '"FORMAT": "'"$(_FORMAT)"'"'
    echo '}'
    CLEAN
    BUILD_AND_UPLOAD
  done
done
}

CI(){
    INVOCATION_NAME="build.$(date -I).$(date +"%H-%M")"
    BUILD_IMAGES 2>&1 | tee "${INVOCATION_NAME}.log"
}
_main(){
  if [[ -z "${1-}" ]] ; then
    _LIST
    _die ''
  fi
"${@}"
}

DAEMON(){
    INVOCATION_NAME="build.$(date -I).$(date +"%H-%M")"
    DIR="$(dirname "$(_THISFILE)")"
    local DIR
    cd "${DIR}"
    nix run -- nixpkgs#screen -dmS "${INVOCATION_NAME}" "$(_THISFILE)" -L -Logfile "${INVOCATION_NAME}.log" "${@}"
    echo "${INVOCATION_NAME}"
    echo "  tail -f ${INVOCATION_NAME}.log"
}

_main "${@}"
