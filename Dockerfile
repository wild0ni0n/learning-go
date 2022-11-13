FROM golang:1.19.3-buster as build
WORKDIR /go/src/app
ADD . /go/src/app
ENV GO111MODULE=on

RUN apt update \
    && go get -u github.com/ramya-rao-a/go-outline \
    && go install golang.org/x/tools/gopls@latest

RUN go build -o /go/bin/app main.go


FROM alpine:3.16 as prod
COPY --from=build /go/bin/app /

CMD ["/app"]