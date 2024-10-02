# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
For build level release notes see https://github.com/mtconnect/cppagent/

## [Unreleased]

## [2.4.0.2] - 2024/10/02 - Max Harris

### Fixed

- Device.xml dynamic loading where the file has not changed. It was causing a crash when a current was run.

## [2.4.0.1] - 2024/08/09 - Max Harris

### Added

- Added json schem for configuration files
- Added xpath to the `Mqtt2Service` to subselect what components and data items will be published.

### Fixed

- - Fixed documentation for the configuration in the readme.

## [2.3.0.16] - 2024/07/09 - Max Harris

### Added

- Added `MqttRetain` and `MqttQOS` options for the MqttSink2. See docs.

## [2.3.0.15] - 2024/07/02 - Max Harris

### Added

- `MqttRetain` and `MqttQOS` are now settable options in the configuration of Mqtt 2 Service (the latest).
- `MqttQOS` options are: at_least_once, at_most_once, and exactly_once. The default is at_least_once
- `MqttRetain` can be true or false.

### Fixed

- UUID device changes were not being pushed through to the Mqtt Service and were not reposting. This required redoing the UUID and device changed handling to better support changes in pub/sub services other than REST.

## [2.3.0.14] - 2024/06/20 - Max Harris

### Fixed

- Fixed issues with MQTT disconnect and options passing to the pipeline
- Fixed MQTT Host and Port in the URL

## [2.3.0.12] - 2024/06/19 - Max Harris

### Fixed

- Updated MTConnect schema files with fixes for condition ID.

## [2.3.0.11] - 2024/06/17 - Max Harris

### Fixed

- Fixed bug where observations were not set to unavailable when MQTT Source would disconnect from broker
- Fixed bug with topics being incorrectly set when parsing the path

## [2.3.0.10] - 2024/06/06 - Max Harris

### Fixed

- Fixes some unhandled exceptions relation to numeric conversions in the pipeline. @wsobel
- Fixes Windows Services with a configuration file other than agent.cfg @wsobel

## [2.3.0.9] - 2024/05/13 - Max Harris

### Changed

- The MQTT2 Sink now includes the MTConnectAssets and Header when publishing assets
- The MTConnect REST API correctly honors pretty parameter when publishing assets.
- MQTT2 Sink now publishes an empty Sample topic before data has come in to have the topic present for subscription.

## [2.3.0.8] - 2024/05/07 - Max Harris

### Added

- Support for initial value that sets the data item's observation whenever the device becomes available.

## [2.3.0.7] - 2024/04/16 - Max Harris

### Fixed

- Fixed port in url for the MQTT service @wsobel

## [2.3.0.6] - 2024/04/13 - Max Harris

### Fixed

- Fixed issues with respect to changing UUIDs @wsobel

## [2.3.0.4] - 2024/03/21 - Max Harris

### Changed

- Approved the release of the 2.3.0.4 agent.

### Fixed

- Fixed `* uuid` command handling in agent not as expected by @wsobel
- Reduced log level for config file search to debug @wsobel
- Crash when editing DataItem in Devices.xml file by @mnoomnoo

## [2.3.0.3] - 2024/03/13 - Max Harris

### Changed

- Approved the release of the 2.3.0.3 agent.

### Added

- Added deviceModel and uuid documentation for SHDR protocol.
- AgentConfiguration::monitorThread message reports wrong number of seconds
- Added websockets support to MQTT Adapter by @wsobel
- Websockets support added to common MQTT client. May add to MQTT sink as well.
- Configure using MqttWs = true in agent.cfg for the MQTT adapter.

### Fixed

- Fix for issue 420 by @mnoomnoo

## [2.3.0.2] - 2024/02/19 - Max Harris

### Changed

- Approved the release of the 2.3.0.2 agent.

### Added

- New condition Id for Condition observations and associated activations
- Added Sender configuration setting Sender = ... to override header
- README updates for MQTT, SHDR, and other fixes
- 2.3 schema files

## [2.2.0.17] - 2024/01/30 - Max Harris

### Changed

- Approved the release of the 2.2.0.17 mtconnect instutite version.

## [2.2.0.16] - 2023/11/28 - Max Harris

### Changed

- Approved the release of the 2.2.0.16 mtconnect instutite version.

## [2.2.0.14] - 2023/11/28 - Max Harris

### Changed

- Approved the release of the 2.2.0.14 mtconnect instutite version.

## Old Logs

- 2023/01/05 = Release version 2.1.0 using 2.1.0 agent
- 2022/05/31 = Release version 2.0.0 using 2.0.0 agent
- 2022/04/18 = Release version 1.8.0.3 using 1.8.0.3 agent
- 2021/12/30 = Release version 1.8.0.2 using 1.8.0.2 agent
- 2021/10/05 = Release version 1.7.0.7 using 1.7.0.7 agent
- 2021/09/29 = Release version 1.7.0.6 using 1.7.0.6 agent
- 2021/09/16 = Release version 1.7.0.5 using 1.7.0.5 agent
- 2021/09/16 = Release version 1.7.0.4 using 1.7.0.4 agent
- 2021/08/11 = Release version 1.7.0.3 using 1.7.0.3 agent
- 2021/04/16 = Release version 1.7.0.2 using 1.7.0.2 agent
- 2020/08/14 = Release Version 1.6.0 using 1.6.0.7 agent
- 2020/04/27 = Release Version 1.5.0 using 1.5.0.14 agent

## Types of changes

### `Added` for new features.

### `Changed` for changes in existing functionality.

### `Deprecated` for soon-to-be removed features.

### `Removed` for now removed features.

### `Fixed` for any bug fixes.

### `Security` in case of vulnerabilities.
