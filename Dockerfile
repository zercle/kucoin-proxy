# syntax=docker/dockerfile:1
# Builder from mikekonan/exchange-proxy
FROM golang AS builder
ARG LATEST_TAG=v1.2.6
ENV BUILD_TAG $LATEST_TAG
WORKDIR /src/app
RUN git clone --depth 1 --branch ${BUILD_TAG} https://github.com/mikekonan/exchange-proxy.git && cd exchange-proxy && go get github.com/mailru/easyjson && go install github.com/mailru/easyjson/...@latest && go mod tidy && make generate && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /src/app/dist/kucoin-proxy .

# Container from builder
FROM alpine
LABEL maintainer="Kawin Viriyaprasopsook <kawin.vir@zercle.tech>"

ARG	timezone=Asia/Bangkok

ENV	LANG en_US.UTF-8
ENV	LC_ALL en_US.UTF-8
ENV	TZ $timezone

# Add config repositories
RUN	echo 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/main' > /etc/apk/repositories \
  && echo 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/community' >> /repositories \
  && mkdir /run/openrc \
  && touch /run/openrc/softlevel

# Update OS
RUN	apk update && apk upgrade \
  && apk add --no-cache \
  openrc \
  tzdata \
  bash \
  bash-completion \
  ca-certificates

# Change locale
RUN echo $timezone > /etc/timezone \
  && cp /usr/share/zoneinfo/$timezone /etc/localtime

# Create app dir
RUN mkdir -p /app
WORKDIR /app
COPY --from=builder /src/app/dist/kucoin-proxy /app/
RUN chmod +x /app/kucoin-proxy && ln -sf /app/kucoin-proxy /usr/local/bin/kucoin-proxy

EXPOSE 8080

# startup script
ENTRYPOINT ["kucoin-proxy"]
# fallback
CMD ["kucoin-proxy"]
