###############
# Build Image
FROM golang:1.19-alpine3.17 AS builder

ARG RELEASE_VERSION
#ARG RELEASE_VERSION=master
ENV RELEASE_VERSION $RELEASE_VERSION

RUN go clean -cache -modcache ; \
    go install github.com/foxromeo/fritzbox_exporter@${RELEASE_VERSION} && \
    mkdir /app && \
    mv /go/bin/fritzbox_exporter /app

WORKDIR /app

COPY metrics.json metrics-lua.json /app/

###############
# Runtime Image
FROM alpine:3.17 as runtime-image

ARG REPO=foxromeo/fritzbox_exporter

LABEL org.opencontainers.image.source https://github.com/${REPO}
MAINTAINER docker@intrepid.de

RUN passwd -l root ; \
    mkdir /app \
    && addgroup -S -g 1000 fritzbox \
    && adduser -S -u 1000 -G fritzbox fritzbox \
    && chown -R fritzbox:fritzbox /app

WORKDIR /app

COPY --chown=fritzbox:fritzbox --from=builder /app /app

EXPOSE ${LISTEN_PORT}

ENTRYPOINT [ "sh", "-c", "/app/fritzbox_exporter" ]
CMD [ "-username", "${USERNAME}", "-password", "${PASSWORD}", "-gateway-url", "${GATEWAY_URL}", "-gateway-luaurl", "${GATEWAY_LUA}" ,"-listen-address", "${LISTEN_ADDRESS}", "${ADDITIONAL_PARAMETER}"]
