FROM alpine:3.7

LABEL maintainer "Fred Helmesjö <helmesjo@live.com>"

# See: http://docs.conan.io/en/latest/server.html

RUN apk update &&\
    apk add py2-pip=9.0.1-r1 &&\
    pip install --no-cache-dir conan==0.30.2

RUN adduser -S conan -h /var/lib/conan -s /bin/sh

EXPOSE 9300

COPY ./conan/server/entrypoint.sh /entrypoint.sh
CMD ["/bin/sh", "/entrypoint.sh"]