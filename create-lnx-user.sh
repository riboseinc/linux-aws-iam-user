#!/bin/bash
#
# create-lnx-user.sh by <ebo@>
#
# Run this script to create a local Linux user account driven by AWS IAM
#
# Usage:
# ./create-lnx-user <IAM name>
#
# Prerequisites:
# 1) Valid AWS credentials
# 2) Installed awscli

set -uo pipefail

readonly __progname="$(basename "$0")"

readonly err_invalid_arg_function="invalid number of arguments for function"

errx() {
	echo -e "${__progname}: $*" >&2

	exit 1
}

warn() {
	echo -e "${__progname}: $*" >&2
}

usage() {
	echo -e "${__progname}: <username> [group]" >&2

	exit 1
}

get_ssh_key() {
	[[ "$#" -ne 1 ]] && \
		errx "${FUNCNAME[0]}(): ${err_invalid_arg_function}"

	local user="$1"

	local sshpubkeyid
	sshpubkeyid=$(aws iam list-ssh-public-keys \
		--user-name "${user}" \
		--output1 text | \
		awk '{ print $2 }')

	if [ "$?" -ne 0 ]; then
		warn "${FUNCNAME[0]}(): failed to obtain the ssh public key for IAM user '${user}'"

		return 1
	fi

	local sshpubkey
	sshpubkey=$(aws iam get-ssh-public-key \
		--user-name "${user}" \
		--ssh-public-key-id "${sshpubkeyid}" \
		--encoding SSH --output json | \
		awk '/SSHPublicKeyBody/ { print $2, $3 }' | \
		cut -d '"' -f 2)

	if [ $? -ne 0 ]; then
		warn "${FUNCNAME[0]}(): failed to obtain the ssh public key with id '${sshpubkeyid}' for IAM user '${user}'"

		return 1
	fi

	# TODO: write some verification tests for the ssh public key

	echo "${sshpubkey}"

	return 0
}

create_user_with_pubkey() {
	[[ "$#" -ne 2 ]] && \
		errx "${FUNCNAME[0]}(): ${err_invalid_arg_function}"

	local user="$1"
	local sshpubkey="$2"	

	local homedir="/home/${user}"
	local sshdir="${homedir}/.ssh"

	mkdir -p "${sshdir}" || \
		errx "${FUNCNAME[0]}(): failed to mkdir '${sshdir}'"

	useradd -m -U --home-dir "${homedir}" "${user}" || \
		errx "${FUNCNAME[0]}(): useradd '${user}' failed"

	echo "${sshpubkey}" > "${sshdir}/authorized_keys"
	chmod -R 500 "${sshdir}"
	chown -R "${user}":"${user}" "${homedir}"

	return 0
}

main() {
	[[ "$#" -ne 1 ]] && \
		usage

	local user="$1"

	local sshpubkey
	sshpubkey="$(get_ssh_key "${user}")"
	[ $? -ne 0 ] && \
		return 1

	create_user_with_pubkey "${user}" "${sshpubkey}"

	return 0
}

main "$@"

exit $?
