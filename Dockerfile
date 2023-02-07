#!/bin/sh
### Ubuntu Version


# ---- Ubuntu instance ----
FROM ubuntu:23.04 AS ubuntu-base
ENV DEBIAN_FRONTEND=noninteractive


# ---- Ubuntu make ----
FROM ubuntu-base AS ubuntu-core
ENV PythonVersion=3.10
ENV PATH=$HOME/venv$PythonVersion/bin:$PATH

RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y \
	build-essential python$PythonVersion python3-pip git cmake make rake\
	&& python$PythonVersion -m pip install conan

RUN git clone --recurse-submodules --progress https://github.com/mtconnect/cppagent.git --depth 1 /app_build/

RUN cd /app_build/ \
	&& conan export conan/mqtt_cpp/ \
	&& conan export conan/mruby/ 
	
RUN cd /app_build/ \
	&& conan install . -if build --build=missing \
	-pr conan/profiles/docker \
	-o run_tests=False \
	-o with_ruby=True

RUN	cd /app_build/ \
	&& conan build . -bf build


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
