#!/bin/sh
### Ubuntu LTS Version

# ---- Ubuntu instance ----
FROM ubuntu:22.04 AS ubuntu-base
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]


# ---- Ubuntu make ----
FROM ubuntu-base AS ubuntu-core

ARG CONAN_CPU_COUNT=2
ARG WITH_RUBY='True'
ARG WITH_CPACK='True'
ARG CPACK_DESTINANTION="/root/agent" 
ARG CPACK_NAME='mtcagent_dist'
ARG WITH_TESTS='False'
ARG WITH_TESTS_ARG=argument
ARG SHARED='False'

ENV PythonVersion=3.11
ENV PATH=$HOME/venv$PythonVersion/bin:$PATH
ENV CONAN_PROFILE='conan/profiles/docker'

RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y \
	    autoconf \
	    automake \
	    build-essential \
	    cmake \
	    git \
	    python$PythonVersion \
	    python3-pip \
	    python$PythonVersion-venv \
	    rake \
	    ruby \
	&& rm -rf /var/lib/apt/lists/*

RUN python$PythonVersion -m venv temp-venv \
	&& source temp-venv/bin/activate \
	&& python -m pip install conan -v 'conan==2.0.9'

RUN git clone --recurse-submodules --progress https://github.com/mtconnect/cppagent.git --depth 1 /app_build/

WORKDIR /app_build/

RUN conan export conan/mqtt_cpp/ \
	&& conan export conan/mruby/ 
	
RUN if [ -z "$WITH_TESTS" ] || [ "$WITH_TESTS" = "false" ] || [ "$WITH_TESTS" = "False" ]; then \
	    WITH_TESTS_ARG="--test-folder="; \
	else \
	    WITH_TESTS_ARG=""; \
	fi \
	&& conan profile detect \
	&& conan create . \
	    --build=missing \
	    -c "tools.build:jobs=$CONAN_CPU_COUNT" \
	    -o agent_prefix=mtc \
	    -o "with_ruby=$WITH_RUBY" \
	    -o "cpack=$WITH_CPACK" \
	    -o "cpack_destination=$CPACK_DESTINANTION" \
	    -o "cpack_name=$CPACK_NAME" \
	    -o cpack_generator=TGZ \
	    -o "shared=$SHARED" \
	    -pr "conan/profiles/docker" \
	    ${WITH_TESTS_ARG}


# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM ubuntu-base AS ubuntu-release
LABEL author="HEMsaw" description="Ubuntu based docker image for the latest Release Version of the MTConnect C++ Agent"
EXPOSE 5000:5000/tcp
EXPOSE 1883:1883/tcp

USER root

RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y \
	ruby mosquitto mosquitto-clients

RUN touch /etc/mosquitto/passwd \
	&& mosquitto_passwd -b /etc/mosquitto/passwd mtconnect mtconnect

# copy mosquitto files from mqtt folder to /etc/mosquitto/*
COPY ./mqtt/acl /etc/mosquitto/acl
COPY ./mqtt/mosquitto.conf /etc/mosquitto/conf.d/


# change to a new non-root user for better security.
# this also adds the user to a group with the same name.
# --create-home creates a home folder, ie /home/<username>
RUN useradd --create-home agent
USER agent
WORKDIR /etc/MTC_Agent/

# install agent executable
COPY --chown=agent:agent --from=ubuntu-core /root/agent/mtcagent_dist.tar.gz /etc/MTC_Agent/

# Extract the data
RUN  tar -xf /etc/MTC_Agent/mtcagent_dist.tar.gz -C /etc/MTC_Agent/

USER root
RUN set -x \
	&& cp /etc/MTC_Agent/mtcagent_dist/bin/* /usr/bin \
	&& cp /etc/MTC_Agent/mtcagent_dist/lib/* /usr/lib \
	&& mkdir -p /etc/mtconnect/config \
	          /etc/mtconnect/data \
	          /etc/mtconnect/log \
	&& chown -R agent:agent /mtconnect \
	&& rm -r /etc/MTC_Agent

WORKDIR /etc/mtconnect/

# copy custom data files and folders to /etc/MTC_Agent/*
USER agent
COPY --chown=agent:agent agent.cfg /etc/mtconnect/data/
COPY --chown=agent:agent ./Devices/ /etc/mtconnect/data/devices/
COPY --chown=agent:agent ./Assets/ /etc/mtconnect/data/assets
Copy --chown=agent:agent ./Ruby/ /etc/mtconnect/data/ruby
COPY --chown=agent:agent ./Styles/ /etc/mtconnect/data/styles

# copy data from the cppagent repo to /etc/mtconnect/*
COPY --chown=agent:agent --from=ubuntu-core app_build/schemas/ /etc/mtconnect/data/schemas

VOLUME ["/etc/mtconnect/config", "/etc/mtconnect/log", "/etc/mtconnect/data"]
RUN chmod +x /usr/local/bin/agent
ENTRYPOINT ["/usr/bin/mtcagent run /etc/mtconnect/data/agent.cfg"]

### EOF
