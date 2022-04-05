#!/bin/bash

export PYTHONPATH=/home/dmwm/crab/WMCore/src/python:$PYTHONPATH
export PYTHONPATH=/home/dmwm/crab/DBS/src/python:$PYTHONPATH
export PYTHONPATH=/home/dmwm/crab/CRABServer/src/python:$PYTHONPATH
export PYTHONPATH=/home/dmwm/crab/CRABClient/src/python:$PYTHONPATH

export PATH=$PATH:/home/dmwm/.local/bin

# if the input variables are empty, then we are not running this script from
# jenkins, but we are testing the pipeline on our laptop.
# in this latter case, we set the variables to a reasonable test value
if [[ -z $ghprbPullId ]]; then
    export ghprbPullId=7296
fi
if [[ -z $ghprbTargetBranch ]]; then
    export ghprbTargetBranch=master
fi

echo "(DEBUG) input env variables "
echo "(DEBUG)   \- ghprbPullId: ${ghprbPullId}"
echo "(DEBUG)   \- ghprbTargetBranch: ${ghprbTargetBranch}"
echo "(DEBUG) end"

bash $HOME/crab/pylintTest.sh
