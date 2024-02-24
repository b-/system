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
_THISFILE() {
	printf %s/%s "${HOME}/system" 'build.sh'
}

# server to scp artifacts to
UPLOAD_SERVER=ci-upload.ibeep.com
UPLOAD_USER=ci-upload
# hashtable of destdirs
declare -A DESTDIRS=(
	["proxmox"]="dump/"
	["proxmox-lxc"]="template/cache/"
	["raw-efi"]="images/"
	["iso"]="template/iso/"
)

DEFAULT_TARGETS=(
	"server"
	"bri"
)
DEFAULT_FORMATS=(
	"proxmox"
	"proxmox-lxc"
	"raw-efi"
	# "iso"
)

# DEFAULT_EXCLUDES contains pairs of "TARGET.FORMAT" to exclude from builds
DEFAULT_EXCLUDES=(
	"bri.proxmox-lxc"
	"bri.proxmox"
	"server.raw-efi"
)
# unused
# shellcheck disable=SC2034
declare -A EXTENSIONS=(
	["raw-efi"]="img"
	["proxmox"]="vma.zst"
	["iso"]="iso"
)

# filename prefixes (only proxmox needs this)
_PREFIX() {
	case "${FORMAT}" in
	"proxmox")
		local PREFIX="vzdump-qemu-"
		;;
	*)
		local PREFIX="" # null
		;;
	esac
	printf '%s' "${PREFIX}"
}

###
# Helper functions

# _STDERR (command_or_function)
# Runs (command_or_function) and redirects 1>&2
_STDERR() {
	"${@}" 1>&2
}

# DATE-TIME returns `(date -I)-(date +%H-%M)`
DATE-TIME() {
	printf %s "${DATE_TIME-$(date -I)-$(date +"%H-%M")}"
}

# _NAME outputs a formatted filename for (_TARGET) (_ARCH) (_OS) (_FORMAT)
_NAME() {
	printf 'build_image_%s@%s-%s_%s' \
		"$(_TARGET)" \
		"$(_ARCH)" \
		"$(_OS)" \
		"$(_FORMAT)" \
		;
}

# _TARGET helper function to output the TARGET to build.
# Returns either $TARGET or $DEFAULT_TARGET
_TARGET() {
	printf '%s' "${TARGET-${DEFAULT_TARGET}}"
}

# _ARCH helper function to output the ARCH to build.
# Returns either $ARCH or $DEFAULT_ARCH
_ARCH() {
	printf '%s' "${ARCH-${DEFAULT_ARCH}}"
}

# _OS helper function to output the OS to build.
# Returns either $OS or $DEFAULT_OS
_OS() {
	printf '%s' "${OS-${DEFAULT_OS}}"
}

# _FORMAT helper function to output the FORMAT to build.
# Returns either $FORMAT or $DEFAULT_format
_FORMAT() {
	printf '%s' "${FORMAT-${DEFAULT_FORMAT}}"
}

# Usage: _println <message>
_println() {
	printf "%s\n" "${*}"
}

# Usage: _die [exit code] <message>
_die() {
	set +x
	exit_code=254
	if [[ ${1} =~ ^[0-9]+$ ]]; then
		exit_code="${1}"
		shift
	fi
	exit "${exit_code}"
}

# LISTs the main functions in this script
_LIST() {
	KEEP_FUNCS='/() {/!d' # bug in bash lsp syntax highlighting
	FMT_FUNCS='s/() {//'
	LIST="$(sed <"$(_THISFILE)" -e '/^_/d' -e '/^ /d' -e "${KEEP_FUNCS}" -e "${FMT_FUNCS}")"
	_println "Targets:"
	_println "${LIST}" | sed -e's/^/  /'
}

# Installs cachix
INSTALL_CACHIX() { # INSTALL_CACHIX Installs cachix
	nix profile install github:nixos/nixpkgs/nixpkgs-unstable#cachix --impure && cachix use $CACHIX_USER
}

WITH_CACHIX() { # Run a command with `cachix
	DEFAULT_CACHIX_USER=bri
	cachix watch-exec "${CACHIX_USER-${DEFAULT_CACHIX_USER}}" -- "${@}"
}

