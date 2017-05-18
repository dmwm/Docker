#!/usr/bin/env bash

# Run pylint over the entire WMCore code base

set -x

# Setup the environment
source ./env_unittest.sh
pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH


git checkout master
git pull origin

#pylint --rcfile=code/standards/.pylintrc -f parseable install/lib/python2.6/site-packages/* 2>&1 > pylint.txt || true
#ls -lR code

#pushd code
#git checkout `git rev-list -n 1 --before="2017-01-01 00:00" master`
#popd

pylint -j 2 --rcfile=standards/.pylintrc --output-format=parseable code/src/python/* code/test/python/* > pylint.txt || true

# For py3 compatibility

pylint --py3k -f parseable -d W1618 WMCore || true


