FROM python:2

# Add the extra python libraries we need

RUN pip install Jinja2
RUN pip install PyGithub
RUN pip install xunitparser

RUN mkdir artifacts

RUN curl -o UnstableTests.txt https://raw.githubusercontent.com/dmwm/WMCore/master/test/etc/UnstableTests.txt

# Temporary

#COPY pylintReport.json pylintReport.json
#COPY nosetests-0-1147.xml MasterUnitTests/1147/nosetests-0-1147.xml
#COPY nosetests-1-1147.xml MasterUnitTests/1147/nosetests-1-1147.xml
#COPY nosetests-0-3458.xml LatestUnitTests/3458/nosetests-0-3458.xml

# End temporary

COPY scripts scripts
COPY templates templates

ENTRYPOINT ["scripts/PullRequestReport.py"]

#CMD ['/bin/bash']
