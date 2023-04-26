# syntax=docker/dockerfile:1

# Build Image
FROM golang:alpine3.15 AS builder
RUN go install github.com/foxromeo/fritzbox_exporter@latest \
    && mkdir /app \
    && mv /go/bin/fritzbox_exporter /app

WORKDIR /app

COPY metrics.json metrics-lua.json /app/

# Runtime Image
FROM alpine:3.15 as runtime-image

ARG REPO=foxromeo/fritzbox_exporter

LABEL org.opencontainers.image.source https://github.com/${REPO}
MAINTAINER docker@intrepid.de

ENV USERNAME username
ENV PASSWORD password
ENV GATEWAY_URL fritz.box
ENV LISTEN_PORT 9042
ENV LISTEN_ADDRESS 0.0.0.0:${LISTEN_PORT}

RUN passwd -l root ; \
    mkdir /app \
    && addgroup -S -g 1000 fritzbox \
    && adduser -S -u 1000 -G fritzbox fritzbox \
    && chown -R fritzbox:fritzbox /app

WORKDIR /app

COPY --chown=fritzbox:fritzbox --from=builder /app /app

EXPOSE ${LISTEN_PORT}

ENTRYPOINT [ "sh", "-c", "/app/fritzbox_exporter" ]
CMD [ "-username", "${USERNAME}", "-password", "${PASSWORD}", "-gateway-url", "${GATEWAY_URL}", "-listen-address", "${LISTEN_ADDRESS}" , "-use-tls" , "-allow-selfsigned"]
