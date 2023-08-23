FROM python:3.8.2-slim

RUN apt update && \
    apt-get install -y --no-install-recommends \
    git curl patch \
    && rm -rf /var/lib/apt/lists/*

# Add a new user (CMS stuff refuses to install as root)
RUN useradd -ms /bin/bash dmwm
USER dmwm
ENV HOME /home/dmwm
WORKDIR /home/dmwm

RUN mkdir /home/dmwm/build /home/dmwm/crab/ /home/dmwm/artifacts
COPY dockerbuild /home/dmwm/build
COPY crab /home/dmwm/crab
RUN bash /home/dmwm/build/install.sh

CMD [ "/bin/bash", "/home/dmwm/crab/crabPylint.sh" ]
