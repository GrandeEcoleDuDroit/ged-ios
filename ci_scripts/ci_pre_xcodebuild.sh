#!/bin/sh

if [ $CI_PULL_REQUEST_TARGET_BRANCH = "development" ] && [ $CI_XCODEBUILD_ACTION = "build" ]; then
    ./debug/pre_build_debug_script.sh
fi

if [[ $CI_PULL_REQUEST_TARGET_BRANCH == release/* ]] && [ $CI_XCODEBUILD_ACTION = "build" ]; then
    ./release/pre_build_release_script.sh
fi
