#!/usr/bin/env bash

source ./env_unittest.sh

pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:${PYTHONPATH}

git checkout master
git pull

# For old code by timestamp

#pushd code
#git checkout `git rev-list -n 1 --before="2017-01-01 00:00" master`
#popd



pylint -j 2 --rcfile=code/standards/.pylintrc --output-format=parseable code/src/python/* code/test/python/* > pylint.txt || true
cp pylint.txt ${HOME}/artifacts/

popd

# Parse output
# also try just code/*

