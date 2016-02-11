#!/bin/bash

# ARGS

BUILD_ID=$1
BUILD_DIR_REL_TO_BUILDS=$2
PROJECT_NAME=$3


# VARS

GITLAB_BUILDS_DIR="/home/gitlab-runner"
BUILD_DIR_PATH="$GITLAB_BUILDS_DIR/$BUILD_DIR_REL_TO_BUILDS"
TARGET_DIR_NAME=`basename $BUILD_DIR_PATH`

STATIC_PROJECT_DIR="/opt/gitlab-ci-builds/builds/$PROJECT_NAME"
STATIC_BUILD_DIR="$STATIC_PROJECT_DIR/$BUILD_ID"

# ENV VARS
#
# BUILD_EXPORT_REMOTE_HOST - host to rsync exported directory
# BUILD_EXPORT_REMOTE_USER - user to rsync exported directory

# UTILS

getcolor () {
  percent=$1
  COLORS=(red orange yellow yellowgreen green brightgreen)
  largestIndex=${#COLORS[@]}
  index=$(($percent*$largestIndex/100))
  if [ $(($index+1)) -gt $largestIndex ]; then index=$(($index-1)); fi
  if [ $index -lt 0 ]; then index=0; fi

  color=${COLORS[$index]}
  echo "$color"
}


# ACTION!

# ensure dir exists
mkdir -p $STATIC_BUILD_DIR

# copy HTML reports
dirs=(coverage mochawesome-reports plato)
for dir in "${dirs[@]}"
do
  from="$BUILD_DIR_PATH/$dir"
  to="$STATIC_BUILD_DIR/$dir"
  echo "Copying $from to $to..."
  cp -rf $from $to
done


# COVERAGE BADGE

cd $BUILD_DIR_PATH

coverage=`./node_modules/.bin/istanbul report text-summary | grep "Lines" | grep -oE "(([0-9]+.)?[0-9]+)%" | sed 's/%//'`

subject="Coverage"
status=$coverage
color=$(getcolor $coverage)

URL="https://img.shields.io/badge/$subject-$status-$color.svg"
img="$STATIC_BUILD_DIR/badge_coverage.svg"
echo "Curl to $URL, img path $img";
curl -sS "$URL" > $img

# TEST CASES BADGE

cd $BUILD_DIR_PATH

tests=`cat mochawesome-reports/mochawesome.json| grep -h '"tests": ' | grep -oE "[0-9]+"`
passed=`cat mochawesome-reports/mochawesome.json| grep -h '"passes": ' | grep -oE "[0-9]+"`

tests_passed=$(awk "BEGIN { pc=100*${passed}/${tests}; i=int(pc); print (pc-i<0.5)?i:i+1 }")

subject="Tests passed"
status="$passed/$tests"
color=$(getcolor $tests_passed)

URL="https://img.shields.io/badge/$subject-$status-$color.svg"
img="$STATIC_BUILD_DIR/badge_tests.svg"
echo "Curl to $URL, img path $img";
curl -sS "$URL" > $img

# MAINTAINABLITY BADGE

cd $BUILD_DIR_PATH

maintainability=`grep -oE '"maintainability":"(([0-9]+.)?[0-9]+)"' plato/report.json | grep -oE "(([0-9]+.)?[0-9]+)"`
maintainability_rounded=$(awk "BEGIN { pc=${maintainability}; i=int(pc); print (pc-i<0.5)?i:i+1 }")

subject="Maintainability"
status=$maintainability
color=$(getcolor $maintainability_rounded)

URL="https://img.shields.io/badge/$subject-$status-$color.svg"
img="$STATIC_BUILD_DIR/badge_maintainability.svg"
echo "Curl to $URL, img path $img";
curl -sS "$URL" > $img

# Copy to remote server if user and host are specified
if [ "$BUILD_EXPORT_REMOTE_USER" ] && [ "$BUILD_EXPORT_REMOTE_HOST" ]; then
  echo "Copying $STATIC_BUILD_DIR at $BUILD_EXPORT_REMOTE_HOST..."
  ssh $BUILD_EXPORT_REMOTE_USER@$BUILD_EXPORT_REMOTE_HOST "\"mkdir -p $STATIC_BUILD_DIR\""
  scp $STATIC_BUILD_DIR $BUILD_EXPORT_REMOTE_USER@$BUILD_EXPORT_REMOTE_HOST:$STATIC_PROJECT_DIR
  rm -rf $STATIC_BUILD_DIR
fi

# REPLACE LATEST LINKS
if [ "$BUILD_EXPORT_REMOTE_USER" ] && [ "$BUILD_EXPORT_REMOTE_HOST" ]; then
  echo "Replacing link on latest build to $BUILD_ID at $BUILD_EXPORT_REMOTE_HOST..."
  ssh $BUILD_EXPORT_REMOTE_USER@$BUILD_EXPORT_REMOTE_HOST "unlink \"$STATIC_PROJECT_DIR/latest\""
  ssh $BUILD_EXPORT_REMOTE_USER@$BUILD_EXPORT_REMOTE_HOST "ln -s \"$STATIC_BUILD_DIR\" \"$STATIC_PROJECT_DIR/latest\""
else
  echo "Replacing link on latest build to $BUILD_ID..."
  unlink "$STATIC_PROJECT_DIR/latest"
  ln -s "$STATIC_BUILD_DIR" "$STATIC_PROJECT_DIR/latest"
fi

# ECHO LINK AT BOTTOM

URL="http://$BUILD_EXPORT_REMOTE_HOST/$PROJECT_NAME/$BUILD_ID"

echo -e "\n\n\n"
echo "========================================="
echo "=== COPIED TO $URL/$TARGET_DIR_NAME  ==="
echo "=== SEE YOUR BUILD DIR AT $URL  ==="
echo "========================================="
echo -e "\n\n\n"
