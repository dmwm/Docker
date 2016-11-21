#! /bin/bash

echo Running slice $1 of $2
set -x

# Make sure we the certs we use are readable by us and only us

/home/dmwm/ContainerScripts/fixCertificates.sh

# Start up services (Couch and MySQL)

source ./env_unittest.sh
$manage start-services

cd /home/dmwm/wmcore_unittest/WMCore/

# Make sure we base our tests on the latest Jenkins-tested master

git fetch --tags
git pull
export LATEST_TAG=`git tag |grep JENKINS| sort | tail -1`

# Find the commit that represents the tip of the PR the latest tag
if [ -z "$3" ]; then
  export COMMIT=$LATEST_TAG
else
  git fetch origin pull/$3/merge:pr_merge
  export COMMIT=`git rev-parse "pr_merge^{commit}"`
fi

# First try to merge this PR into the same tag used for the baseline
# If it doesn't merge, just test the tip of the branch
(git checkout $LATEST_TAG && git merge $COMMIT) ||  git checkout -f $COMMIT

# Run tests and watchdog to shut it down if needed

cd /home/dmwm/wmcore_unittest/WMCore/
rm test/python/WMCore_t/REST_t/*_t.py
/home/dmwm/cms-bot/DMWM/TestWatchdog.py &
python setup.py test --buildBotMode=true --reallyDeleteMyDatabaseAfterEveryTest=true --testCertainPath=test/python --testTotalSlices=$2 --testCurrentSlice=$1

# Save the results

cp nosetests.xml /home/dmwm/artifacts/nosetests-$1.xml
