FROM debian:bullseye

LABEL maintainer="arakhurs"

RUN apt-get update && \
    apt-get install -y frr frr-pythontools busybox iproute2 iputils-ping net-tools && \
    rm -rf /var/lib/apt/lists/*

COPY daemons.conf /etc/frr/daemons
COPY frr.conf /etc/frr/frr.conf

EXPOSE 2601 2602 2604 2605 2606 2608

CMD ["/bin/bash", "-c", "/etc/init.d/frr start && tail -f /dev/null"]

