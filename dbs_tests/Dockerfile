FROM gitlab-registry.cern.ch/cmsdocks/dmwm:wmcore_base

RUN echo "2017-05-23" # Change to tickle new release
COPY DBSScripts /home/dmwm/DBSScripts

RUN sh ContainerScripts/installWMCore.sh
RUN sh DBSScripts/installDBS.sh && rm -rf /home/dmwm/dbs_test/DBS/Server/Python/src/dbs/dao/MySQL

ENTRYPOINT ["/bin/bash"]

