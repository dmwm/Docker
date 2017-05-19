#!/usr/bin/env bash

# Run pylint and pep8 (pycodestyle) over the entire WMCore code base

# Setup the environment
source ./env_unittest.sh
pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH

git checkout master
git pull origin

# Run pylint on the whole code base
pylint --rcfile=standards/.pylintrc  -f parseable src/python/* test/python/*

# Fix pep8 which has the wrong python executable
echo "#! /usr/bin/env python" > ../pep8
cat `which pep8` >> ../pep8
chmod +x ../pep8

# Run PEP-8 checker but not in pylint format
../pep8 --format=default --exclude=test/data,.svn,CVS,.bzr,.hg,.git,__pycache__,.tox.
