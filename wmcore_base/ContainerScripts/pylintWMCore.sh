#!/usr/bin/env bash


if [[ -f env_unittest_py3.sh ]]
then
    echo "Sourcing a python3 unittest environment"
    source env_unittest_py3.sh
    OUT_FILENAME=pylintpy3.txt
else
    echo "Sourcing a python2 unittest environment"
    source env_unittest.sh
    OUT_FILENAME=pylint.txt
fi


pushd wmcore_unittest/WMCore
export PYTHONPATH=`pwd`/test/python:`pwd`/src/python:${PYTHONPATH}

git checkout master
git pull

# For old code by timestamp

#pushd code
#git checkout `git rev-list -n 1 --before="2017-01-01 00:00" master`
#popd



pylint -j 2 --rcfile=code/standards/.pylintrc --output-format=parseable code/src/python/* code/test/python/* > ${OUT_FILENAME} || true
cp ${OUT_FILENAME} ${HOME}/artifacts/

popd

# Parse output
# also try just code/*

