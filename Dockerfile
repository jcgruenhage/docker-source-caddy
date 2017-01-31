FROM alpine:edge
MAINTAINER Jan Christian Grünhage <mail@janchristiangruenhage.de>

ENV GOPATH /gopath
ENV CADDY_REPO_OWNER mholt
ENV CADDY_REPO_NAME caddy
ENV CADDY_BRANCH tags/v0.9.5
ENV CADDYPATH /caddy
ENV UID 192
ENV GID 192

RUN addgroup -g $GID -S caddy \
	&& adduser -u $UID -g $GID -S caddy

RUN apk add --update musl \
	&& apk add --no-cache build-base libcap tini go git \
	&& mkdir -p $GOPATH/src/github.com/$CADDY_REPO_OWNER \
	&& cd $GOPATH/src/github.com/$CADDY_REPO_OWNER \
	&& git clone https://github.com/$CADDY_REPO_OWNER/$CADDY_REPO_NAME \
	&& cd $CADDY_REPO_NAME \
	&& git checkout $CADDY_BRANCH \
	&& go get github.com/$CADDY_REPO_OWNER/$CADDY_REPO_NAME/... \
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
