FROM alpine:3.19

RUN apk --update add socat

ENTRYPOINT [ "socatt" ]
