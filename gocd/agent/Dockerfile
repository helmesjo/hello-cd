FROM gocd/gocd-agent-debian-8:v17.11.0

LABEL maintainer "Fred Helmesjö <helmesjo@live.com>"

ENV DOCKER_VERSION 17.12.0

RUN     apt-get update && apt-get install --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common && \
        # Add Docker-repo
        curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && \
        apt-key fingerprint 0EBFCD88 && \
        add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
            $(lsb_release -cs) \
            stable" && \
        apt-cache madison docker-ce && \
        # Update package list again
        apt-get update && apt-get install --no-install-recommends -y \
            docker-ce=$DOCKER_VERSION~ce-0~debian && \
        # Clean up
        apt-get clean -y && \
        apt-get autoclean -y && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/*

COPY ./gocd/agent/custom-entrypoint.sh .

ENTRYPOINT ["/custom-entrypoint.sh"]
