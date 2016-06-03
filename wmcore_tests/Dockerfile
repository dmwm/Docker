FROM vondo/cms_grid

# Add the extra system stuff we need

# Add a new user (CMS stuff refuses to install as root)

RUN useradd -ms /bin/bash dmwm
#RUN chown -R dmwm /build

# Switch user

USER dmwm
ENV HOME /home/dmwm
WORKDIR /home/dmwm
RUN mkdir ContainerScripts

COPY ContainerScripts /home/dmwm/ContainerScripts
RUN sh ContainerScripts/installWMCore.sh

CMD bash

