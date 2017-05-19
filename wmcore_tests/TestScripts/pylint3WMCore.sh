#!/usr/bin/env bash

# Run pylint over the entire WMCore code base for compatibility checks

# Setup the environment
source ./env_unittest.sh
pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH

git checkout master
git pull origin

# Run the python3 compatibility checkers in python
pylint --py3k -f parseable -d W1618 src/python/* test/python/*
