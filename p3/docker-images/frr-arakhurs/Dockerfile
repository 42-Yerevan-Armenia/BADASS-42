FROM debian:bookworm-slim

LABEL maintainer="arakhurs"

RUN apt-get -o Acquire::Retries=5 update && \
    apt-get -o Acquire::Retries=5 install -y --fix-missing \
    frr frr-pythontools iproute2 iputils-ping net-tools && \
    rm -rf /var/lib/apt/lists/*

COPY daemons.conf /etc/frr/daemons
COPY --chmod=755 router*.sh reset.sh /root/

CMD ["/bin/bash", "-c", "tail -f /dev/null"]
