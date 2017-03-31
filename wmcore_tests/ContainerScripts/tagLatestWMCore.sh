#!/usr/bin/env bash

pushd /home/dmwm/wmcore_unittest/WMCore/

set +x
git remote set-url origin https://${DMWMBOT_TOKEN}:x-oauth-basic@github.com/${WMCORE_REPO}/${CODE_REPO}
set -x

git checkout master
git pull

# Create a new tag and push it
export TAG=${TAG_PREFIX}_`date "+%Y%m%d%H%M%S"`
git tag ${TAG}
git push origin ${TAG}

# Deletes tags from previous days
export VALID_TAGS=`date "+JENKINS_%Y%m%d"`
git push --delete origin `git tag | grep JENKINS | grep -Ev ${VALID_TAGS}` || true

popd
