FROM gocd/gocd-server:v17.8.0

LABEL maintainer Fred Helmesjö <helmesjo@live.com>

COPY ./gocd/server/custom-entrypoint.sh .

ENTRYPOINT ["/custom-entrypoint.sh"]