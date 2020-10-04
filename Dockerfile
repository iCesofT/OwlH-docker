###############################################################################
# MULTI-STAGE BUILD: BASE
################################################################################
FROM centos:centos7 as owlh-centos-base

RUN yum -y update     \
 && yum -y upgrade    \
 && yum -y install wget net-tools tcpdump socat tcpreplay initscripts jq PyYAML libpcap \
 && yum -y --enablerepo=extras install epel-release \
 && yum clean all     \
 && yum -y autoremove \
 && rm -rf /var/cache/yum

################################################################################
# BUILD: OWLH-NODE Suricata and zeek
################################################################################

FROM owlh-centos-base

STOPSIGNAL SIGRTMIN+3

COPY [ "./scripts/docker-entrypoint.sh", "/" ]
COPY [ "./config/*", "/tmp/" ]
COPY [ "./scripts/*", "/tmp/" ]
COPY [ "./config/dummy-modules-load.conf", "/etc/modules-load.d/dummy.conf" ]
COPY [ "./config/dummy-modprobe.conf", "/etc/modprobe.d/dummy.conf" ]
COPY [ "./config/ifcfg-dummy", "/etc/sysconfig/network-scripts/ifcfg-dummy" ]

RUN cd /tmp \
 && wget --quiet http://repo.owlh.net/current-centos/owlhinstaller.tar.gz \
 && mkdir owlhinstaller \
 && tar -C owlhinstaller -xf owlhinstaller.tar.gz \
 && mv owlhinstaller/config.json owlhinstaller/config.json.orig \
 && mv /tmp/install-node-config.json owlhinstaller/config.json \
 && cd owlhinstaller && ./owlhinstaller \
 && cd /tmp \
 && wget --quiet http://repo.owlh.net/current-centos/services/suricata-5.0.3-centos7.tar.gz \
 && mkdir suricata \
 && cd suricata    \
 && tar -xf /tmp/suricata-5.0.3-centos7.tar.gz \
 && tar -C /usr/bin/ -xf /tmp/suricata/suribin/suricatabin.tar.gz \
 && tar -C / -xf /tmp/suricata/suriconfig/suricataconfig.tar.gz   \
 && tar -C / -xf /tmp/suricata/surilib/suricatalib.tar.gz   \
 && ln -s /usr/lib64/libhtp.so.2.0.0 /usr/lib64/libhtp.so   \
 && ln -s /usr/lib64/libhtp.so.2.0.0 /usr/lib64/libhtp.so.2 \
 && ln -s /usr/lib64/libnetfilter_queue.so.1.3.0 /usr/lib64/libnetfilter_queue.so   \
 && ln -s /usr/lib64/libnetfilter_queue.so.1.3.0 /usr/lib64/libnetfilter_queue.so.1 \
 && ln -s /usr/lib64/libnet.so.1.7.0 /usr/lib64/libnet.so   \
 && ln -s /usr/lib64/libnet.so.1.7.0 /usr/lib64/libnet.so.1 \
 && mkdir /var/log/suricata \
 && cd /tmp \
 && wget --quiet http://repo.owlh.net/current-centos/services/zeek-3.0.3-centos7.tar.gz \
 && tar -C / -xf /tmp/zeek-3.0.3-centos7.tar.gz \
 && rm -rf /tmp/* \
 && chmod +x /docker-entrypoint.sh \
 && echo "NOZEROCONF=yes" >> /etc/sysconfig/network

# OwlH Node
EXPOSE 50002
EXPOSE 50010-50020

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "owlh" ]