# BUILD_IMAGE
# Builds an image $TARGET@$ARCH-linux.$FORMAT
# Usage: BUILD_IMAGE
# Returns the built filename to stdout and redirects
# all other output to stderr.
BUILD_IMAGE() { # Build image $TARGET@$ARCH-linux.$FORMAT
	IMAGE_BUILD_FLAGS=(-v --show-trace --accept-flake-config)
	local NIX_BUILD_TARGET BUILT_FILE ARCH BASE_FILE HASH CUT_FILE
	mkdir -p build
	ARCH="$(_ARCH)"
	# NIX_BUILD_TARGET e.g., `.#nixosConfigurations.server@x86_64-linux.config.formats.raw-efi`
	NIX_BUILD_TARGET="$(
		printf .#nixosConfigurations.%s@%s-%s.config.formats.%s \
			"$(_TARGET)" \
			"${ARCH//arm/aarch}" \
			"$(_OS)" \
			"$(_FORMAT)" \
			;
	)"
	# $BUILT_FILE is the path to the build artifact inside /nix store.
	# `nix build --print-out-paths` sends all build output to stderr and outputs only the built path(s) to stdout
	if [[ -n ${DRY_RUN-} ]]; then
		for _ in {1..10}; do
			sleep 0.05s
			_STDERR _println "Blah blah blah sample build output..."
		done
		BUILT_FILE="/tmp/x9s4kb8sip304fbggdbf9ibjqmdz9c6l-proxmox-nixos-24.05.20240211.f9d39fb.vma.zst"
		touch "${BUILT_FILE}"
	else
		BUILT_FILE="$(nix build --print-out-paths "${NIX_BUILD_TARGET}" "${IMAGE_BUILD_FLAGS[@]}")"
	fi

	# BASE_FILE basename of $BUILT_FILE
	BASE_FILE="$(basename "${BUILT_FILE}")"
	# CUT_FILE the rest of $BASE_FILE after the full $HASH
	CUT_FILE="$(cut -d- -f2- <<<"${BASE_FILE}")"
	# OUTNAME the final filename of our linked build artifact
	OUTNAME="build/$(_PREFIX)-$(DATE-TIME)_${TARGET}_${CUT_FILE}"
	export OUTNAME
	_STDERR ln -fvs "${BUILT_FILE}" "${OUTNAME}"
	# return "${OUTNAME}"
	printf %s "${OUTNAME}"
}

# SAVE_SSH_KEY
# Usage: SAVE_SSH_KEY [var]
# Saves the (base64-encoded) SSH private key from .env variable $UPLOAD_SSH_KEY_BASE64
SAVE_SSH_KEY() {
	base64 <<<"${UPLOAD_SSH_KEY_BASE64// /$'\n'}" -d >/tmp/ci-upload.key
	# ssh refuses to use a key with open permissions
	chmod 600 /tmp/ci-upload.key
}

# UPLOAD_ARTIFACT
# Usage: UPLOAD_ARTIFACT <file> [<file> [<file>]]...
# Saves SSH key and uploads <file>s via rsync
UPLOAD_ARTIFACT() {
	SSH_OPTIONS=(
		"-oIdentityFile=/tmp/ci-upload.key" # private key
		"-oStrictHostKeyChecking=no"        # Disable prompting on unknown host key TODO: add host public key instead
		"-oPort=222"
		"-oIdentitiesOnly=true"       # Don't use any other private keys.
		"-oPasswordAuthentication=no" # Don't attempt password authentication.
		"-oUser=${UPLOAD_USER}"       # Probably not necessary unless you use a bastion host
	)
	RSYNC_OPTIONS=(
		#"-t" # timestamps
		"-u" # update (skip newer files)
		#"-v" # verbose
		"-L"                         # traverse symlinks
		"-z"                         # compress data during transfer
		"--chmod=D2775,F664" "-p"    # file modes
		"-e" "ssh ${SSH_OPTIONS[*]}" # ssh flags
		"--info=progress2"           # show progress
	)
	[[ -n ${DRY_RUN-} ]] && RSYNC_OPTIONS+=("--dry-run")
	rsync \
		"${RSYNC_OPTIONS[@]}" \
		"${@}" \
		"${UPLOAD_USER}@${UPLOAD_SERVER}:${DESTDIRS["$(_FORMAT)"]}"
}

