#!/bin/bash

set -e
set -o pipefail
set -u

if [ $# -eq 0 ]
  then
    echo "Usage : ./incrementVersion.sh ('App' or 'SDK')"
    exit 1
fi

PROJECT=$1
MAIN_FILE='./build.gradle'
VERSIONNAME=""

if [ "$PROJECT" == "App" ];then
    # versionApp = "1.83.0"
    VERSIONNAME=$(sed -n /'versionApp = "[0-9\.]*".*'/p $MAIN_FILE)
elif [ "$PROJECT" == "SDK" ];then
    # versionSdk = "2.4.0"
    VERSIONNAME=$(sed -n /'versionSdk = "[0-9\.]*".*'/p $MAIN_FILE)
else
    echo 'ERROR: As a second parameter you have to write "App" or "SDK".'
    exit 1
fi

# Picking the versionName by removing unnecessary things
VERSIONNAME=${VERSIONNAME%\"*}
VERSIONNAME=${VERSIONNAME##*\"}

if [[ ${#VERSIONNAME} -eq 0 ]];then
  echo "Failed to extract VERSIONNAME"
  exit 1
fi

echo "Current $PROJECT version: $VERSIONNAME"
echo
read -r -p "New version: " NEW_VERSIONNAME
if [[ ${#NEW_VERSIONNAME} -eq 0 ]];then
  echo "ERROR: Empty $PROJECT version"
  exit 1
fi

if [ "$PROJECT" == "App" ];then
    sed -i '' /'.versionApp = "[0-9\.]*".*'/s/'"[0-9\.]*"'/\"$NEW_VERSIONNAME\"/ "$MAIN_FILE"
else
    sed -i '' /'.versionSdk = "[0-9\.]*".*'/s/'"[0-9\.]*"'/\"$NEW_VERSIONNAME\"/ "$MAIN_FILE"
fi

echo
echo "New $PROJECT version: $NEW_VERSIONNAME"
echo "Updating version..."

#================================== Commit ==================================
git add "$MAIN_FILE"
git commit -m "Iterate for $PROJECT release $NEW_VERSIONNAME"
git diff --quiet
echo
read -r -p "Increment committed. Push to origin (y/n)? " REPLY
if [ "$REPLY" == "y" ]
then
 git push
 echo
 echo "New $PROJECT version pushed!"
fi
#============================================================================

echo
