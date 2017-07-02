FROM	jcgruenhage/baseimage-alpine
MAINTAINER Jan Christian Grünhage <jan.christian@gruenhage.xyz>

ENV GOPATH=/gopath \
      CADDY_REPO_OWNER=mholt \
      CADDY_REPO_NAME=caddy \
      CADDY_BRANCH=tags/v0.10.4 \
      CADDYPATH=/caddy \
      UID=192 \
      GID=192

ADD	plugins.txt /plugins

RUN	apk upgrade --update \
 			&& apk add build-base su-exec libcap go git \
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

ADD	root /

EXPOSE		2015 80 443
VOLUME		["$CADDYPATH"]
