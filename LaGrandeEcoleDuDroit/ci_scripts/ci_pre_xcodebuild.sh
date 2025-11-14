#!/bin/sh

if [ $CI_PULL_REQUEST_TARGET_BRANCH = "development" ]; then
    ./debug_script.sh
else
    echo "Not a development branch, skipping debug script"
    exit 0
fi
