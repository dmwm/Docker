#! /bin/bash

set -e
set -x

GIT_CHECKOUT=master
if [[ -z $RELEASE_TAG ]]; then
    GIT_CHECKOUT=$RELEASE_TAG
fi

python -m pip install --user -r /home/dmwm/build/requirements.txt

curl -o /home/dmwm/crab/.pylintrc https://raw.githubusercontent.com/dmwm/WMCore/master/standards/.pylintrc
patch /home/dmwm/crab/.pylintrc /home/dmwm/build/dot-pylintrc.diff
curl -o /home/dmwm/crab/setup.cfg https://raw.githubusercontent.com/dmwm/WMCore/master/setup.cfg

git clone https://github.com/dmwm/WMCore /home/dmwm/crab/WMCore
git clone https://github.com/dmwm/DBS /home/dmwm/crab/DBS
git clone https://github.com/dmwm/CRABServer /home/dmwm/crab/CRABServer
git clone https://github.com/dmwm/CRABClient /home/dmwm/crab/CRABClient

cd /home/dmwm/crab/CRABServer
git checkout $GIT_CHECKOUT || true
cd -
cd /home/dmwm/crab/CRABClient
git checkout $GIT_CHECKOUT || true
cd -
