#!/usr/bin/env sh
set -e

if [ -z $DBENCH_MOUNTPOINT ]; then
    DBENCH_MOUNTPOINT=/tmp
fi


if [ "$1" = 'fio' ]; then
    fio --server --daemonize=/tmp/fio.pid
    rm $DBENCH_MOUNTPOINT/fiotest
    exit 0
fi

exec "$@"
