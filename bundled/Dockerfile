FROM golang:latest

# Install sshpiper
ENV VERSION=0.3.1

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

# Install Forego
RUN go get -u github.com/ddollar/forego

# Install docker-gen
ENV DOCKER_GEN_VERSION 0.7.4

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

## SCRIPTS
## -------

COPY ./docker-entrypoint.sh /
COPY ./Procfile /
COPY ./reload-on-change.sh /reload-on-change.sh
COPY ./sshproxy.tmpl /etc/docker-gen/templates/sshproxy.tmpl
COPY ./generateConfig.sh /

RUN mkdir -p /docker-entrypoint.d \
 && touch /etc/sshpiper/docker.generated.conf \
 && chmod +x /docker-entrypoint.sh \
 && chmod +x /generateConfig.sh \
 && chmod +x /reload-on-change.sh

ENV DOCKER_HOST unix:///tmp/docker.sock

WORKDIR /
EXPOSE 2222
VOLUME ["/var/sshpiper", "/etc/sshpiper"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]