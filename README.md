# MTConnect_Docker_Agent Project

This repo houses an Ubuntu Docker version of the MTConnect Cpp agent. This creates most of the needed items to build a local docker CPP agent using docker and docker-compose.
This project will mirror the log file to the local machine for full trace logging of the agent. This project was origionally forked from [RaymondCui21/MTConnect_Docker](https://github.com/RaymondCui21/MTConnect_Docker), The project has been seperated from the origional code set due to the amount of changes occuring. 

# Running from GitHub

To run the project clone a local instance of the repo.

``` bash
git clone https://github.com/skibum1869/MTConnect_Docker.git <name you want for the local repo>
```
Edit the agent.cfg to meet your requirements and add any devices you need to the folder. This has been tested using subfolders for devises and Assets.
To add asset definitions to the compiled project include the following line under the devises line see below.

```bash
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
```

To edit the instance settings use the docker-compose.yml file. 
```yml
version: '3.5'
services:
  agent:
    container_name: MTConnect_Agent
    build: .
    user: agent
    environment:
      - TZ=Etc/UTC
      - DEBIAN_FRONTEND=noninteractive
    ports: 
      - target: 5000
        published: 5001
        protocol: tcp
        mode: host
    entrypoint: "/bin/sh -x /etc/MTC_Agent/docker-entrypoint.sh"
    working_dir: "/etc/MTC_Agent/"
    restart: unless-stopped
    volumes:
      - './agent.cfg:/etc/MTC_Agent/agent.cfg'
      - './Devices/:/etc/MTC_Agent/devices'
      - './Assets/:/etc/MTC_Agent/assets'
      - './Ruby/:/etc/MTC_Agent/ruby'
```

# Running from DockerHub

Running a project form the prebuilt dockerhub libarary will speed up the build time.

To get the project running create a dockerfile, docker-entrypoint.sh, and a docker-compose.yml file similar to the ones below.

docker-compose.yml
```yml
version: '3.5'
services:
  agent:
    container_name: MTConnect_Agent
    image: skibum1869/mtconnect_ubuntu_agent:latest
    user: agent
    environment:
      - TZ=Etc/UTC
      - DEBIAN_FRONTEND=noninteractive
    ports: 
      - target: 5000
        published: 5001
        protocol: tcp
        mode: host
    entrypoint: "/bin/sh -x /etc/MTC_Agent/docker-entrypoint.sh"
    working_dir: "/etc/MTC_Agent/"
    restart: unless-stopped
    volumes:
      - './agent.cfg:/etc/MTC_Agent/agent.cfg'
      - './Devices/:/etc/MTC_Agent/devices'
      - './Assets/:/etc/MTC_Agent/assets'
      - './Ruby/:/etc/MTC_Agent/ruby'
```

# Core Docker and MTConnect Commands

## Build comand for docker to create a run time for latest MTC_Agent
```bash
docker build . -t "mtc_agent:latest"
```

## Run the docker image in interactive mode:
```bash
docker run --name agent --rm -it mtc_agent
```

## To build the docker-compose file:
``` bash
docker-compose build
````

## To run the docker-compose file detached and removing any orphaned containers:
``` bash
docker-compose up --remove-orphans -d
```

## To shutdown the docker-compose instance
``` bash
docker-compose down
```

## Access the logs
```bash
docker-compose logs
```

## MTConnect agent usage
```bash
agent [help|install|debug|run] [configuration_file]
   help           Prints this message
   install        Installs the service
   remove         Remove the service
   debug          Runs the agent on the command line with verbose logging
   run            Runs the agent on the command line
   config_file    The configuration file to load
                  Default: agent.cfg in current directory
````

When the agent is started without any arguments it is assumed it will be running as a service and will begin the service initialization sequence. The full path to the configuration file is stored in the registry in the following location:

```\\HKEY_LOCAL_MACHINE\SOFTWARE\MTConnect\MTConnect Agent\ConfigurationFile```

## Pushing Assets
To push the asset you need to be in the source folder of the asset.
```bash
curl -d @ZWEQ063C34HPII.xml 'http://example.com:5000/assets/ZWEQ063C34HPII.1?device=HEMsaw&type=CuttingTool'
```

Note: depending on the setup of your computer you may have to run the sudo command on a linux machine to get docker-compose to build or destroy a process. 