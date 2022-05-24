#!/bin/sh
### Ubuntu Version


# ---- Ubuntu instance ----
FROM ubuntu:latest AS ubuntu-base
ENV DEBIAN_FRONTEND=noninteractive


# ---- Ubuntu make ----
FROM ubuntu-base AS ubuntu-core
RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y \
	build-essential python3.10 python3-pip git cmake make \
	&& python3.10 -m pip install conan

RUN git clone --recurse-submodules --progress https://github.com/mtconnect/cppagent.git --depth 1 /app_build/

RUN cd /app_build/ \
	&& conan export conan/mqtt_cpp/ \
	&& conan install . -if build --build=missing -pr conan/profiles/docker

RUN	cd /app_build/ \
	&& conan build . -bf build


# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM ubuntu-base AS ubuntu-release
LABEL author="skibum1869" description="Ubuntu based docker image for the latest Release Version of the MTConnect C++ Agent"
EXPOSE 5000:5000/tcp

WORKDIR /MTC_Agent/
COPY agent.cfg /MTC_Agent/
COPY ./mtconnect-devicefiles/Devices/ /MTC_Agent/devices/
COPY ./mtconnect-devicefiles/Assets/ /MTC_Agent/assets
COPY docker-entrypoint.sh /MTC_Agent/
COPY --from=ubuntu-core app_build/simulator/ /MTC_Agent/simulator
COPY --from=ubuntu-core app_build/schemas/ /MTC_Agent/schemas
COPY --from=ubuntu-core app_build/styles/ /MTC_Agent/styles
COPY --from=ubuntu-core app_build/build/bin/agent /MTC_Agent/agent
RUN chmod +x /MTC_Agent/agent && \
	chmod +x /MTC_Agent/docker-entrypoint.sh
ENTRYPOINT ["/bin/sh", "-x", "/MTC_Agent/docker-entrypoint.sh"]

### EOF
