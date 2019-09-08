# MTConnect Version 1.4

FROM ubuntu:18.04

MAINTAINER raymond.cui2015@gmail.com

# Download, validate, and expand Apache NiFi binary.
RUN apt-get update \
    && apt-get install -y libxml2 libxml2-dev cmake git libcppunit-dev build-essential screen ruby curl \
    && mkdir -p ~/agent/build \ 
    && cd ~/agent \
    && git clone https://github.com/mtconnect/cppagent.git \
    && cd cppagent \
    && git submodule init \
    && git submodule update \
    && cd .. \
    && cd build \ 
    && cmake -D CMAKE_BUILD_TYPE=Release ../cppagent/ \
    && make \ 
    && cp agent/agent /usr/local/bin \
    && mkdir -p /etc/mtconnect/agent /etc/mtconnect/adapter \
    && cd ~/agent/cppagent \
    && cp -r styles schemas simulator/VMC-3Axis.xml /etc/mtconnect/agent \
    && cp simulator/VMC-3Axis-Log.txt simulator/run_scenario.rb /etc/mtconnect/adapter

# Web HTTP(s) & Socket Site-to-Site Ports
EXPOSE 5000 7878

