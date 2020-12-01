#!/usr/bin/env bash

if [ -z "$ghprbPullId" -o -z "$ghprbTargetBranch" ]; then
  echo "Not all necessary environment variables set: ghprbPullId, ghprbTargetBranch"
  exit 1
fi

# Setup the environment
source ./env_unittest.sh
pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH

# Figure out the one commit we are interested in and what happens to the repo if we were to merge it
git config remote.origin.url https://github.com/dmwm/WMCore.git
git fetch origin pull/${ghprbPullId}/merge:PR_MERGE
export COMMIT=`git rev-parse "PR_MERGE^{commit}"`
git checkout ${ghprbTargetBranch}
git pull

# Which python files changed?
git diff --name-only  ${ghprbTargetBranch}..${COMMIT} > allChangedFiles.txt
${HOME}/ContainerScripts/IdentifyPythonFiles.py allChangedFiles.txt > changedFiles.txt

pylint --version
echo "{}" > pylintReport.json

# Get pylint report for the tip of our branch
git checkout -f $COMMIT
while read name; do
  pylint --py3k -d W1618,W1619 --evaluation='10.0 - ((float(5 * error + warning) / statement) * 10)'  --rcfile standards/.pylintrc  --msg-template='{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}'  $name  > pylint.out || true
 ${HOME}/ContainerScripts/AggregatePylint.py test
done <changedFiles.txt

# Save the artifacts to a directory shared by the container and the node
cp pylintReport.json ${HOME}/artifacts/pylint3kReport.json
popd
