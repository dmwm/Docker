#! /bin/bash

mkdir /home/dmwm/crabclient_test/
mkdir /home/dmwm/crabserver_test/
mkdir /home/dmwm/aso_test/

pushd  /home/dmwm/crabclient_test/
curl -o .pylintrc https://raw.githubusercontent.com/dmwm/WMCore/master/standards/.pylintrc
git clone https://github.com/dmwm/CRABClient.git
pushd CRABClient
git checkout master
popd
popd

pushd  /home/dmwm/crabserver_test/
curl -o .pylintrc https://raw.githubusercontent.com/dmwm/WMCore/master/standards/.pylintrc
git clone https://github.com/dmwm/CRABServer.git
pushd CRABServer
git checkout master
popd
popd

pushd  /home/dmwm/aso_test/
curl -o .pylintrc https://raw.githubusercontent.com/dmwm/WMCore/master/standards/.pylintrc
git clone https://github.com/dmwm/AsyncStageout.git
pushd AsyncStageout
git checkout master
popd
popd


