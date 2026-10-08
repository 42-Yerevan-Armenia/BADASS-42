FROM alpine:latest

LABEL maintainer="arakhurs"

RUN apk update && apk add --no-cache busybox

COPY --chmod=755 host*.sh reset.sh /root/

CMD ["/bin/sh"]
