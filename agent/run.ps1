#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

cd $PSScriptRoot
. $PSScriptRoot/bin/Agent.Listener run
