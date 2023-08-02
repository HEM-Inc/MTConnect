#!/bin/sh
### Ubuntu Version


# ---- Ubuntu instance ----
FROM ubuntu:22.04 AS ubuntu-base
ENV DEBIAN_FRONTEND=noninteractive


# ---- Ubuntu make ----
FROM ubuntu-base AS ubuntu-core
ENV PythonVersion=3.11
ENV PATH=$HOME/venv$PythonVersion/bin:$PATH

# set some variables
ENV PATH=$HOME/venv3.9/bin:$PATH
ENV CONAN_PROFILE=conan/profiles/docker
ENV WITH_RUBY=True
ENV WITH_TESTS=False

# limit cpus so don't run out of memory on local machine
# symptom: get error - "c++: fatal error: Killed signal terminated program cc1plus"
# can turn off if building in cloud
ENV CONAN_CPU_COUNT=1

RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y \
	build-essential git cmake make rake \
	autoconf automake \
	python$PythonVersion python3-pip \
	python$PythonVersion-venv \
	&& python$PythonVersion -m pip install conan \
	&& echo 'export PATH=$HOME/.local/bin:$PATH' >> .bashrc

RUN git clone --recurse-submodules --progress https://github.com/mtconnect/cppagent.git --depth 1 /app_build/

RUN cd /app_build/ \
	&& conan export conan/mqtt_cpp \
	&& conan export conan/mruby \
	&& conan build . \
	--profile:build=$CONAN_PROFILE \
	-o build_tests=$WITH_TESTS \
	-o run_tests=$WITH_TESTS \
	-o with_ruby=$WITH_RUBY \
	--build=missing


# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM ubuntu-base AS ubuntu-release
LABEL author="skibum1869" description="Ubuntu based docker image for the latest Release Version of the MTConnect C++ Agent"
EXPOSE 5000:5000/tcp
EXPOSE 1883:1883/tcp

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
COPY --chown=agent:agent --from=ubuntu-core app_build/build/bin/agent /usr/local/bin/

# copy custom data files and folders to /etc/MTC_Agent/*
COPY --chown=agent:agent agent.cfg /etc/MTC_Agent/
COPY --chown=agent:agent ./Devices/ /etc/MTC_Agent/devices/
COPY --chown=agent:agent ./Assets/ /etc/MTC_Agent/assets
Copy --chown=agent:agent ./Ruby/ /etc/MTC_Agent/ruby

# copy data from the cppagent repo to /etc/MTC_Agent/*
COPY --chown=agent:agent --from=ubuntu-core app_build/simulator/ /etc/MTC_Agent/simulator
COPY --chown=agent:agent --from=ubuntu-core app_build/schemas/ /etc/MTC_Agent/schemas
COPY --chown=agent:agent --from=ubuntu-core app_build/styles/ /etc/MTC_Agent/styles

RUN chmod +x /usr/local/bin/agent
ENTRYPOINT ["agent run agent.cfg"]

### EOF
