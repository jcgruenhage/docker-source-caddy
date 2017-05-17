FROM alpine:edge
MAINTAINER Jan Christian Grünhage <mail@janchristiangruenhage.de>

ENV GOPATH /gopath
ENV CADDY_REPO_OWNER mholt
ENV CADDY_REPO_NAME caddy
ENV CADDY_BRANCH tags/v0.10.2
ENV CADDYPATH /caddy
ENV UID 192
ENV GID 192

COPY plugins.txt /plugins

RUN apk add --update musl \
	&& apk add --no-cache build-base su-exec libcap tini go git \
	&& mkdir -p $GOPATH/src/github.com/$CADDY_REPO_OWNER \
	&& cd $GOPATH/src/github.com/$CADDY_REPO_OWNER \
	&& git clone https://github.com/$CADDY_REPO_OWNER/$CADDY_REPO_NAME \
	&& cd $CADDY_REPO_NAME \
	&& git checkout $CADDY_BRANCH \
	&& cd caddy/caddymain \
	&& export line="$(grep -n "// This is where other plugins get plugged in (imported)" < run.go | sed 's/^\([0-9]\+\):.*$/\1/')" \
	&& head -n ${line} run.go > newrun.go \
	&& cat /plugins >> newrun.go \
	&& line=`expr $line + 1` \
	&& tail -n +${line} run.go >> newrun.go \
	&& rm -f run.go \
	&& mv newrun.go run.go \
	&& go get github.com/$CADDY_REPO_OWNER/$CADDY_REPO_NAME/... \
	&& mv $GOPATH/bin/caddy /usr/bin \
	&& setcap cap_net_bind_service=+ep /usr/bin/caddy \
	&& apk del --purge build-base go \
	&& mkdir $CADDYPATH \
	&& rm -rf $GOPATH /var/cache/apk/* /plugins

COPY root /

EXPOSE		2015 80 443
VOLUME		["$CADDYPATH" ]
WORKDIR		"$CADDYPATH"
ENTRYPOINT	["/sbin/tini", "--", "/usr/local/bin/run.sh"]
