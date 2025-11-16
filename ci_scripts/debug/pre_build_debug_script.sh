#!/bin/sh

echo "Download configuration files"

curl "$ORACLE_BUCKET_URL/GoogleService-Info-debug.plist" -o "$CI_PRIMARY_REPOSITORY_PATH/LaGrandeEcoleDuDroit/GoogleService-Info.plist"
curl "$ORACLE_BUCKET_URL/Config-debug.xcconfig" -o "$CI_PRIMARY_REPOSITORY_PATH/LaGrandeEcoleDuDroit/Config.xcconfig"
