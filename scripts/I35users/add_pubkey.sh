#!/bin/bash
set -e
if [ $# != 4 ]; then
    echo usage:
    echo "  $0 HOME_DIR UID GID \"PUBKEY\""
    exit 1
fi

home=$1
uid=$2
gid=$3
pubkey=$4

keys=${home}/.ssh/authorized_keys

if test -z "${pubkey}"; then exit 0; fi
# if authorized_keys exists, we do not modify it
if test -e "${keys}" ; then
    exit 0;
fi   # && grep "${pubkey}" "${keys}"

if ! test -d ${home}/.ssh ; then
    mkdir -p ${home}/.ssh -m 0700
    chown ${uid}:${gid} ${home}/.ssh
fi

echo "${pubkey}" >> "${keys}"
chown ${uid}:${gid} "${keys}"

