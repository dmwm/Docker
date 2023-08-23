#!/usr/bin/env bash

if [ -z "$ghprbPullId" -o -z "$ghprbTargetBranch" ]; then
  echo "Not all necessary environment variables set: ghprbPullId, ghprbTargetBranch"
  exit 1
fi

# all available env variables described at https://plugins.jenkins.io/ghprb/

echo "Executing Pylint for"
echo "  \- repo $ghprbPullLink"
echo "  \- PR ID $ghprbPullId"
echo "  \- target branch $ghprbTargetBranch"

JSON_FILENAME=pylintpy3Report.json
PYCODESTYLE_FILENAME=pep8py3.txt
CRABREPO=CRABServer
if [[ $ghprbPullLink == *"CRABClient"* ]]; then
  CRABREPO=CRABClient
fi

pushd /home/dmwm/crab/$CRABREPO
export PYTHONPATH=$(pwd)/src/python:$PYTHONPATH

# Figure out the one commit we are interested in and what happens to the repo if we were to merge it
git config remote.origin.url https://github.com/dmwm/$CRABREPO.git
git fetch origin ${ghprbTargetBranch}
git fetch origin pull/${ghprbPullId}/merge:PR_MERGE
export COMMIT=`git rev-parse "PR_MERGE^{commit}"`
git checkout ${ghprbTargetBranch}
git pull

# Which python files changed?
git diff --name-only  ${ghprbTargetBranch}..${COMMIT} > allChangedFiles.txt
${HOME}/crab/IdentifyPythonFiles.py allChangedFiles.txt > changedFiles.txt

echo "Printing Pylint version"
pylint --version

# Get pylint report for master
git checkout -f $ghprbTargetBranch
echo "{}" > pylintReport.json
echo "*** Running Pylint on the changed files against the $ghprbTargetBranch"
while read name; do
  pylint --evaluation='10.0 - ((float(5 * error + warning) / statement) * 10)'  --rcfile /home/dmwm/crab/.pylintrc --msg-template='{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}'  $name > pylint.out || true
 ${HOME}/crab/AggregatePylint.py base
done <changedFiles.txt

# Get pylint report for the tip of our branch
git checkout -f $COMMIT
echo "*** Running Pylint on the changed files against the feature branch"
while read name; do
  pylint --evaluation='10.0 - ((float(5 * error + warning) / statement) * 10)'  --rcfile /home/dmwm/crab/.pylintrc  --msg-template='{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}'  $name  > pylint.out || true
 ${HOME}/crab/AggregatePylint.py test
done <changedFiles.txt

# Save the artifacts to a directory shared by the container and the node
cp pylintReport.json ${HOME}/artifacts/$JSON_FILENAME

# Do pycodestyle  analysis on tip of branch
touch NOTHING # If changedFiles.txt is empty, this will keep it from parsing the whole directory tree
pycodestyle --config="/home/dmwm/crab/setup.cfg" NOTHING `< changedFiles.txt` > ${PYCODESTYLE_FILENAME}
cp ${PYCODESTYLE_FILENAME} ${HOME}/artifacts/

popd
