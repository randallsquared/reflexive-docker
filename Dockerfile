
FROM golang:alpine AS dev
RUN apk add git ca-certificates && go get github.com/cespare/reflex
WORKDIR /go/src/app
CMD /go/bin/reflex -v -r '\.go$' -s -- sh -c "go install -v ./... && /go/bin/app"


# only useful to build the app we'll need for the next stage
FROM dev AS build_stage
WORKDIR /go/src/app
COPY . .
RUN go get -d -v ./...
RUN go install -v ./...


# docker build -t ms-do-things --target deploy --build-arg APP_NAME=ms-do-things .
FROM alpine:latest AS deploy
EXPOSE 3000
RUN apk --no-cache add ca-certificates

ARG APP_NAME=app
COPY --from=build_stage /go/bin/app /usr/local/bin/$APP_NAME

ENV APP_NAME $APP_NAME
ENTRYPOINT exec /usr/local/bin/$APP_NAME 
