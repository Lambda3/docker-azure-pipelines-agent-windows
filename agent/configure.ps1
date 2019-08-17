#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

if (!($env:AGENT_POOL)) { $env:AGENT_POOL='Default' }
if (!($env:VS_TENANT)) {
  write-error 'Variable "VS_TENANT" is not set.'
  exit 1
}
if (!($env:AGENT_PAT)) {
  write-error 'Variable "AGENT_PAT" is not set.'
  exit 2
}
if (!(Test-Path $PSScriptRoot/.credentials))
{
  $env:DOTNET_VERSION=$(dotnet --version)
  $WORK_DIR="$PSScriptRoot/_works/$(hostname)"
  if (!(Test-Path $WORK_DIR)) {
    mkdir $WORK_DIR
  }
  . $PSScriptRoot/bin/Agent.Listener configure --url https://dev.azure.com/$env:VS_TENANT --pool $env:AGENT_POOL --auth PAT --token $env:AGENT_PAT --agent $(hostname) --work $WORK_DIR --unattended
  $retval = $LASTEXITCODE
  if ($retval -ne 0) {
    write-error "Return code was not zero but $retval"
    exit 3
  }
}
Remove-Item Env:\AGENT_PAT
Remove-Item Env:\AGENT_POOL
Remove-Item Env:\VS_TENANT