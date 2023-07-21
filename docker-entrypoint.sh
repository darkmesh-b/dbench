#!/usr/bin/env sh
set -e

fio --server --daemonize=/tmp/fio.pid &
tail -f /dev/null
