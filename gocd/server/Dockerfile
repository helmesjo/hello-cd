FROM gocd/gocd-server:v18.7.0

LABEL maintainer "Fred Helmesjö <helmesjo@live.com>"

COPY ./gocd/server/custom-entrypoint.sh .

ENTRYPOINT ["/custom-entrypoint.sh"]