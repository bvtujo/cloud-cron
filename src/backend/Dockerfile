FROM golang:1.18.4-alpine3.16

RUN apk add git

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
COPY *.go ./

ENV GOPROXY=direct
RUN go build -o /kv

EXPOSE 80

CMD ["/kv"]