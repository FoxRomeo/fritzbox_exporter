# Fritz!Box Upnp statistics exporter for prometheus

<a href="https://hub.docker.com/r/intrepidde/fritzbox_exporter"><img src="https://img.shields.io/docker/pulls/intrepidde/fritzbox_exporter.svg?style=plastic&logo=appveyor" alt="Docker pulls"/></a><br>
[![ci](https://github.com/FoxRomeo/fritzbox_exporter/actions/workflows/main.yml/badge.svg)](https://github.com/FoxRomeo/fritzbox_exporter/actions/workflows/main.yml)

forked from micxer/fritzbox_exporter
primary focus of this fork is to build (and continously update/rebuild) the docker container for ARM32v6 (all RaspberryPis), ARM32v7 (newer RPis), ARM64 and x86/AMD64

-----------

This exporter exports some variables from an 
[AVM Fritzbox](http://avm.de/produkte/fritzbox/)
to prometheus.

This exporter is tested with a Fritzbox 7590 software version 07.12, 07.20, 07.21 and 07.25.

The goal of the fork is:
  - [x] allow passing of username / password using evironment variable
  - [x] use https instead of http for communitcation with fritz.box
  - [x] move config of metrics to be exported to config file rather then code
  - [x] add config for additional metrics to collect (especially from TR-064 API)
  - [x] create a grafana dashboard consuming the additional metrics
  - [x] collect metrics from lua APIs not available in UPNP APIs
 
Other changes:
  - replaced digest authentication code with own implementation
  - improved error messages
  - test mode prints details about all SOAP Actions and their parameters
  - collect option to directly test collection of results
  - additional metrics to collect details about connected hosts and DECT devices
  - support to use results like hostname or MAC address as labels to metrics
  - support for metrics from lua APIs (e.g. CPU temperature, utilization, ...)
 

## Building

    go install github.com/foxromeo/fritzbox_exporter@latest

## Running

In the configuration of the Fritzbox the option "Statusinformationen über UPnP übertragen" in the dialog "Heimnetz >
Heimnetzübersicht > Netzwerkeinstellungen" has to be enabled.

### Using docker

First you have to build the container: `docker build --tag fritzbox-prometheus-exporter:latest .`
or use `docker pull intrepidde/fritzbox_exporter:latest`

Then start the container:

```bash
$ docker run -e 'USERNAME=your_fritzbox_username' \
    -e 'PASSWORD=your_fritzbox_password' \
    -e 'GATEWAY="fritz.box"' \
    -e 'LISTEN_PORT="9042"' \
    intrepidde/fritzbox_exporter:latest
```

I've you're getting `no such host` issues, define your FritzBox as DNS server for your docker container like this:

```bash
$ docker run --dns YOUR_FRITZBOX_IP \
    -e 'USERNAME=your_fritzbox_username' \
    -e 'PASSWORD=your_fritzbox_password' \
    -e 'GATEWAY="fritz.box"' \
    -e 'LISTEN_PORT="9042"' \
    intrepidde/fritzbox_exporter:latest
```

Additional options:
  METRICS="metrics.json"
  sets -metrics-file="metrics.json": The JSON file with the metric definitions.

  LUA_METRICS="metrics-lua.json"
  sets -lua-metrics-file="metrics-lua.json": The JSON file with the lua metric definitions.

  NOLUA="1"
  sets -nolua=true: disable collecting lua metrics
  unset or set to 0 = false/default

  VERIFYTLS="1"
  sets -verifyTls=true: Verify the tls connection when connecting to the FRITZ!Box
  unset or set to 0 = false/default


  LOGLEVEL="info"
  sets -log-level="info": The logging level. Can be error, warn, info, debug or trace

### Using docker-compose

Set your environment variables within the [docker-compose.yml](docker-compose.yml) file.  

Then start up the container using `docker-compose up -d`.

### Using the binary

Usage:

./fritzbox_exporter --help
Usage of ./fritzbox_exporter:
  -collect=false: print configured metrics to stdout and exit
  -gateway-luaurl="http://fritz.box": The URL of the FRITZ!Box UI
  -gateway-url="http://fritz.box:49000": The URL of the FRITZ!Box
  -json-out="": store metrics also to JSON file when running test
  -listen-address="127.0.0.1:9042": The address to listen on for HTTP requests.
  -log-level="info": The logging level. Can be error, warn, info, debug or trace
  -lua-metrics-file="metrics-lua.json": The JSON file with the lua metric definitions.
  -metrics-file="metrics.json": The JSON file with the metric definitions.
  -nolua=false: disable collecting lua metrics
  -password="": The password for the FRITZ!Box UPnP service
  -test=false: print all available metrics to stdout
  -testLua=false: read luaTest.json file make all contained calls and dump results
  -username="": The user for the FRITZ!Box UPnP service
  -verifyTls=false: Verify the tls connection when connecting to the FRITZ!Box

    The password (needed for metrics from TR-064 API) can be passed over environment variables to test in shell:
    read -rs PASSWORD && export PASSWORD && ./fritzbox_exporter -username <user> -test; unset PASSWORD

## Exported metrics

start exporter and run
curl -s http://127.0.0.1:9042/metrics 

## Output of -test

The exporter prints all available Variables to stdout when called with the -test option.
These values are determined by parsing all services from http://fritz.box:49000/igddesc.xml and http://fritzbox:49000/tr64desc.xml (for TR64 username and password is needed!!!)

## Customizing metrics

The metrics to collect are no longer hard coded, but have been moved to the [metrics.json](metrics.json) and [metrics-lua.json](metrics-lua.json) files, so just adjust to your needs (for cable version also see [metrics-lua_cable.json](metrics-lua_cable.json)).
For a list of all the available metrics just execute the exporter with -test (username and password are needed for the TR-064 API!)
For lua metrics open UI in browser and check the json files used for the various screens.

For a list of all available metrics, see the dumps below (the format is the same as in the metrics.json file, so it can be used to easily add further metrics to retrieve):
- [FritzBox 6591 v7.29](all_available_metrics_6591_7.29.json)
- [FritzBox 7590 v7.12](all_available_metrics_7590_7.12.json)
- [FritzBox 7590 v7.20](all_available_metrics_7590_7.20.json)
- [FritzBox 7590 v7.25](all_available_metrics_7590_7.25.json)
- [FritzBox 7590 v7.29](all_available_metrics_7590_7.29.json)
## Grafana Dashboard

The dashboard is now also published on [Grafana](https://grafana.com/grafana/dashboards/12579).
