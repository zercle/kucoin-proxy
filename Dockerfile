# syntax=docker/dockerfile:1
# Builder from mikekonan/exchange-proxy
FROM golang AS builder
WORKDIR /src/app
RUN 
RUN git clone --depth 1 --branch $(curl --silent "https://api.github.com/repos/mikekonan/exchange-proxy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') https://github.com/mikekonan/exchange-proxy.git && cd exchange-proxy && go get github.com/mailru/easyjson && go install github.com/mailru/easyjson/...@latest && go mod tidy && make generate && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /src/app/dist/kucoin-proxy .

# Container from builder
FROM debian:stable-slim
LABEL maintainer="Kawin Viriyaprasopsook <kawin.vir@zercle.tech>"

ARG	timezone=Asia/Bangkok

ENV	LANG C.UTF-8
ENV	LC_ALL C.UTF-8
ENV	TZ $timezone

# Update OS
RUN	apt update && apt -y full-upgrade \
  && apt -y install locales tzdata net-tools bash-completion ca-certificates

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
