#!/usr/bin/env bash

if [ -z "$ghprbPullId" -o -z "$ghprbTargetBranch" ]; then
  echo "Not all necessary environment variables set: ghprbPullId, ghprbTargetBranch"
  exit 1
fi

# Setup the environment
source ./env_unittest.sh
pushd dbs_test/DBS
export PYTHONPATH=`pwd`/Server/Python/src:`pwd`/Client/src/python/dbs/api:${PYTHONPATH}

# Figure out the one commit we are interested in and what happens to the repo if we were to merge it
git config remote.origin.url https://github.com/dmwm/DBS.git
git fetch origin pull/${ghprbPullId}/merge:PR_MERGE
export COMMIT=`git rev-parse "PR_MERGE^{commit}"`
git checkout -f ${COMMIT}

futurize -1 src/ test/ > test.patch

# Get changed files and analyze for idioms
git diff --name-only  ${ghprbTargetBranch}..${COMMIT} > changedFiles.txt
git diff-tree --name-status  -r ${ghprbTargetBranch}..${COMMIT} | egrep "^A" | cut -f 2 > addedFiles.txt

while read name; do
  futurize -f idioms $name  >> idioms.patch || true
done <changedFiles.txt

${HOME}/ContainerScripts/AnalyzePyFuture.py > added.message

cp test.patch idioms.patch added.message ${HOME}/artifacts/

popd
