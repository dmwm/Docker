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

pylint --py3k -f parseable -d W1618 \
  aso_test/AsyncStageout/test/python/AsyncStageOut_t/ \
  aso_test/AsyncStageout/src/python/AsyncStageOut crabserver_test/CRABServer/src/python/UserFileCache \
  crabserver_test/CRABServer/src/python/taskbuffer crabserver_test/CRABServer/src/python/TaskWorker \
  crabserver_test/CRABServer/src/python/CRABInterface crabserver_test/CRABServer/src/python/Databases \
  crabclient_test/CRABClient/src/python/CRABClient crabclient_test/CRABClient/src/python/CRABAPI

