FROM cern/cc7-base:latest

# Add the extra system stuff we need

RUN yum -y update && yum -y install wget HEP_OSlibs cronie yum-plugin-priorities e2fsprogs git voms-clients-cpp osg-ca-certs vo-client && yum clean all
#RUN wget -O HEP.rpm http://linuxsoft.cern.ch/wlcg/sl6/x86_64/HEP_OSlibs_SL6-1.0.16-0.el6.x86_64.rpm && wget -O OSG.rpm https://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm && yum -y install HEP.rpm OSG.rpm && yum clean all
#RUN yum -y install HEP_OSlibs cronie yum-plugin-priorities e2fsprogs git voms-clients-cpp osg-ca-certs vo-client && yum clean all
CMD ['/bin/sh']

#COPY deploy_unittest.sh /
