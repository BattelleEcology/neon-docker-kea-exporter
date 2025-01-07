FROM alpine:3.21.1

RUN addgroup -g 101 kea &&\
    adduser kea -G kea -S &&\
    apk add --no-cache python3 py3-pip git &&\
    mkdir /usr/app &&\
    chown kea:kea /usr/app

COPY requirements.txt /usr/app/

USER kea
RUN python3 -mvenv /usr/app
ENV PATH="/usr/app/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN pip install --upgrade pip &&\
    pip install -r /usr/app/requirements.txt


ENTRYPOINT ["kea-exporter"]
