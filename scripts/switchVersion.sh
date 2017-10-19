#!/bin/bash

set -e
set -u
set -o pipefail

if [ $# -le 1 ] && [ $# -gt 2 ]
  then
    echo "Usage : ./incrementVersion.sh ('App' or 'SDK')"
    exit 1
fi

MAIN_FILE='./build.gradle'
#RC_TAG='./scripts/rcTag.sh'
VERSIONNAME_APP=$(sed -n /'versionApp = "[0-9\.]*".*'/p $MAIN_FILE)
VERSIONNAME_SDK=$(sed -n /'versionSdk = "[0-9\.]*".*'/p $MAIN_FILE)
VERSIONNAME=""

if [ "$1" == "App" ]
  then
    VERSIONNAME="$VERSIONNAME_APP"
  elif [ "$1" == "SDK" ]
    then
    VERSIONNAME="$VERSIONNAME_SDK"
  else
    echo "ERROR: As a second parameter you have to write `App` or `SDK`."
    exit 1
  fi

VERSIONNAME=${VERSIONNAME%\"*}
VERSIONNAME=${VERSIONNAME##*\"}

if [[ ${#VERSIONNAME} -eq 0 ]];then
  echo "Failed to extract VERSIONNAME"
  exit 1
fi

echo "Current versionName: $VERSIONNAME"
echo
read -r -p "Writte new versionName: " NEW_VERSIONNAME
if [[ ${#NEW_VERSIONNAME} -eq 0 ]];
then
  echo "Empty versionName"
  exit 1
fi

read -r -p "Are you sure the new versionName is \"$NEW_VERSIONNAME\" ?(y/n) " REPLY
if [ "$REPLY" == "y" ]
then
  #echo "sed /'.versionName "\[\0\-\9\.\]\*".*'/s/'"\[\0\-\9\.\]\*"'/\"$NEW_VERSIONNAME\"/ $TEMP_FILE > $MAIN_FILE"
  sed -i '' /'.versionName "[0-9\.]*".*'/s/'"[0-9\.]*"'/\"$NEW_VERSIONNAME\"/ "$MAIN_FILE"

  echo
  echo "Updated Android build information. New version name: $NEW_VERSIONNAME"

  #============================== Commit and tag ==============================
  git add .
  git ci -m "Iterate for $1 release $NEW_VERSIONNAME"
  read -p "Commited new versionName! Push to origin (y/n)? " REPLY
  if [ "$REPLY" == "y" ]
  then
     git push
     echo "New versionName pushed!"
  fi
  #sh $RC_TAG $0
  #============================================================================

fi

echo
echo "END"
