#!/bin/bash
# Tag current commit with beta/[currentDate]_[index]
# Possibility to edit tag message during the process
# param : release version

echo "Tagging current commit as the next RC..."

# Get date of lastest beta tag in the history
LAST_BETA=`git describe --tags "$(git rev-list --tags='beta/*' --max-count=1)"`
read -p  "$LAST_BETA"
if [ -z "$LAST_BETA" ];
then
  DATE_LAST_BETA=1
else
  DATE_LAST_BETA=`git log -1 --format=%at $LAST_BETA`
fi
read -p  "$DATE_LAST_BETA"
# Get date of lastest RC tag in the history
LAST_RC=`git describe --tags "$(git rev-list --tags='release/*' --max-count=1)"`
read -p  "$LAST_RC"
if [ -z "$LAST_RC" ];
then
  DATE_LAST_RC=1
else
  DATE_LAST_RC=`git log -1 --format=%at $LAST_RC`
fi
read -p  "$DATE_LAST_RC"

RC_TAG_BASE="release/$1-RC"

# Retrieve which index to apply at the end of the name of the tag we are building
INDEX=`git tag | grep $RC_TAG_BASE | wc -l`
((INDEX++))

# Set the name of the tag we will apply
RC_TAG=$RC_TAG_BASE$INDEX

# Build message associated to the tag
LOGS=""

if [ $DATE_LAST_BETA -gt $DATE_LAST_RC ];
then
   LAST_BETA_LOGS=`git show -s --format=%N $LAST_BETA | grep -v "tag beta/" | grep -v "Tagger:"`
   LOGS="$LAST_BETA_LOGS"
else
   LAST_RC_LOGS=`git show -s --format=%N $LAST_RC | grep -v "tag release/" | grep -v "Tagger:"`
   echo "LAST_RC_LOGS = $LAST_RC_LOGS"
   LOGS="$LAST_RC_LOGS"
   echo "LOGS = $LOGS"
fi
read -p "WAIT"
# Open vi for edition
echo $LOGS > tmp
vi tmp

# Update commit message possibly edited in vi
LOGS=$(cat tmp)
rm tmp

# Issue the command to tag the current commit locally
git tag $RC_TAG -m "$LOGS"

# Issue the command to push the tag to origin

echo "Current commit tagged with" $RC_TAG "."

read -p "Tag created locally. Push to origin (y/n)? "
if [ "$REPLY" == "y" ]
then
   # Issue the command to push the tag to origin
   git push origin $RC_TAG
   echo "Tag push to origin!"
fi
