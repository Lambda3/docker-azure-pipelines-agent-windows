#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot
. $PSScriptRoot/bin/Agent.Listener run
Wait-Event
Pop-Location