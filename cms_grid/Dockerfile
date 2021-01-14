FROM cern/cc7-base:latest

# Add the extra system stuff we need
ADD http://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo /etc/yum.repos.d/egi.repo
ADD http://linuxsoft.cern.ch/wlcg/wlcg-centos7.repo /etc/yum.repos.d/wlcg-centos7.repo
#ADD http://linuxsoft.cern.ch/cern/centos/7/ /etc/yum.repos.d/CentOS-CERN.repo

# Install CA related things
RUN yum install -y sudo cern-get-certificate fetch-crl CERN-CA-certs ca-certificates dummy-ca-certs \
    ca-policy-lcg ca-policy-egi-core ca_CERN-GridCA ca_CERN-Root-2 \
    && yum clean all && rm -rf /var/cache/yum && ln -s /bin/bash /usr/bin/bashs && \
    echo "32 */6 * * * root ! /usr/sbin/fetch-crl -q -r 360" > /etc/cron.d/fetch-crl-docker

# Workaround for "Couldn't open file /etc/pki/rpm-gpg/RPM-GPG-KEY-wlcg"
RUN yum -y update && yum -y install --nogpgcheck HEP_OSlibs && yum clean all

RUN yum -y update && yum -y install which wget cronie yum-plugin-priorities e2fsprogs git voms-clients-cpp osg-ca-certs vo-client && yum clean all

# Try more stuff from cms images
RUN yum update -y && yum install -y HEP_OSlibs_CC7 finger screen libXpm-devel libXft-devel krb5-devel subversion telnet readline-devel wget \
                                    glibc-devel.x86_64 mesa-libGL-devel.x86_64 mesa-libGLU-devel.x86_64 libXext-devel rsync tcsh zsh tcl tk \
                                    openssl e2fsprogs perl-ExtUtils-Embed compat-libstdc++-33 libXmu libXcursor libXrandr e2fsprogs-libs \
                                    libXi libXinerama tar perl-Data-Dumper perl-Digest-MD5 perl-Switch perl-Env perl-Thread-Queue bzip2 && \
                                    yum clean all

# And a list from Alan:
RUN yum -y update && yum -y install libaio unzip wget libXft-devel libXpm-devel libXext-devel mesa-libGLU-devel perl-Switch perl-Env perl-Thread-Queue && yum clean all




#RUN wget -O HEP.rpm http://linuxsoft.cern.ch/wlcg/sl6/x86_64/HEP_OSlibs_SL6-1.0.16-0.el6.x86_64.rpm && wget -O OSG.rpm https://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm && yum -y install HEP.rpm OSG.rpm && yum clean all
#RUN yum -y install HEP_OSlibs cronie yum-plugin-priorities e2fsprogs git voms-clients-cpp osg-ca-certs vo-client && yum clean all
CMD ['/bin/sh']

#COPY deploy_unittest.sh /
