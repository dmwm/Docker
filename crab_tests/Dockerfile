FROM gitlab-registry.cern.ch/cmsdocks/dmwm:wmcore_base

RUN echo "2017-05-23" # Change to tickle new release
COPY CRABScripts /home/dmwm/CRABScripts

RUN sh ContainerScripts/installWMCore.sh
RUN sh CRABScripts/installCRAB.sh 

ENTRYPOINT ["/bin/bash"]

