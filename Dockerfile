#!/bin/sh
# ---- Base Node ----
# This dockerfile defines the expected runtime environment before the project is installed
FROM ubuntu:latest AS base
# FROM debian:latest AS base

# ---- Dependencies ----
### Be sure to install any runtime dependencies
FROM base AS dependencies

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y \
	curl \
	libxml2-dev \
	libcppunit-dev \
	build-essential

# ---- Core ----
### Application compile
FROM dependencies AS core

RUN apt-get update \
	&& apt-get install -y \
	apt-utils \
	make \
	cmake \
	git \
	&& git clone --recurse-submodules https://github.com/mtconnect/cppagent.git /app_build/ \
	&& cd /app_build/ \
	&& git submodule init \
	&& git submodule update \
	&& cmake -G 'Unix Makefiles' . \
	&& make

# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM dependencies AS release
LABEL author="skibum1869"
EXPOSE 5000:5000/tcp

# RUN mkdir /MTC_Agent/ 
# COPY <src> <dest>
COPY docker-entrypoint.sh /MTC_Agent/
COPY agent.cfg /MTC_Agent/
COPY ./Devices/ /MTC_Agent/
COPY --from=core app_build/schemas/ /MTC_Agent/schemas
COPY --from=core app_build/simulator/ /MTC_Agent/simulator
COPY --from=core app_build/styles/ /MTC_Agent/style
COPY --from=core app_build/agent/agent /MTC_Agent/agent

# Set permission on the folder
RUN ["chmod", "o+x", "/MTC_Agent/"]
### EOF
