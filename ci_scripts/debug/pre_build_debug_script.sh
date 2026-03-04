#!/bin/sh

echo "Download configuration files"

curl "$ORACLE_BUCKET_URL/Configurations/GoogleService-Info-debug.plist" -o "$CI_PRIMARY_REPOSITORY_PATH/ItsCloudy/GoogleService-Info.plist"
curl "$ORACLE_BUCKET_URL/Configurations/Config-debug.xcconfig" -o "$CI_PRIMARY_REPOSITORY_PATH/ItsCloudy/Config.xcconfig"
