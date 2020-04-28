FROM docker.io/library/golang:1.14.2 as builder
ADD . /go/src/github.com/cilium/cilium
WORKDIR /go/src/github.com/cilium/cilium/hubble-relay
RUN make

FROM docker.io/library/alpine:3.11 as certs
RUN apk --update add ca-certificates

FROM docker.io/library/golang:1.14.2-alpine3.11 as gops
RUN apk add --no-cache binutils git \
 && go get -d github.com/google/gops \
 && cd /go/src/github.com/google/gops \
 && git checkout -b v0.3.6 v0.3.6 \
 && go install \
 && strip /go/bin/gops

FROM scratch
LABEL maintainer="maintainer@cilium.io"
COPY --from=builder /go/src/github.com/cilium/cilium/hubble-relay/hubble-relay /usr/bin/hubble-relay
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
# cilium-sysdump expects gops to be installed in /bin
COPY --from=gops /go/bin/gops /bin
ENTRYPOINT ["/usr/bin/hubble-relay"]
CMD ["serve"]
