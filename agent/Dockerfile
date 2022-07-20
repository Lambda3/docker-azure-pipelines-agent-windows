# escape=`
ARG LTSC_YEAR=2019
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc${LTSC_YEAR}
LABEL maintainer="giggio@giggio.net"
WORKDIR c:\agent
#users
RUN net user /add agentuser
RUN net user agentuser /expires:never

# just to create the user profile:
USER agentuser
RUN dir c:\users\
USER ContainerAdministrator

#choco
RUN powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
# pwsh
RUN [ "choco", "install", "--no-progress", "-y", "powershell-core" ]
SHELL [ "pwsh.exe", "-NoLogo", "-Command", "$ErrorActionPreference='Stop';", "$ProgressPreference='SilentlyContinue';" ]
# VS tools
# See: https://docs.microsoft.com/visualstudio/install/build-tools-container
# See commandline: https://docs.microsoft.com/visualstudio/install/use-command-line-parameters-to-install-visual-studio
# See workloads: https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community
# original instalation executable for build tools: https://aka.ms/vs/17/release/vs_buildtools.exe
# running in multiple RUNs to not hit the layer limit of 10GB
RUN choco install --execution-timeout 7200 --no-progress -y visualstudio2022community --verbose --package-parameters `
    '--add Microsoft.VisualStudio.Workload.Azure `
    --add Microsoft.VisualStudio.Workload.ManagedDesktop `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Workload.VisualStudioExtension `
    --add Microsoft.VisualStudio.Workload.NetWeb '
RUN choco install --execution-timeout 7200 --no-progress -y visualstudio2022community --verbose --force --package-parameters `
    '--add Microsoft.VisualStudio.Workload.NetCrossPlat `
    --add Microsoft.Component.NetFX.Native `
    --add Microsoft.VisualStudio.ComponentGroup.MSIX.Packaging `
    --add Microsoft.VisualStudio.ComponentGroup.UWP.Support	 `
    --add Microsoft.VisualStudio.ComponentGroup.UWP.NetCoreAndStandard `
    --add Microsoft.VisualStudio.Component.Windows10SDK.19041 '
# netcore 3.1 (6 is already installed)
RUN Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1; `
    .\dotnet-install.ps1 -Channel 3.1 -InstallDir $env:ProgramFiles\dotnet; `
    [Environment]::SetEnvironmentVariable('PATH', \"$HOME\.dotnet\tools;$env:PATH\", [EnvironmentVariableTarget]::Machine); `
    Remove-Item dotnet-install.ps1
# # az cli:
# kubectl, helm, terraform, git, nvm, node, az cli:
RUN [ "choco", "install", "--no-progress", "-y", "kubernetes-cli", "kubernetes-helm", "terraform", "git.install", "nvm.portable", "nodejs.install", "azure-cli" ]
# chrome, ignores checksum because they cannot be safely verified
RUN [ "choco", "install", "--no-progress", "-y", "--ignore-checksum", "GoogleChrome" ]
# openjdk
RUN [ "choco", "install", "--no-progress", "-y", "openjdk ", "--version", "11.0.2.01" ]
# corepack (yarn)
RUN corepack enable
# vim, auto download latest release
RUN $releases = Invoke-RestMethod https://api.github.com/repos/vim/vim-win32-installer/releases; `
    $releaseTag = npx -q --yes semvermaxcli ( $releases | ? { ! $_.prerelease } | % { $_.tag_name }); `
    $assets = Invoke-RestMethod ($releases | ? { $_.tag_name -eq $releaseTag }).assets_url; `
    $vimUrl = ($assets | ? { $_.name -like '*_x64.zip' }).browser_download_url; `
    if ($vimUrl.count -ne 1) { throw "Found more than one version." } `
    Invoke-WebRequest $vimUrl -OutFile vim.zip; `
    Add-Type -AssemblyName System.IO.Compression.FileSystem ; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory(\"$(pwd)\vim.zip\", \"$env:ProgramFiles\"); `
    Remove-Item vim.zip; `
    [Environment]::SetEnvironmentVariable('PATH', \"$((Get-ChildItem $env:ProgramFiles\vim\)[0].FullName);$env:PATH\", [EnvironmentVariableTarget]::Machine)
# powershell modules: azurerm, azureps
RUN Install-Module -Name AzureRM -Repository PSGallery -Force -Scope AllUsers -AllowClobber; `
    Install-Module -Name Az -Repository PSGallery -Force -Scope AllUsers -AllowClobber
# setup iis permissions
RUN . 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Aspnet_regiis.exe' -ga containeradministrator; `
    . 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Aspnet_regiis.exe' -ga agentuser; `
    . 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Aspnet_regiis.exe' -ga containeradministrator; `
    . 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Aspnet_regiis.exe' -ga agentuser
# docker, index at: https://dockermsft.blob.core.windows.net/dockercontainer/DockerMsftIndex.json
RUN mkdir $env:temp\docker\extracted\ | out-null; `
    mkdir $env:ProgramFiles\Docker\ | out-null; `
    Invoke-WebRequest https://dockermsft.azureedge.net/dockercontainer/docker-20-10-9.zip -OutFile $env:temp\docker\docker.zip; `
    Add-Type -AssemblyName System.IO.Compression.FileSystem ; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory(\"$env:temp\docker\docker.zip\", \"$env:temp\docker\extracted\"); `
    get-childitem -Recurse \"$env:temp\docker\extracted\docker\" | Move-Item -Destination \"$env:ProgramFiles\Docker\"; `
    Remove-Item $env:temp\docker\ -Recurse -Force; `
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramFiles\Docker\;$env:PATH\", [EnvironmentVariableTarget]::Machine); `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe -UseBasicParsing -OutFile $Env:ProgramFiles\Docker\docker-compose.exe
# agent, auto download latest release
RUN $releases = Invoke-RestMethod https://api.github.com/repos/microsoft/azure-pipelines-agent/releases; `
    $releaseTag = npx -q --yes semvermaxcli ( $releases | ? { ! $_.prerelease } | % { $_.tag_name }); `
    $assetsUrl = Invoke-RestMethod ($releases | ? { $_.tag_name -eq $releaseTag }).assets_url; `
    $assets = Invoke-RestMethod $assetsUrl.browser_download_url; `
    $agentUrl = ($assets | ? { $_.platform -eq 'win-x64' -and $_.name -like 'vsts*' }).downloadUrl; `
    if ($agentUrl.count -ne 1) { throw "Found more than one version." } `
    Invoke-WebRequest $agentUrl -OutFile agent.zip; `
    Add-Type -AssemblyName System.IO.Compression.FileSystem ; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory('agent.zip', \"$PWD\"); `
    Remove-Item agent.zip
COPY *.ps1 c:\agent\
CMD ["pwsh", "-f", "configureAndRun.ps1"]
COPY _vimrc C:\Users\ContainerAdministrator\
RUN Copy-Item C:\Users\ContainerAdministrator\_vimrc c:\Users\agentuser\; `
    $acl = Get-Acl c:\Users\agentuser\_vimrc; `
    $acl.SetOwner([System.Security.Principal.NTAccount] 'agentuser'); `
    $acl = Get-Acl c:\agent\; `
    $acl.SetOwner([System.Security.Principal.NTAccount] 'agentuser'); `
    get-childitem -File c:\agent\ | % { Set-Acl -Path $_ -AclObject $acl }; `
    Set-Acl -Path c:\agent\ -AclObject $acl
