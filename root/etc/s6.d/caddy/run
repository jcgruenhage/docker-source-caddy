#!/bin/sh
chown -R ${UID}:${GID} /caddy
exec su-exec ${UID}:${GID} /usr/bin/caddy -quic --conf /caddy/Caddyfile
