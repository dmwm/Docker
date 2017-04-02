#!/usr/bin/env bash

if [ -z "$ghprbPullId" -o -z "$ghprbTargetBranch" ]; then
  echo "Not all necessary environment variables set: ghprbPullId, ghprbTargetBranch"
  exit 1
fi

source ./env_unittest.sh

pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH

#git fetch --tags  https://github.com/dmwm/WMCore.git "+refs/heads/*:refs/remotes/origin/*"
git config remote.origin.url https://github.com/dmwm/WMCore.git
git config --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

git fetch --tags  https://github.com/dmwm/WMCore.git "origin/pr/${ghprbPullId}" || true
git fetch --tags  https://github.com/dmwm/WMCore.git "origin/pr/${ghprbPullId}/merge" || true
git fetch --tags  https://github.com/dmwm/WMCore.git "+refs/pull/*:refs/remotes/origin/pr/${ghprbPullId}" || true
git fetch --tags  https://github.com/dmwm/WMCore.git "+refs/pull/*:refs/remotes/origin/pr/${ghprbPullId}/merge" || true
export COMMIT=`git rev-parse "origin/pr/$ghprbPullId/merge^{commit}"`
git checkout ${ghprbTargetBranch}
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
cp *.json ${HOME}/artifacts/
popd



