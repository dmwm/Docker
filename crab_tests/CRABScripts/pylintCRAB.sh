#!/usr/bin/env bash

# Run pylint and pep8 (pycodestyle) over the entire DBS code base

# Setup the environment
source ./env_unittest.sh

# Do CRABServer code

pushd crabserver_test/CRABServer

timeout -s 9 5m git checkout master || timeout -s 9 5m git checkout master
timeout -s 9 5m git pull origin || timeout -s 9 5m git pull origin

# Run pylint on the whole code base
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:${PYTHONPATH}
popd

# Do CRABClient code
pushd crabclient_test/CRABClient

timeout -s 9 5m git checkout master || timeout -s 9 5m git checkout master
timeout -s 9 5m git pull origin || timeout -s 9 5m git pull origin

# Run pylint on the whole code base
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:${PYTHONPATH}
popd

# Do ASO code

pushd aso_test/AsyncStageout

timeout -s 9 5m git checkout master || timeout -s 9 5m git checkout master
timeout -s 9 5m git pull origin || timeout -s 9 5m git pull origin

# Run pylint on the whole code base
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:${PYTHONPATH}
popd

pylint --rcfile /home/dmwm/crabclient_test/.pylintrc -f parseable \
  aso_test/AsyncStageout/test/python/AsyncStageOut_t/ \
  aso_test/AsyncStageout/src/python/AsyncStageOut crabserver_test/CRABServer/src/python/UserFileCache \
  crabserver_test/CRABServer/src/python/taskbuffer crabserver_test/CRABServer/src/python/TaskWorker \
  crabserver_test/CRABServer/src/python/CRABInterface crabserver_test/CRABServer/src/python/Databases \
  crabclient_test/CRABClient/src/python/CRABClient crabclient_test/CRABClient/src/python/CRABAPI



# Fix pep8 which has the wrong python executable
echo "#! /usr/bin/env python" > ./pep8
cat `which pep8` >> ./pep8
chmod +x ./pep8

# Run PEP-8 checker but not in pylint format
./pep8 --format=default --exclude=.svn,CVS,.bzr,.hg,.git,__pycache__,.tox. crabserver_test crabclient_test aso_test

exit

