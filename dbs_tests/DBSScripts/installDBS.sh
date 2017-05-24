#! /bin/bash



mkdir /home/dmwm/dbs_test/
pushd  /home/dmwm/dbs_test/
curl -o .pylintrc https://raw.githubusercontent.com/dmwm/WMCore/master/standards/.pylintrc
git clone https://github.com/dmwm/DBS.git
pushd DBS
git checkout master
popd
popd


