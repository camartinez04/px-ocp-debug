FROM registry.access.redhat.com/ubi7/ubi:7.8
RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y && \
    yum install collectl-4.3.0-5.el7 pciutils hostname sysvinit-tools -y && \
    yum clean all
COPY entrypoint.sh /root/entrypoint.sh
COPY px-collectl.sh /root/px-collectl.sh

RUN chmod 741 /root/entrypoint.sh && chmod 741 /root/px-collectl.sh

CMD ["/root/entrypoint.sh"]
