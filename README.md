# MTConnect_Docker_Agent Project

This repo houses an Ubuntu Docker version of the MTConnect Cpp agent. This creates most of the needed items to build a local docker CPP agent using docker and docker-compose.
This project will mirror the log file to the local machine for full trace logging of the agent. This project was origionally forked from [RaymondCui21/MTConnect_Docker](https://github.com/RaymondCui21/MTConnect_Docker), The project has been seperated from the origional code set due to the amount of changes occuring. 

# Running from DockerHub

Running a project form the prebuilt dockerhub libarary will speed up the build time.

To get the project running create a docker-compose.yml file similar to the one below.

docker-compose.yml
```yml
version: '3.5'
services:
  mtc_agent:
    container_name: mtc_agent
    hostname: mtc_agent
    image: hemsaw/mtconnect:latest
    user: agent
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    volumes:
      - "/etc/mtconnect/config/:/mtconnect/config/"
      - "/etc/mtconnect/data/ruby/:/mtconnect/data/ruby/"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    ports: 
      - 5000:5000/tcp
    entrypoint: "/usr/bin/mtcagent run /mtconnect/config/agent.cfg"
    working_dir: "/home/agent"
    restart: unless-stopped
    depends_on:
      - mosquitto
      # - hivemq

  mosquitto:
    container_name: mosquitto
    hostname: mosquitto
    image: hemsaw/mosquitto:latest
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    volumes:
      - "/etc/mqtt/config/mosquitto.conf:/mosquitto/config/mosquitto.conf"
      - "/etc/mqtt/data/passwd:/mosquitto/data/passwd"
      - "/etc/mqtt/data/acl:/mosquitto/data/acl"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    ports:
      - 1883:1883/tcp
      - 9001:9001/tcp
    restart: unless-stopped

```

Note that the password and acl files need to have chmod 700 ran on them.
```
    chmod 0700 ./mqtt/data/passwd
    chmod 0700 ./mqtt/data/acl
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
mtcagent [help|install|debug|run] [configuration_file]
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