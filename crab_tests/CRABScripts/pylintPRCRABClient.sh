#!/usr/bin/env bash

if [ -z "$ghprbPullId" -o -z "$ghprbTargetBranch" ]; then
  echo "Not all necessary environment variables set: ghprbPullId, ghprbTargetBranch"
  exit 1
fi

# Setup the environment
source ./env_unittest.sh
pushd crabclient_test/CRABClient
export PYTHONPATH=`pwd`/src/python:`pwd`/test/python:${PYTHONPATH}

# Figure out the one commit we are interested in and what happens to the repo if we were to merge it
git config remote.origin.url https://github.com/dmwm/CRABClient.git
git fetch origin pull/${ghprbPullId}/merge:PR_MERGE
export COMMIT=`git rev-parse "PR_MERGE^{commit}"`
git checkout ${ghprbTargetBranch}
git pull

# Which python files changed?
git diff --name-only  ${ghprbTargetBranch}..${COMMIT} > allChangedFiles.txt
${HOME}/ContainerScripts/IdentifyPythonFiles.py allChangedFiles.txt > changedFiles.txt

# Get pylint report for master
git checkout -f $ghprbTargetBranch
echo "{}" > pylintReport.json
while read name; do
  pylint --evaluation='10.0 - ((float(5 * error + warning) / statement) * 10)' --rcfile /home/dmwm/crabclient_test/.pylintrc -d C0103 -f parseable $name > pylint.out || true
 ${HOME}/ContainerScripts/AggregatePylint.py base
done <changedFiles.txt

# Get pylint report for the tip of our branch
git checkout -f $COMMIT
while read name; do
  pylint --evaluation='10.0 - ((float(5 * error + warning) / statement) * 10)' --rcfile /home/dmwm/crabclient_test/.pylintrc -d C0103 -f parseable $name  > pylint.out || true
 ${HOME}/ContainerScripts/AggregatePylint.py test
done <changedFiles.txt

# Save the artifacts to a directory shared by the container and the node
cp pylintReport.json ${HOME}/artifacts/

# Do pep8 analysis on tip of branch
# Renamed pycodestyle in future iterations
# Hack to fix broken pep8
echo "#! /usr/bin/env python" > ./pep8
cat `which pep8` >> ./pep8
chmod +x pep8

touch NOTHING # If changedFiles.txt is empty, this will keep it from parsing the whole directory tree
./pep8 NOTHING `< changedFiles.txt` > pep8.txt
cp pep8.txt ${HOME}/artifacts/

popd
