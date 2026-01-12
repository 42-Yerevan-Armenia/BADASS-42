FROM debian:bullseye
LABEL maintainer="arakhurs"

RUN apt-get update && \
    apt-get install -y frr frr-pythontools iproute2 iputils-ping net-tools && \
    rm -rf /var/lib/apt/lists/*

COPY daemons.conf /etc/frr/daemons

CMD ["/bin/bash", "-c", "/etc/init.d/frr start && tail -f /dev/null"]
