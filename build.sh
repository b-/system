#!/usr/bin/env bash
CACHIX_USER="bri"
ARCH=x86_64

ENUMERATE_TARGETS(){
#build_image_task:
  #matrix:
    # - <<: *ARM_CONTAINER_TEMPLATE
    #   env:
    #     ARCH: arm64
    #     USER: root

    # Proxmox server image
    #- <<: *LINUX_CONTAINER_TEMPLATE
    PROXMOX_TARGET(){
        :
    }
      env:
        FORMAT: proxmox
        DESTDIR: dump
        EXT: vma.zst
        TARGET: server
    # raw server image
    - <<: *LINUX_CONTAINER_TEMPLATE
      env:
        ARCH: x86_64
        FORMAT: raw-efi
        DESTDIR: images
        EXT: img
        TARGET: server
    # iso server image
    - <<: *LINUX_CONTAINER_TEMPLATE
      env:
        ARCH: x86_64
        FORMAT: iso
        DESTDIR: template/iso
        EXT: iso
        TARGET: server
    # bri proxmox image
    - <<: *LINUX_CONTAINER_TEMPLATE
      env:
        ARCH: x86_64
        FORMAT: proxmox
        DESTDIR: dump
        EXT: vma.zst
        TARGET: bri
    # server lxc image (broken)
    # - <<: *LINUX_CONTAINER_TEMPLATE
    #   env:
    #     ARCH: x86_64
    #     FORMAT: proxmox-lxc
    #     DESTDIR: template/cache
    #     EXT: tar.xz
    #     TARGET: server

    # bri raw image
    - <<: *LINUX_CONTAINER_TEMPLATE
      env:
        ARCH: x86_64
        FORMAT: raw-efi
        EXT: img
        DESTDIR: images
        TARGET: bri
    # bri iso image
    - <<: *LINUX_CONTAINER_TEMPLATE
      env:
        ARCH: x86_64
        FORMAT: iso
        EXT: iso
        TARGET: bri
        DESTDIR: template/iso
}

INSTALL_CACHIX(){
    nix profile install github:nixos/nixpkgs/nixpkgs-unstable#cachix --impure && cachix use $CACHIX_USER
}
BUILD_IMAGE(){
    mkdir -p build
    cp -LR "$(nix build ".#nixosConfigurations.${TARGET}@${ARCH//arm/aarch}-${CIRRUS_OS}.config.formats.${FORMAT}" --print-out-paths --show-trace --accept-flake-config)" build/
}
LIST_RENAME_BUILD_ARTIFACTS(){
    set -x
    find build
    if [[ "${EXT}" == "vma.zst" ]] ; then
        for i in build/*.${EXT} ; do
            mv "$i" build/"vzdump-qemu-${TARGET}_$(basename ${i})"
        done
    else
        for i in build/*.${EXT} ; do
            mv "$i" build/"${TARGET}_$(basename ${i})"
        done
    fi
}

SAVE_SSH_KEY(){
    printenv UPLOAD_SSH_KEY > /tmp/ci-upload.key
}

UPLOAD_ARTIFACTS(){
    set -x
    chmod 600 /tmp/ci-upload.key
    chmod -R 755 build
    scp -C -i /tmp/ci-upload.key  -oStrictHostKeyChecking=no -oport=222 -oidentitiesonly=true -oPasswordAuthentication=no build/* ci-upload@home.ibeep.com:${DESTDIR}
}


BUILD_IMAGE_TARGET(){
#build_image_template: &BUILD_IMAGE_TEMPLATE
    NAME="build_image_${TARGET}@${ARCH}-${OS}_${FORMAT}"
    INSTALL_CACHIX
    BUILD_IMAGE
    LIST_RENAME_BUILD_ARTIFACTS
    SAVE_SSH_KEY
    UPLOAD_ARTIFACTS
}