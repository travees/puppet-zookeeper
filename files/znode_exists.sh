#!/bin/bash

function usage () {
  echo "usage: $0 znode_path" >&2
  exit 1
}

_znode="$1"

[ -z $_znode ] && usage

[[ $(echo "stat $_znode" | zkCli.sh 2>&1 >/dev/null) != \
   *'Node does not exist:'* ]]
