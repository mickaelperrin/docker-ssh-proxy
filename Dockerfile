FROM golang:latest

ENV VERSION=0.3.1
ENV DOCKER_HOST unix:///tmp/docker.sock

RUN apt-get update \
 && apt-get install -y libpam0g-dev libpam-google-authenticator bash inotify-tools \
 && ln -sf /usr/include/security/_pam_types.h /usr/include/security/pam_types.h \
 && mkdir -p /etc/sshpiper \
 && touch /etc/sshpiper/docker.generated.conf \
 && mkdir -p /go/src/github.com/tg123/sshpiper \
 && git clone --branch v${VERSION} https://github.com/tg123/sshpiper /go/src/github.com/tg123/sshpiper \
 && go install -ldflags "$(/go/src/github.com/tg123/sshpiper/sshpiperd/ldflags.sh)" -tags pam github.com/tg123/sshpiper/sshpiperd \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

## SCRIPTS
## -------

COPY ./scripts/docker-entrypoint.sh /
COPY ./scripts/generateConfig.sh /

RUN mkdir -p /docker-entrypoint.d \
 && touch /etc/sshpiper/docker.generated.conf \
 && chmod +x /docker-entrypoint.sh \
 && chmod +x /generateConfig.sh

EXPOSE 2222
VOLUME ["/var/sshpiper", "/etc/sshpiper"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/go/bin/sshpiperd"]