###
# META TARGETS

# CLEAN cleans built artifacts
# Usage: CLEAN
CLEAN() {
	set -x
	rm -fR build result
}
# BUILD_IMAGE_TASKS
# Usage: BUILD_IMAGE_TASKS
# Builds an image for $FORMAT and $TARGET
# runs (BUILD_IMAGE)
BUILD_IMAGE_TASKS() {
	#INSTALL_CACHIX
	#WITH_CACHIX BUILD_IMAGE
	BUILD_IMAGE
}

# UPLOAD_TASKS
# Usage: UPLOAD_TASKS
# runs (SAVE_SSH_KEY) and (UPLOAD_ARTIFACT)
UPLOAD_TASKS() {
	SAVE_SSH_KEY
	UPLOAD_ARTIFACT "${@}"
}

# BUILD_AND_UPLOAD
# Usage: BUILD_AND_UPLOAD
# runs (BUILD_IMAGE_TASKS) while saving output to "build_${INVOCATION_NAME}.log".
BUILD_AND_UPLOAD() {
	INVOCATION_NAME="${BUILD_NAME-$(_TARGET).$(_FORMAT).$(DATE-TIME)}"

	# Build image, then set BUILT_ARTIFACT to built image filename
	BUILT_ARTIFACT="$(
		# and tee build log (from stderr) to build_${INVOCATION_NAME}.log
		BUILD_IMAGE_TASKS
	)" 2> >(tee "build_${INVOCATION_NAME}.log")
	# upload built image
	UPLOAD_TASKS "${BUILT_ARTIFACT}" 2>&1 | tee "upload_${INVOCATION_NAME}.log"
}

# BUILD_MATRIX
# Runs (CLEAN) and (BUILD_AND_UPLOAD) for each combination of the arrays ${TARGETS[@]} and ${FORMATS[@]}.
# If ${TARGETS[@]} or ${FORMATS[@]} are unset, the ${DEFAULT_TARGETS[@]} and ${DEFAULT_FORMATS[@]} arrays are used instead.
BUILD_MATRIX() {
	TARGETS=("${TARGETS[@]-${DEFAULT_TARGETS[@]}}")
	FORMATS=("${FORMATS[@]-${DEFAULT_FORMATS[@]}}")
	EXCLUDES=("${EXCLUDES[@]-${DEFAULT_EXCLUDES[@]}}")

	for FORMAT in "${FORMATS[@]}"; do
		for TARGET in "${TARGETS[@]}"; do
			EXCLUDING=0
			for EXCLUDE in "${EXCLUDES[@]}"; do
				if [[ "${TARGET}.${FORMAT}" == "${EXCLUDE}" ]]; then
					EXCLUDING=1
					break
				fi
			done
			if [[ ${EXCLUDING} -eq 0 ]]; then
				# not excluding
				if [[ -n ${NOCLEAN-} ]]; then
					CLEAN
				fi
				BUILD_NAME="$(_TARGET).$(_FORMAT).$(DATE-TIME)"
				export BUILD_NAME
				_println ""
				_println "  *** Starting build ${BUILD_NAME} ***"
				time BUILD_AND_UPLOAD
				_println "  *** Finished build ${BUILD_NAME} ***"
			else
				_println "  *** Skipping excluded TARGET.FORMAT ${TARGET}.${FORMAT} ***"
			fi
		done
	done
	_println "  *** DONE! ***"
}

CI_BUILD() {
	export DATE_TIME
	DATE_TIME="$(DATE-TIME)" # save the DATE-TIME so we can upload it
	time BUILD_MATRIX 2>&1 | tee "ci-build.${DATE_TIME}.log"
	UPLOAD_ARTIFACT "ci-build.${DATE_TIME}.log"
}

_main() {
	if [[ -z ${1-} ]]; then
		_LIST
		_die ''
	fi
	"${@}"
}

_main "${@}"
