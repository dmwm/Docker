FROM gitlab-registry.cern.ch/cmsdocks/dmwm:wmcore_base

RUN echo "2017-03-01" # Change to tickle new release
RUN sh ContainerScripts/installWMCore.sh && \
    rm /home/dmwm/unittestdeploy/wmagent/1.1.2.pre5/install/mysql/database/ib_logfile*
RUN sh ContainerScripts/updateGit.sh

COPY TestScripts /home/dmwm/TestScripts
VOLUME /home/dmwm/unittestdeploy/wmagent/current/install/

ENTRYPOINT ["TestScripts/runSlice.sh"]
CMD ["0", "10"]

