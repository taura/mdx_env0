#!/bin/bash
set -e
if [ $# != 2 ]; then
    echo usage:
    echo "  $0 HOME_DIR \"PUBKEY\""
    exit 1
fi

home=$1
pubkey=$2

keys=${home}/.ssh/authorized_keys

if test -z "${pubkey}"; then exit 0; fi
mkdir -p ${home}/.ssh -m 0700
if test -e "${keys}" && grep "${pubkey}" "${keys}"; then exit 0; fi
echo "${pubkey}" >> "${keys}"

