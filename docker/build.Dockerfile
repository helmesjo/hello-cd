FROM debian:9.1

# The full build & testing environment
RUN     apt-get update && \
        apt-get install --no-install-recommends -y \ 
        software-properties-common && \
        # Install from default
        apt-get install --no-install-recommends -y \
        automake=1:1.15-6 \
        autotools-dev=20161112.1 \
        cppcheck=1.76.1-1 \
        gcc=4:6.3.0-4 \
        g++=4:6.3.0-4 \
        g++-multilib=4:6.3.0-4 \
        lcov=1.13-1 \
        make=4.1-9.1 \
        python-pip=9.0.1-2 \
        python-pygments=2.2.0+dfsg-1 \
        python-setuptools=33.1.1-1 \
        ruby=1:2.3.3 && \
        # Install from buster main
        add-apt-repository "deb http://httpredir.debian.org/debian buster main" && \
        apt-get update && \
        apt-get -t buster install --no-install-recommends -y \
        # No specific versions. Available versions may change from 'buster' (is in testing)
        cmake \
        git && \
        # Gem
        gem install cucumber --version 2.4.0 && \
        # pip
        pip install wheel && \
        pip install cppcheck-junit==1.4.0 && \
        pip install conan==1.0.2 && \
        # Clean up
        apt-get clean -y && \
        apt-get autoclean -y && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/*

RUN     git config --global user.name "docker_bot" && \
        git config --global user.email "<>"

WORKDIR /source