#!/usr/bin/env bash

if [ -z "$ghprbPullId" -o -z "$ghprbTargetBranch" ]; then
  echo "Not all necessary environment variables set: ghprbPullId, ghprbTargetBranch"
  exit 1
fi

source ./env_unittest.sh

pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH

# debug
set -x

# Figure out the one commit we are interested in and what happens to the repo if we were to merge it

#git fetch --tags  https://github.com/dmwm/WMCore.git "+refs/heads/*:refs/remotes/origin/*"
git config remote.origin.url https://github.com/dmwm/WMCore.git
#git config --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

git fetch origin pull/${ghprbPullId}/merge:PR_MERGE
export COMMIT=`git rev-parse "PR_MERGE^{commit}"`
git checkout ${ghprbTargetBranch}
#git pull
git diff --name-only  ${ghprbTargetBranch}..${COMMIT} > allChangedFiles.txt

# Debug
cat allChangedFiles.txt

${HOME}/ContainerScripts/IdentifyPythonFiles.py allChangedFiles.txt > changedFiles.txt

# Debug
cat changedFiles.txt
echo "{}" > pylintReport.json

git checkout -f $ghprbTargetBranch
while read name; do
  pylint --evaluation='10.0 - ((float(5 * error + warning) / statement) * 10)'  --rcfile standards/.pylintrc --msg-template='{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}'  $name > pylint.out || true
 ${HOME}/ContainerScripts/AggregatePylint.py base

done <changedFiles.txt


git checkout -f $COMMIT
while read name; do
  pylint --evaluation='10.0 - ((float(5 * error + warning) / statement) * 10)'  --rcfile standards/.pylintrc  --msg-template='{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}'  $name  > pylint.out || true
 ${HOME}/ContainerScripts/AggregatePylint.py test

done <changedFiles.txt

ls -lR
cp *.json ${HOME}/artifacts/
ls -lR ${HOME}
popd



