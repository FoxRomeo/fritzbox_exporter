###############
# Build Image
FROM golang:alpine3.15 AS builder

ARG RELEASE_VERSION
#ARG RELEASE_VERSION=master
ENV RELEASE_VERSION $RELEASE_VERSION

RUN go clean -cache -modcache; \
    go install github.com/foxromeo/fritzbox_exporter@${RELEASE_VERSION} \
    && mkdir /app \
    && mv /go/bin/fritzbox_exporter /app

WORKDIR /app

COPY metrics.json metrics-lua.json /app/
COPY metrics-lua_cable.json luaTest.json luaTest-many.json /app/
COPY all_available_metrics_*.json /app/

###############
# Runtime Image
FROM alpine:3.15 as runtime-image

ARG REPO=foxromeo/fritzbox_exporter

LABEL org.opencontainers.image.source https://github.com/${REPO}
MAINTAINER docker@intrepid.de

RUN mkdir /app

COPY entrypoint.sh /entrypoint.sh
COPY fritzbox_exporter.sh /app/fritzbox_exporter.sh

RUN passwd -l root ; \
    addgroup -S -g 1000 fritzbox && \
    adduser -S -u 1000 -G fritzbox fritzbox && \
    chown -R fritzbox:fritzbox /app && \
    chmod 550 /entrypoint.sh && \
    chmod 750 /app/fritzbox_exporter.sh

WORKDIR /app
COPY --chown=fritzbox:fritzbox --from=builder /app /app

USER fritzbox

EXPOSE ${LISTEN_PORT}

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/app/fritzbox_exporter.sh"]
