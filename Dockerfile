FROM golang:1.18.1-stretch

RUN go mod download github.com/coredns/coredns@v1.9.1

WORKDIR $GOPATH/pkg/mod/github.com/coredns/coredns@v1.9.1
RUN go mod download

RUN sed -i '70 i docker:github.com/blinkinglight/coredns-dockerdiscovery' plugin.cfg
ENV CGO_ENABLED=0
RUN go generate coredns.go
RUN go get -u github.com/blinkinglight/coredns-dockerdiscovery@v0.0.2
RUN go build -mod=mod -o=/usr/local/bin/coredns

FROM alpine:3.13.5

RUN apk --no-cache add ca-certificates
COPY --from=0 /usr/local/bin/coredns /usr/local/bin/coredns

ENTRYPOINT ["/usr/local/bin/coredns"]
