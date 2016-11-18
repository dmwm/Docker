FROM python:3

# Add the extra python libraries we need

RUN pip install Jinja2
RUN pip install PyGithub

COPY scripts scripts
COPY templates templates

# Temporary

COPY pylintReport.json pylintReport.json

CMD ['/bin/bash']
