FROM vondo/cms_grid

# Add the extra system stuff we need

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
COPY ContainerScripts/installWMCore.sh /home/dmwm/ContainerScripts/installWMCore.sh
RUN sh ContainerScripts/installWMCore.sh
COPY ContainerScripts /home/dmwm/ContainerScripts

RUN git clone https://github.com/cms-sw/cms-bot.git

RUN sh ContainerScripts/updateGit.sh

ENTRYPOINT ["ContainerScripts/runSlice.sh"]
CMD ["0", "10"]

