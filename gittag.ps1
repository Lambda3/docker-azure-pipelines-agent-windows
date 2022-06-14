$ErrorActionPreference = "Stop"
$releases = Invoke-RestMethod https://api.github.com/repos/microsoft/azure-pipelines-agent/releases
$releaseTag = npx -q --yes semvermaxcli ( $releases | ? { ! $_.prerelease } | % { $_.tag_name })
Write-Output "Release tag: $releaseTag"
Write-Output "Release url: https://github.com/microsoft/azure-pipelines-agent/releases/$releaseTag"
$assetsUrl = Invoke-RestMethod ($releases | ? { $_.tag_name -eq $releaseTag }).assets_url
$assets = Invoke-RestMethod $assetsUrl.browser_download_url
$agentUrl = ($assets | ? { $_.platform -eq 'win-x64' -and $_.name -like 'vsts*' }).downloadUrl
if ($agentUrl.count -ne 1) {
    Write-Error "Found more than one download url: $agentUrl"
    exit 1
} else {
    Write-Output "Download url: $agentUrl"
}
# match releaseTag to regex
if ($releaseTag -match 'v(\d+\.\d+\.\d+)') {
    $version = $matches[1]
    Write-Output "Version: $version"
} else {
    Write-Error "Could not match releaseTag to semver"
    exit 1
}
Write-Output "Writing git tag $version..."
git tag -s $version -m $version
if ($LASTEXITCODE -ne 0) {
    Write-Output "Failed to write git tag $version"
    exit 1
}