#!/bin/sh

set -e


# env

export REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

function error {
  echo "$(basename $0): $1" >&2
}
export -f error

function fail {
  error "$1"
  exit 1
}
export -f fail


# main

if [ "$#" -lt 1 ]; then
  fail "No command provided"
fi

TARGET="$(uname -s)"
case "$TARGET" in
  Darwin*) TARGET=darwin;;
  Linux*) TARGET=linux;;
  *) fail "Unhandled target: $TARGET";;
esac

CMD=$1
TARGET_CMD="$CMD-$TARGET"
ARGS=${@:2}

function try_cmd {
  cmd="$REPO_ROOT/cmd/$1"

  if [ -e "$cmd" ]; then
    exec $cmd $ARGS
  fi
}

try_cmd $CMD
try_cmd $TARGET_CMD

error "Command not found: $CMD"
error "Command not found: $TARGET_CMD"

exit 1
