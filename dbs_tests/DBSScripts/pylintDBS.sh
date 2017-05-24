#!/usr/bin/env bash

# Run pylint and pep8 (pycodestyle) over the entire WMCore code base

# Setup the environment
source ./env_unittest.sh
pushd dbs_test/DBS
#export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:$PYTHONPATH

timeout -s 9 5m git checkout master || timeout -s 9 5m git checkout master
timeout -s 9 5m git pull origin || timeout -s 9 5m git pull origin

# Run pylint on the whole code base
pylint --rcfile /home/dmwm/dbs_test/.pylintrc  -f parseable Client/src/python/dbs/ Server/Python/src/dbs/ PycurlClient/src/python/RestClient/

# Fix pep8 which has the wrong python executable
echo "#! /usr/bin/env python" > ../pep8
cat `which pep8` >> ../pep8
chmod +x ../pep8

# Run PEP-8 checker but not in pylint format
../pep8 --format=default --exclude=.svn,CVS,.bzr,.hg,.git,__pycache__,.tox. Client/src/python/dbs/ Server/Python/src/dbs/ PycurlClient/src/python/RestClient/
