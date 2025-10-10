# MTConnect Docker Agent for HEMsaw

A containerized MTConnect agent implementation that provides manufacturing equipment connectivity and data collection capabilities. This repository contains the official Docker container release of the MTConnect C++ Agent, customized for HEMsaw manufacturing systems.

## What This Does

This project packages the official [MTConnect Institute C++ Agent](https://github.com/mtconnect/cppagent) into a Docker container with custom styling and configuration for manufacturing data collection and monitoring. The MTConnect agent:

- **Collects Manufacturing Data**: Connects to manufacturing equipment (CNC machines, robots, sensors) via adapters
- **Provides REST API**: Exposes machine data through standardized MTConnect REST endpoints
- **Real-time Monitoring**: Streams live manufacturing data including machine status, tool conditions, and production metrics
- **Asset Management**: Manages manufacturing assets like cutting tools, fixtures, and pallets
- **MQTT Integration**: Publishes manufacturing data to MQTT brokers for integration with other systems
- **Web Interface**: Includes a custom Bootstrap-based web UI for visualizing machine data

## Key Features

- **MTConnect 2.6+ Compliance**: Latest version with support for DataSets, WebSockets, and enhanced validation
- **Multi-Protocol Support**: SHDR, MQTT, WebSocket adapters for equipment connectivity
- **Custom HEMsaw Styling**: Professional web interface with HEMsaw branding and logos
- **Production Ready**: Configured with proper logging, health checks, and restart policies
- **Multi-Architecture**: Supports both AMD64 and ARM64 platforms

## Architecture

The system consists of two main services:

1. **MTConnect Agent** (`mtc_agent`): Core agent that collects and serves manufacturing data
2. **MQTT Broker** (`mosquitto`): Message broker for real-time data distribution

## Quick Start

1. Create a `docker-compose.yml` file:

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

2. Set proper permissions for MQTT security files:
```bash
chmod 0700 ./mqtt/data/passwd
chmod 0700 ./mqtt/data/acl
```

3. Start the services:
```bash
docker-compose up --remove-orphans -d
```

4. Access the web interface at `http://localhost:5000`

## Docker Commands

### Build the Docker image:
```bash
docker build . -t "mtc_agent:latest"
```

### Run interactively for testing:
```bash
docker run --name agent --rm -it mtc_agent
```

### Build with docker-compose:
```bash
docker-compose build
```

### Start services:
```bash
docker-compose up --remove-orphans -d
```

### Stop services:
```bash
docker-compose down
```

### View logs:
```bash
docker-compose logs
```

## MTConnect Agent Usage

```bash
mtcagent [help|install|debug|run] [configuration_file]
   help           Prints this message
   install        Installs the service
   remove         Remove the service
   debug          Runs the agent on the command line with verbose logging
   run            Runs the agent on the command line
   config_file    The configuration file to load
                  Default: agent.cfg in current directory
```

## API Endpoints

Once running, the agent provides these REST endpoints:

- **Probe**: `http://localhost:5000/probe` - Device capabilities and structure
- **Current**: `http://localhost:5000/current` - Current state of all data items
- **Sample**: `http://localhost:5000/sample` - Historical data samples
- **Assets**: `http://localhost:5000/assets` - Manufacturing assets (tools, fixtures, etc.)

## Configuration

The agent uses configuration files mounted at `/mtconnect/config/`. Key configuration options include:

- **Device Models**: Define your manufacturing equipment in `Devices.xml`
- **Agent Settings**: Configure ports, logging, and adapters in `agent.cfg`
- **MQTT Settings**: Configure MQTT broker connection and topics
- **Validation**: Enable MTConnect document validation for data quality

## Asset Management

Push manufacturing assets (cutting tools, fixtures, etc.) using curl:

```bash
curl -d @TOOL_ID.xml 'http://localhost:5000/assets/TOOL_ID.1?device=YourDevice&type=CuttingTool'
```

## Data Integration

The agent supports multiple protocols for equipment integration:

- **SHDR**: MTConnect's Simple Streaming Protocol
- **MQTT**: Bidirectional MQTT communication
- **WebSockets**: Real-time web-based data streaming
- **File-based**: Configuration and static data import

## Custom Styling

This container includes custom HEMsaw branding and a responsive web interface built with Bootstrap. The styling provides:

- Professional dashboard for machine monitoring
- Tabbed interface for Probe, Current, and Sample data
- Mobile-responsive design
- HEMsaw logos and branding

## Version History

See [ChangeLog.md](ChangeLog.md) for detailed release notes. This container tracks the official MTConnect Institute agent releases with HEMsaw-specific customizations.

## Support

This is a production deployment container for HEMsaw manufacturing systems. For MTConnect protocol questions, refer to the [MTConnect Standard](https://www.mtconnect.org/). For container-specific issues, contact the HEMsaw development team.

## Docker Hub Deployment

This project uses automated GitHub Actions workflows to build and publish Docker images to Docker Hub under the `hemsaw/mtconnect` repository.

### Image Tags

- **`hemsaw/mtconnect:latest`** - Latest stable release
- **`hemsaw/mtconnect:experimental`** - Development builds from `develop` branch
- **`hemsaw/mtconnect:X.X.X.X`** - Specific version releases (e.g., `2.6.0.3`)
- **`hemsaw/mtconnect:X.X`** - Major.minor version (e.g., `2.6`)

### Deployment Workflows

#### 1. Experimental Builds (Development)

Pushes to the `develop` or `dev` branches automatically trigger experimental builds:

```bash
# Push changes to develop branch
git checkout develop
git add .
git commit -m "Add new feature"
git push origin develop
```

This creates: `hemsaw/mtconnect:experimental`

#### 2. Release Builds (Production)

Create and push a version tag to trigger a production release:

```bash
# Create and push a version tag
git checkout main
git tag 2.6.0.4
git push origin 2.6.0.4
```

This creates:
- `hemsaw/mtconnect:latest`
- `hemsaw/mtconnect:2.6.0.4`
- `hemsaw/mtconnect:2.6`

### Manual Docker Hub Push

For manual deployments or testing:

#### 1. Build the image locally:
```bash
docker build -t hemsaw/mtconnect:your-tag .
```

#### 2. Log in to Docker Hub:
```bash
docker login
# Enter your Docker Hub credentials
```

#### 3. Push to Docker Hub:
```bash
# Push specific tag
docker push hemsaw/mtconnect:your-tag

# Push multiple tags
docker tag hemsaw/mtconnect:your-tag hemsaw/mtconnect:latest
docker push hemsaw/mtconnect:latest
```

### Multi-Architecture Builds

The automated workflows build for multiple architectures:
- `linux/amd64` (Intel/AMD x64)
- `linux/arm64` (ARM64/Apple Silicon)

To build multi-architecture images manually:

```bash
# Set up buildx
docker buildx create --use

# Build and push multi-arch
docker buildx build --platform linux/amd64,linux/arm64 \
  -t hemsaw/mtconnect:your-tag --push .
```

### Repository Secrets

The following secrets must be configured in the GitHub repository:
- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token (not password)

### Version Numbering

Follow the MTConnect Agent version numbering scheme:
- **Format**: `MAJOR.MINOR.PATCH.BUILD` (e.g., `2.6.0.3`)
- **Major**: MTConnect standard version
- **Minor**: Agent feature release
- **Patch**: Bug fixes and minor updates
- **Build**: HEMsaw-specific builds

### Deployment Checklist

Before creating a release:

1. ✅ Update [ChangeLog.md](ChangeLog.md) with release notes
2. ✅ Test the build locally: `docker build . -t test-build`
3. ✅ Verify multi-architecture compatibility
4. ✅ Ensure all tests pass in GitHub Actions
5. ✅ Create and push the version tag
6. ✅ Monitor the GitHub Actions workflow
7. ✅ Verify the image is available on Docker Hub

## License

Based on the official MTConnect Institute C++ Agent. Custom styling and configurations are proprietary to HEMsaw.
