#!/usr/bin/env bash
set -eux

# set cachix user
CACHIX_USER="bri"

# only x86_64 for now
ARCH=x86_64

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
declare -A PREFIXES=(
  [proxmox]=vzdump-qemu-
)

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
    BUILD_FILE="$(nix build ".#nixosConfigurations.${TARGET}@${ARCH//arm/aarch}-${OS}.config.formats.${FORMAT}" --print-out-paths --show-trace --accept-flake-config)"
    cp "${BUILD_FILE}" "build/"
}

LIST_RENAME_BUILD_ARTIFACTS(){
    set -x
    find build
    OUTFILE="${PREFIXES[${FORMAT}]}${NAME}.${EXTENSIONS[${FORMAT}]}"
    for i in build/*."${EXT}" ; do
        mv "$i" "build/${OUTFILE}"
    done
}

SAVE_SSH_KEY(){
    printenv UPLOAD_SSH_KEY > /tmp/ci-upload.key
}

UPLOAD_ARTIFACTS(){
    set -x
    chmod 600 /tmp/ci-upload.key
    chmod -R 755 build
    scp -C -i /tmp/ci-upload.key  -oStrictHostKeyChecking=no -oport=222 -oidentitiesonly=true -oPasswordAuthentication=no -oUser="${UPLOAD_USER}" build/* "${UPLOAD_SERVER}":"${DESTDIRS[${FORMAT}]}"
}

###
# META TARGETS
###

CLEAN(){
  #rm -fR "${ARTIFACTS[@]}"
  true #don't clean for now
}
# tasks to build an image
BUILD_IMAGE_TASKS(){
  NAME="build_image_${TARGET}@${ARCH}-${OS}_${FORMAT}"
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
    echo "TARGET: ${TARGET}"
    echo "FORMAT: ${FORMAT}"
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
