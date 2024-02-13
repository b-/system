#!/usr/bin/env bash
set -eux

# set cachix user
CACHIX_USER="bri"

DEFAULT_ARCH=x86_64

# only linux for now
OS=linux

# server to scp artifacts to
UPLOAD_SERVER=ci-upload.ibeep.com
UPLOAD_USER=ci-upload

# hashtable of destdirs
declare -A DESTDIRS=(
  [proxmox]="dump"
  [raw-efi]="images"
  [iso]="template/iso"
)

TARGETS=(
  "server"
  "bri"
)
FORMATS=(
  "proxmox"
  "raw-efi"
  "iso"
)
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

die(){
  exit_code=254
  if [[ "${1}" =~ ^[0-9]+$ ]] ; then
    exit_code="${1}"
    shift
  fi
  _println "${*}"
  exit "${exit_code}"
}


INSTALL_CACHIX(){
    nix profile install github:nixos/nixpkgs/nixpkgs-unstable#cachix --impure && cachix use $CACHIX_USER
}

WITH_CACHIX(){
  cachix watch-exec "${CACHIX_USER}" -- "${@}"
}

BUILD_IMAGE(){
    mkdir -p build
    BUILD_FILE="$(nix build ".#nixosConfigurations.$(TARGET)@${ARCH//arm/aarch}-${OS}.config.formats.$(_FORMAT)" --print-out-paths --show-trace --accept-flake-config)"
    cp "${BUILD_FILE}" "build/"
}

LIST_RENAME_BUILD_ARTIFACTS(){
    set -x
    find build
    printf -v OUTFILE\
      '%s%s.%s.%s"' \
      "$(_PREFIX)" \
      "$(NAME)" \
      "$(date -I)" \
      "${EXTENSIONS[$(_FORMAT)]}"

    for i in build/*."${EXTENSIONS[$(_FORMAT)]}" ; do
        mv "$i" "build/${OUTFILE}"
    done
}

SAVE_SSH_KEY(){
    <<< "${UPLOAD_SSH_KEY_BASE64// /$'\n'}" base64 -d > /tmp/ci-upload.key
}

UPLOAD_ARTIFACTS(){
    set -x
    chmod 600 /tmp/ci-upload.key
    chmod -R 755 build
    scp -C -i /tmp/ci-upload.key  -oStrictHostKeyChecking=no -oport=222 -oidentitiesonly=true -oPasswordAuthentication=no -oUser="${UPLOAD_USER}" build/*."${EXTENSIONS[$(_FORMAT)]}" "${UPLOAD_SERVER}":"${DESTDIRS[$(_FORMAT)]}"
}

###
# META TARGETS
###

CLEAN(){
  rm -fR build result
}
# tasks to build an image
BUILD_IMAGE_TASKS(){
  #INSTALL_CACHIX
  #WITH_CACHIX BUILD_IMAGE
  BUILD_IMAGE
  LIST_RENAME_BUILD_ARTIFACTS
}

# tasks to run for upload
UPLOAD_TASKS(){
  SAVE_SSH_KEY
  UPLOAD_ARTIFACTS
}

# build and upload an image
BUILD_AND_UPLOAD(){
  BUILD_IMAGE_TASKS
  UPLOAD_TASKS
}

BUILD_IMAGES(){
for FORMAT in "${FORMATS[@]}"; do
  for TARGET in "${TARGETS[@]}"; do
    echo '{'
    echo '"TARGET": '"$(TARGET)"
    echo '"FORMAT": '"$(_FORMAT)"
    echo '}'
    CLEAN
    BUILD_AND_UPLOAD
  done
done
}

CI(){
  BUILD_IMAGES
}

main(){
"${@}"
}

main "${@}"
