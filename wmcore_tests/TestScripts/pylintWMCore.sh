#!/usr/bin/env bash

# Run pylint over the entire WMCore code base

# Setup the environment
source ./env_unittest.sh
pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH

set -x
git checkout master
git pull origin

pwd
ls


#pylint --rcfile=code/standards/.pylintrc -f parseable install/lib/python2.6/site-packages/* 2>&1 > pylint.txt || true
#ls -lR code

#pushd code
#git checkout `git rev-list -n 1 --before="2017-01-01 00:00" master`
#popd

pylint --rcfile=standards/.pylintrc  -f parseable src/python/* test/python/*

# For py3 compatibility

#pylint --py3k -f parseable -d W1618 .

#echo "#! /usr/bin/env python" > ../pep8
#cat `which pep8` >> ../pep8
#chmod +x ../pep8

# Run PEP-8 checker but not in pylint format
../pep8 --format=default .
