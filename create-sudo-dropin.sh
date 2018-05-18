#!/bin/bash
#
# create-sudo-dropin.sh by <ebo@>
#
# Run this script to create a sudoers drop-in file for NOPASSWD
#
# Usage:
# ./create-sudo-dropin.sh <group>

set -uo pipefail

readonly __progname="$(basename "$0")"

readonly err_invalid_arg_function="invalid number of arguments for function"

errx() {
	echo -e "${__progname} $*" >&2

	exit 1
}

warn() {
	echo -e "${__progname} $*" >&2
}

usage() {
	echo -e "${__progname} <group>" >&2

	exit 1
}

# add a sudo drop-in file for a group
create_sudo_whitelist() {
	[[ "$#" -ne 1 ]] && \
		errx "${FUNCNAME[0]}(): ${err_invalid_arg_function}"

	local group="$1"

	local sudoersd="/etc/sudoers.d"
	[ ! -d "${sudoersd}" ] || \
		errx "directory '${sudoersd}' does not exist"

	local sudoers="/etc/sudoers"
	[ ! -f "${sudoers}" ] && \
		errx "file '${sudoers}' does not exist"

	local includeline="#includedir ${sudoersd}"
	grep -qw "${includeline}" "${sudoers}" || \
		errx "line '${includeline}' is not present in '${sudoers}'"

	local sudodropin="${sudoersd}/${group}-nopasswd"
	if [ ! -f "${sudodropin}" ]; then
		install -m 0440 -o root -g root "/dev/null" "${sudodropin}" || \
			errx "install '${sudodropin}' failed"
	fi

	grep -qw "^%${group}" "${sudodropin}" && \
		return 0

	local nopasswd="%${group} ALL=(ALL) NOPASSWD: ALL"
	echo "${nopasswd}" > "${sudodropin}"
}	

main() {
	[[ "$#" -ne 1 ]] && \
		usage

	local group="$1"

	create_sudo_whitelist "${group}"

	return 0
}

main "$@"

exit $?
