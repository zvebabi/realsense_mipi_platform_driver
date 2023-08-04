#!/bin/bash

set -e

if [[ $# < 1 ]]; then
    echo "apply_patches.sh apply [JetPack_version]"
    exit 1
fi

DEVDIR=$(cd `dirname $0` && pwd)

. $DEVDIR/scripts/setup-common "$2"

cd "$DEVDIR"

apply_external_patches() {
    if [ $1 = 'apply' ]; then
        git -C sources_$JETPACK_VERSION/ apply ${PWD}/$2/$JETPACK_VERSION/*
    fi
}

apply_external_patches $1 patches_leopard
