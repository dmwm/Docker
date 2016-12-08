#! /bin/sh

pushd /home/dmwm/wmcore_unittest/WMCore/
git pull
git fetch --tags  https://github.com/dmwm/WMCore.git "+refs/heads/*:refs/remotes/origin/*"
git config remote.origin.url https://github.com/dmwm/WMCore.git
git config --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch --tags  https://github.com/dmwm/WMCore.git "+refs/pull/*:refs/remotes/origin/pr/*"



popd
