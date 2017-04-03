#!/usr/bin/env bash

if [ -z "$ghprbPullId" -o -z "$ghprbTargetBranch" ]; then
  echo "Not all necessary environment variables set: ghprbPullId, ghprbTargetBranch"
  exit 1
fi

source ./env_unittest.sh

pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:${PYTHONPATH}

git config remote.origin.url https://github.com/dmwm/WMCore.git
git fetch origin pull/${ghprbPullId}/merge:PR_MERGE
export COMMIT=`git rev-parse "PR_MERGE^{commit}"`
git checkout -f $COMMIT

futurize -1 src/ test/ > test.patch

# Get changed files and analyze for idioms
git diff --name-only  ${ghprbTargetBranch}..${COMMIT} > changedFiles.txt
git diff-tree --name-status  -r ${ghprbTargetBranch}..${COMMIT} | egrep "^A" | cut -f 2 > addedFiles.txt

# Debug
cat changedFiles.txt
cat addedFiles.txt

while read name; do
  futurize -f idioms  $name  >> idioms.patch || true
done <changedFiles.txt

${HOME}/ContainerScripts/AnalyzePyFuture.py > added.message

cp test.patch idioms.patch added.message ${HOME}/artifacts/

popd


