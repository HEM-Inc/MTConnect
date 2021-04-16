#!/bin/sh
### Ubuntu instance

# ---- Base Node ----
# This dockerfile defines the expected runtime environment before the project is installed
FROM ubuntu:latest AS ubuntu-base
# FROM debian:latest AS base
ENV DEBIAN_FRONTEND=noninteractive

# ---- Core ----
### Application compile
FROM ubuntu-base AS ubuntu-core

RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y \
	curl
RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y \
	g++ \
	make \
	cmake \
	git \
	&& git clone --recurse-submodules --progress https://github.com/mtconnect/cppagent.git --depth 1 /app_build/ \
	&& cd /app_build/ \
	&& git submodule init \
	&& git submodule update \
	&& cmake -G 'Unix Makefiles' . \
	&& make

# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM ubuntu-base AS ubuntu-release
LABEL author="skibum1869" description="Ubuntu based docker image for the latest Release Version of the MTConnect C++ Agent"
EXPOSE 5000:5000/tcp

WORKDIR /MTC_Agent/
# COPY <src> <dest>
COPY agent.cfg docker-entrypoint.sh /MTC_Agent/
COPY ./Devices/ /MTC_Agent/
COPY ./Assets/ /MTC_Agent/assets
COPY --from=ubuntu-core app_build/schemas/ /MTC_Agent/schemas
COPY --from=ubuntu-core app_build/simulator/ /MTC_Agent/simulator
COPY --from=ubuntu-core app_build/styles/ /MTC_Agent/styles
COPY --from=ubuntu-core app_build/agent/agent /MTC_Agent/

# Set permission on the folder
RUN chmod +x /MTC_Agent/agent && \
	chmod +x /MTC_Agent/docker-entrypoint.sh
ENTRYPOINT ["/bin/sh", "-x", "/MTC_Agent/docker-entrypoint.sh"]
### EOF
