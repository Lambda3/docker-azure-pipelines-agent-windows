#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$env:DOCKER_VERSION = $(docker --version)
$env:DOCKER_COMPOSE_VERSION = $(docker-compose --version)
