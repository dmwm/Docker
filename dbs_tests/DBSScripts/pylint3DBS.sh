#!/usr/bin/env bash

# Run pylint and pep8 (pycodestyle) over the entire WMCore code base

# Setup the environment
source ./env_unittest.sh
pushd dbs_test/DBS
#export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH

timeout -s 9 5m git checkout master || timeout -s 9 5m git checkout master
timeout -s 9 5m git pull origin || timeout -s 9 5m git pull origin

# Run pylint on the whole code base checking for Python3 compatibility
pylint --py3k -f parseable -d W1618 Client/src/python/dbs/ Server/Python/src/dbs/ PycurlClient/src/python/RestClient/
