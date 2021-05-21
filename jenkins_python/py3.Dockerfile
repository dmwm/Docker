FROM python:3.8.2

# Add the extra python libraries we need

RUN pip --no-cache-dir install Jinja2
RUN pip --no-cache-dir install PyGithub
RUN pip --no-cache-dir install xunitparser

RUN mkdir artifacts

COPY scripts scripts
COPY templates templates

# Keep this at the end to avoid caching
RUN curl -o UnstableTests.txt https://raw.githubusercontent.com/dmwm/WMCore/master/test/etc/UnstableTests.txt

ENTRYPOINT ["scripts/PullRequestReport.py"]
