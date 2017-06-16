FROM gitlab-registry.cern.ch/cmsdocks/dmwm:cms_grid

# Add the extra system stuff we need

RUN echo "Updating the base system - 2017-06-16"

RUN yum -y install cern-get-sso-cookie && yum clean all

# Add a new user (CMS stuff refuses to install as root)

RUN useradd -ms /bin/bash dmwm

# Switch user

USER dmwm
ENV HOME /home/dmwm
WORKDIR /home/dmwm
RUN mkdir artifacts
RUN mkdir certs
RUN mkdir ContainerScripts

# Remove this when stable
COPY ContainerScripts /home/dmwm/ContainerScripts

# Install cms-bot and WMCore
RUN echo "Release version of WMCore 1.0.21.patch1"
ENV DMWM_ARCH slc6_amd64_gcc493
RUN sh ContainerScripts/installCMSBot.sh

#Finished

ENTRYPOINT ["/bin/bash"]

