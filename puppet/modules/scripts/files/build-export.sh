#!/bin/bash

# ARGS

BUILD_ID=$1
BUILD_DIR_PATH=$2
PROJECT_NAME=$3
REF_NAME=$4


# VARS

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

# reports with different badge logic
str="`declare -p BUILD_EXPORT_REPORTERS 2>/dev/null`";
if [[ "${str:0:10}" == 'declare -a' ]];then
  reports=$BUILD_EXPORT_REPORTERS
else
  reports=(coverage mochawesome-reports plato)
fi

for report in "${reports[@]}"; do

  from="$BUILD_DIR_PATH/$report"
  to="$STATIC_BUILD_DIR/$report"

  echo "Processing $report..."

  # Process one-by-one
  case $report in
    "coverage" )
      if [[ -d $from ]]; then
        echo "Copying $from to $to..."
        cp -r $from $to

        # COVERAGE BADGE

        cd $BUILD_DIR_PATH

        coverage=`./node_modules/.bin/istanbul report text-summary | grep "Lines" | grep -oE "(([0-9]+.)?[0-9]+)%" | sed 's/%//'`
        coverage_rounded=$(awk "BEGIN { pc=100*${coverage}; i=int(pc); print (pc-i<0.5)?i:i+1 }")

        subject="Coverage"
        status=$coverage_rounded
        color=$(getcolor $coverage_rounded)

        URL="https://img.shields.io/badge/$subject-$status-$color.svg"
        img="$STATIC_BUILD_DIR/badge_coverage.svg"
        echo "Curl to $URL, img path $img";
        curl -sS "$URL" > $img

      else
        echo "No directory found for $report..."

        subject="Coverage"
        status="Fail"
        color="lightgrey"

        URL="https://img.shields.io/badge/$subject-$status-$color.svg"
        img="$STATIC_BUILD_DIR/badge_coverage.svg"
        echo "Curl to $URL, img path $img";
        curl -sS "$URL" > $img4
      fi
      ;;
    "mochawesome-reports" )
      if [[ -d $from ]]; then
        echo "Copying $from to $to..."
        cp -r $from $to

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

      else
        echo "No directory found for $report..."

        subject="Tests passed"
        status="Fail"
        color="lightgrey"

        URL="https://img.shields.io/badge/$subject-$status-$color.svg"
        img="$STATIC_BUILD_DIR/badge_tests.svg"
        echo "Curl to $URL, img path $img";
        curl -sS "$URL" > $img4
      fi
      ;;
    "plato" )
      if [[ -d $from ]]; then
        echo "Copying $from to $to..."
        cp -r $from $to

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

      else
        echo "No directory found for $report..."

        subject="Maintainability"
        status="Fail"
        color="lightgrey"

        URL="https://img.shields.io/badge/$subject-$status-$color.svg"
        img="$STATIC_BUILD_DIR/badge_maintainability.svg"
        echo "Curl to $URL, img path $img";
        curl -sS "$URL" > $img4
      fi
      ;;
  esac

done

# Copy to remote server if user and host are specified
if [ "$BUILD_EXPORT_REMOTE_USER" ] && [ "$BUILD_EXPORT_REMOTE_HOST" ]; then
  echo "Copying $STATIC_BUILD_DIR at $BUILD_EXPORT_REMOTE_HOST..."
  ssh $BUILD_EXPORT_REMOTE_USER@$BUILD_EXPORT_REMOTE_HOST "mkdir -p \"$STATIC_BUILD_DIR\""
  scp -rpC $STATIC_BUILD_DIR $BUILD_EXPORT_REMOTE_USER@$BUILD_EXPORT_REMOTE_HOST:$STATIC_PROJECT_DIR
  rm -rf $STATIC_BUILD_DIR
fi

# REPLACE LATEST LINKS
if [[ $REF_NAME = "master" ]]; then
  if [ "$BUILD_EXPORT_REMOTE_USER" ] && [ "$BUILD_EXPORT_REMOTE_HOST" ]; then
    echo "Replacing link on latest build to $BUILD_ID at $BUILD_EXPORT_REMOTE_HOST..."
    ssh $BUILD_EXPORT_REMOTE_USER@$BUILD_EXPORT_REMOTE_HOST "rm -r \"$STATIC_PROJECT_DIR/latest\""
    ssh $BUILD_EXPORT_REMOTE_USER@$BUILD_EXPORT_REMOTE_HOST "cp -r \"$STATIC_BUILD_DIR\" \"$STATIC_PROJECT_DIR/latest\""
  else
    echo "Replacing link on latest build to $BUILD_ID..."
    rm -r "$STATIC_PROJECT_DIR/latest"
    cp -r "$STATIC_BUILD_DIR" "$STATIC_PROJECT_DIR/latest"
  fi
else
  echo "REF_NAME is not master. Skipping latest build link replace..."
fi

# ECHO LINK AT BOTTOM

URL="http://$BUILD_EXPORT_REMOTE_HOST/builds/$PROJECT_NAME/$BUILD_ID"

echo -e "\n\n\n"
echo "========================================="
echo "=== SEE YOUR BUILD DIR AT $URL  ==="
echo "========================================="
echo -e "\n\n\n"
