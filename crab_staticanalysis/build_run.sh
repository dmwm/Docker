#!/bin/bash

# when building the image manually, push it to registry.cern.ch
IMAGETAG=registry.cern.ch/cmscrab/crabstaticanalysis:latest
# gitlab will automatically build this image and keep it in its registry.
# IMAGETAG=gitlab-registry.cern.ch/cmsdocks/dmwm:crab_staticanalysis

docker build --no-cache -t $IMAGETAG .

# docker run -it $IMAGETAG

# test CRABServer
mkdir -p ~/temp/artifacts-0 ~/temp/artifacts-1
docker run \
-e ghprbPullId=7309 -e  ghprbTargetBranch=master \
-v ~/temp/artifacts-0/:/home/dmwm/artifacts/:Z \
-it $IMAGETAG

# test CRABClient
docker run \
-e ghprbPullId=5168 -e  ghprbTargetBranch=master \
-e ghprbPullLink=https://github.com/dmwm/CRABClient/ \
-v ~/temp/artifacts-1/:/home/dmwm/artifacts/:Z \
-it $IMAGETAG
