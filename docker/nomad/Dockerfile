FROM centos:latest

ENV NOMAD_VERSION 0.6.0

RUN yum install -y wget unzip \
  && wget https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip \
  && unzip nomad_${NOMAD_VERSION}_linux_amd64.zip \
  && mv nomad /usr/bin/ \
  && rm -rf nomad_${NOMAD_VERSION}_linux_amd64.zip

EXPOSE 4646 4647 4648 4648/udp

VOLUME [ "/var/lib/nomad" ]

COPY ./conf/base.hcl /etc/nomad/base.hcl
COPY ./conf/node.hcl /etc/nomad/node.hcl

CMD ["nomad", "agent", "-server", "-config=/etc/nomad", "-data-dir=/var/lib/nomad"]
