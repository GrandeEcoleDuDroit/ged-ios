#!/bin/sh

echo "Download configuration files"
curl "$ORACLE_BUCKET_URL"/GoogleService-Info.plist -o $(PROJECT_DIR)/GoogleService-Info.plist
curl "$ORACLE_BUCKET_URL"/Config.xconfig -o $(PROJECT_DIR)/Config.xconfig
