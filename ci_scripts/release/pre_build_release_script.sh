#!/bin/sh

echo "Download configuration files"

curl "$ORACLE_BUCKET_URL/Configurations/GoogleService-Info-release.plist" -o "$CI_PRIMARY_REPOSITORY_PATH/ItsCloudy/GoogleService-Info.plist"
curl "$ORACLE_BUCKET_URL/Configurations/Config-release.xcconfig" -o "$CI_PRIMARY_REPOSITORY_PATH/ItsCloudy/Config.xcconfig"
