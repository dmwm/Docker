FROM python:2

# Add the extra python libraries we need

RUN pip install Jinja2
RUN pip install PyGithub
RUN pip install xunitparser

RUN mkdir artifacts

COPY scripts scripts
COPY templates templates

# Keep this at the end to avoid caching
RUN curl -o UnstableTests.txt https://raw.githubusercontent.com/dmwm/WMCore/master/test/etc/UnstableTests.txt

ENTRYPOINT ["scripts/PullRequestReport.py"]
