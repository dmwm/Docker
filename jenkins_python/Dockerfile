FROM python:3

# Add the extra python libraries we need

RUN pip install Jinja2
RUN pip install PyGithub
RUN pip install xunitparser

COPY scripts scripts
COPY templates templates
RUN mkdir artifacts



# Temporary

COPY pylintReport.json pylintReport.json


ENTRYPOINT ["scripts/AnalyzePylint.py"]

#CMD ['/bin/bash']
