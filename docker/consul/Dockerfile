FROM centos:latest

ENV CONSUL_VERSION 0.8.5

RUN yum install -y wget unzip \
  && wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip \
  && unzip consul_${CONSUL_VERSION}_linux_amd64.zip \
  && mv consul /usr/bin/ \
  && rm -rf consul_${CONSUL_VERSION}_linux_amd64.zip

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

VOLUME [ "/var/lib/consul" ]

COPY ./conf/base.json /etc/consul/base.json
COPY ./conf/node.json /etc/consul/node.json

CMD ["consul", "agent", "-config-dir=/etc/consul", "-data-dir=/var/lib/consul"]
