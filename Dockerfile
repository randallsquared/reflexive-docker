

FROM golang:alpine AS dev
ARG DEVELOPING_APP=app
ENV APP_NAME $DEVELOPING_APP
WORKDIR /go/src/$APP_NAME
RUN apk add git ca-certificates \
 && go get github.com/cespare/reflex
ENTRYPOINT exec /go/bin/reflex -v -g '*go' -s -- sh -c "go install -v ./... && /go/bin/$APP_NAME"

FROM dev AS build
ARG DEVELOPING_APP=app
ENV APP_NAME ${APP_NAME:-DEVELOPING_APP}
WORKDIR /go/src/$APP_NAME
COPY . .
RUN go get -d -v ./...
RUN go install -v ./...

FROM alpine:latest AS deploy
ARG DEVELOPING_APP=app
ENV APP_NAME $DEVELOPING_APP
RUN apk --no-cache add ca-certificates
COPY --from=build /go/bin/$APP_NAME /$APP_NAME
ENTRYPOINT exec /$APP_NAME 
EXPOSE 3000
