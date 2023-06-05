# This project is unmaintaned

At this point the project is unmantained. If you wish to collaborate let us know.

# Azure Pipelines Agent Docker Image

This repository contains `Dockerfile` definitions for
[lambda3/azure-pipelines-agent](https://github.com/lambda3/docker-azure-pipelines-agent-windows).

It will not work with Azure DevOps Server.

[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/lambda3/azure-pipelines-agent-windows.svg)](https://registry.hub.docker.com/u/lambda3/azure-pipelines-agent-windows)
[![Build](https://github.com/lambda3/docker-azure-pipelines-agent-windows/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/Lambda3/docker-azure-pipelines-agent-windows/actions/workflows/build.yml)

## Supported tags

- [`latest` (*agent/Dockerfile*)](https://github.com/lambda3/docker-azure-pipelines-agent-windows/blob/main/agent/Dockerfile)

### Other tags

- For a specific Windows Server Version (only 2019 at this time): `lambda3/azure-pipelines-agent-windows:windowsservercore-ltsc2019`
- For a specific git tag (tag `1.2.3` in this example): `lambda3/azure-pipelines-agent-windows:1.2.3`
- For a specific git tag on a specific Windows Server Version: `lambda3/azure-pipelines-agent-windows:1.2.3-windowsservercore-ltsc2019`
- For a specific commit (only commits on `main` get tagged and pushed): `lambda3/azure-pipelines-agent-windows:95aeca1`
- For the current `main` branch: `lambda3/azure-pipelines-agent-windows:main`

## Configuration

You need/can to set these environment variables:

- `AGENT_PAT` - The personal access token from Azure Pipelines. Required. See
  [Microsoft Docs](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#authenticate-with-a-personal-access-token-pat) for instructions on how to create the PAT.
- `VS_TENANT` - The Azure Pipelines tenant, a.k.a. the value that goes before .visualstudio.com, i.e., on foo.visualstudio.com, should be `foo`. Required.
- `AGENT_POOL` - The agent pool. Optional. Default value: `Default`

## Running

On Windows, use Docker for Windows and run, on PowerShell:

````powershell
docker run --name azure-pipelines-agent-windows -ti -e VS_TENANT=$env:VS_TENANT -e AGENT_PAT=$env:AGENT_PAT -d lambda3/azure-pipelines-agent-windows
````

For the agent to work as expected mount `c:\agent\_works` from the host to the agent
container, adding to docker run `-v c:\agent\_works:c:\agent\_works`, like so, on
PowerShell:

````powershell
docker run --name azure-pipelines-agent-windows -ti -e VS_TENANT=$env:VS_TENANT -e AGENT_PAT=$env:AGENT_PAT -d -v c:\agent\_works:c:\agent\_works lambda3/azure-pipelines-agent-windows
````

This will keep the agent staging directory (and other work directories)
persistent across agent restarts. Also, it is recommended that you mount to a
directory that is relative to this directory, like the staging directory, so
when it is mounted on the host, it is also available for the agent.

### With Docker

If you want to run Docker on Docker, and access the underlying Docker engine,
you have to mount the Docker named pipe, and user the `docker` tag of this
repository, like so:

````powershell
docker run --name azure-pipelines-agent-windows -ti -v \\.\pipe\docker_engine:\\.\pipe\docker_engine -e VS_TENANT=$env:VS_TENANT -e AGENT_PAT=$env:AGENT_PAT -d -ti azure-pipelines-agent-windows
````

### With docker-compose

See examples at the [examples](https://github.com/Lambda3/docker-azure-pipelines-agent-windows/blob/main/examples/)) folder.

## Maintainers

- [Giovanni Bassi](http://blog.lambda3.com.br/L3/giovannibassi/), aka Giggio, [Lambda3](http://www.lambda3.com.br), [@giovannibassi](https://twitter.com/giovannibassi)

## License

This software is open source, licensed under the Apache License, Version 2.0.
See [LICENSE.txt](https://github.com/lambda3/azure-pipelines-agent-windows/blob/main/LICENSE.txt) for details.
Check out the terms of the license before you contribute, fork, copy or do anything
with the code. If you decide to contribute you agree to grant copyright of all your contribution to this project, and agree to
mention clearly if do not agree to these terms. Your work will be licensed with the project at Apache V2, along the rest of the code.
