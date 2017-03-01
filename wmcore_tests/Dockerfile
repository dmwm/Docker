FROM gitlab-registry.cern.ch/cmsdocks/dmwm:wmcore_base
RUN echo "2017-03-01" # Change to tickle new release
RUN sh ContainerScripts/installWMCore.sh

RUN echo "Updating git again"
RUN sh ContainerScripts/updateGit.sh
#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["ContainerScripts/runSlice.sh"]
CMD ["0", "10"]

