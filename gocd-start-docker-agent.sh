docker run  -d -v //var/run/docker.sock://var/run/docker.sock \
            -e GO_SERVER_URL=https://172.19.16.1:8154/go \
            gocd-agent

            replace ip above (localhost doesn't work)