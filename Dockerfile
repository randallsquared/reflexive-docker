

FROM golang:alpine AS dev
ARG APP_NAME=app
WORKDIR /go/src/$APP_NAME
RUN apk add git ca-certificates \
 && go get github.com/cespare/reflex
ENV APP_NAME $APP_NAME
ENTRYPOINT exec /go/bin/reflex -v -g '*go' -s -- sh -c "go install -v ./... && /go/bin/$APP_NAME"

FROM dev AS build
ARG APP_NAME=app
WORKDIR /go/src/$APP_NAME
COPY . .
RUN go get -d -v ./...
RUN go install -v ./...

FROM alpine:latest AS deploy
RUN apk --no-cache add ca-certificates
EXPOSE 3000
ARG APP_NAME=app
ENV APP_NAME $APP_NAME
COPY --from=build /go/bin/$APP_NAME /$APP_NAME
ENTRYPOINT exec /$APP_NAME 
