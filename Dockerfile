FROM alpine:edge
MAINTAINER Jan Christian Grünhage <mail@janchristiangruenhage.de>

ENV GOPATH /gopath
ENV CADDY_BRANCH unbuffered_proxy
ENV CADDYPATH /caddy
ENV UID 192
ENV GID 192

RUN addgroup -g $GID -S caddy \
	&& adduser -u $UID -g $GID -S caddy

RUN apk add --update musl \
	&& apk add --no-cache build-base libcap tini go git \
	&& mkdir -p $GOPATH/src/github.com/mholt \
	&& cd $GOPATH/src/github.com/mholt \
	&& git clone https://github.com/mholt/caddy \
	&& cd caddy \
	&& git checkout $CADDY_BRANCH \
	&& go get github.com/mholt/caddy/... \
	&& mv $GOPATH/bin/caddy /usr/bin \
	&& setcap cap_net_bind_service=+ep /usr/bin/caddy \
	&& apk del --purge build-base go \
	&& mkdir $CADDYPATH \
	&& rm -rf $GOPATH /var/cache/apk/*

USER		caddy
EXPOSE		2015 80 443
VOLUME		[ "$CADDYPATH" ]
WORKDIR		"$CADDYPATH"
ENTRYPOINT	[ "/sbin/tini" ]
CMD		[ "caddy", "-quic", "--conf", "/caddy/Caddyfile" ]
