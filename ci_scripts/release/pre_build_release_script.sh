#!/bin/sh

echo "Download configuration files"

curl "$ORACLE_BUCKET_URL/GoogleService-Info-prod.plist" -o "$CI_PRIMARY_REPOSITORY_PATH/LaGrandeEcoleDuDroit/GoogleService-Info.plist"
curl "$ORACLE_BUCKET_URL/Config-prod.xcconfig" -o "$CI_PRIMARY_REPOSITORY_PATH/LaGrandeEcoleDuDroit/Config.xcconfig"
