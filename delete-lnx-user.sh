#!/bin/bash
#
# delete-lnx-user.sh by <ebo@>
#
# Run this script to delete a local Linux user account
#
# Usage:
# ./delete-lnx-user.sh <username>

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
	echo -e "${__progname} <username> [group]" >&2

	exit 1
}

delete_user() {
        [[ "$#" -ne 1 ]] && \
                errx "${FUNCNAME[0]}(): ${err_invalid_arg_function}"

	local user="$1"

	warn "${FUNCNAME[0]}(): locking down user account '${user}'"
	chage -E 0 "${user}"

	# now kill all running processes of the to be deleted user
	for pid in $(ps -o pid= -u ${user} 2>/dev/null); do
		warn "${FUNCNAME[0]}(): killing pid '${pid}' from '${user}'"
		kill -9 "${pid}"
	done

	warn "${FUNCNAME[0]}(): deleting user account '${user}'"
	userdel -f -r "${user}"
	getent group "${user}" && \
		groupdel "${user}"

	return 0
}

main() {
	[[ "$#" -ne 1 ]] && \
		usage

	local user="$1"

	delete_user "${user}"

	return 0
}

main "$@"

exit $?
