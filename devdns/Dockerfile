FROM alpine:3 AS builder
WORKDIR /root
RUN apk add --no-cache git go && \
    git clone https://github.com/robbiev/devdns.git && \
    cd /root/devdns && \
    go mod init mbo.dev/devdns && \
    go mod tidy && \
    go build -o /usr/local/bin/devdns

FROM alpine:3
COPY --from=builder /usr/local/bin/devdns /usr/local/bin/devdns
RUN apk add --no-cache bind-tools
ENTRYPOINT ["/usr/local/bin/devdns"]
CMD ["-addr=0.0.0.0:5300"]
HEALTHCHECK --interval=5s --timeout=1s --start-period=2s --retries=3 \
  CMD dig @127.0.0.1 -p5300 example.com || exit 1
EXPOSE 5300