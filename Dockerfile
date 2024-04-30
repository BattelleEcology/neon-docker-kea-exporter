FROM alpine:3.19.1

RUN addgroup -g 101 kea &&\
    adduser kea -G kea -S &&\
    apk add --no-cache python3 py3-pip git &&\
    mkdir /usr/app &&\
    chown kea:kea /usr/app

USER kea
RUN python3 -mvenv /usr/app
ENV PATH="/usr/app/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN pip install --upgrade pip &&\
    pip install kea-exporter==0.5.1


ENTRYPOINT ["kea-exporter"]
