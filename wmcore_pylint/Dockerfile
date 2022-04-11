FROM python:3.8.2-slim

COPY requirements.txt requirements.txt

RUN apt update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/* && \
    pip install -r requirements.txt

RUN useradd -ms /bin/bash dmwm

USER dmwm
ENV HOME /home/dmwm
WORKDIR /home/dmwm

RUN git clone https://github.com/dmwm/WMCore.git

RUN mkdir artifacts ContainerScripts
COPY ContainerScripts ContainerScripts

ENTRYPOINT ["ContainerScripts/pylintTest.sh"]

