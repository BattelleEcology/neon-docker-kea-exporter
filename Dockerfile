FROM alpine:3.18.5

RUN addgroup -g 101 kea \
    && adduser kea -G kea -S \
    && apk add --no-cache python3 py3-pip git \
    && python3 -mpip install --upgrade pip \
    && python3 -mpip install kea-exporter==0.5.1

USER kea

ENTRYPOINT ["kea-exporter"]
