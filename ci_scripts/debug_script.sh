#!/bin/sh

echo "Download configuration files"
curl "$ORACLE_BUCKET_URL"/GoogleService-Info.plist -o $CI_PROJECT_FILE_PATH/GoogleService-Info.plist
curl "$ORACLE_BUCKET_URL"/Config.xconfig -o $CI_PROJECT_FILE_PATH/Config.xconfig
