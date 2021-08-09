# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

LABEL maintainer="giggio@giggio.net"
SHELL ["powershell.exe", "-Command"]
#SHELL ["cmd", "/S", "/C"]
#users
RUN net user /add agentuser; `
    mkdir c:\agent
WORKDIR c:\agent
# VS build tools
# See: https://docs.microsoft.com/visualstudio/install/build-tools-container
# See commandline: https://docs.microsoft.com/visualstudio/install/use-command-line-parameters-to-install-visual-studio
# See workloads: https://docs.microsoft.com/visualstudio/install/workload-component-id-vs-build-tools
RUN Invoke-WebRequest https://aka.ms/vs/16/release/vs_buildtools.exe -outfile $env:temp\vs_buildtools.exe; `
    Invoke-WebRequest https://aka.ms/vs/16/release/channel -outfile $env:temp\visualstudio.chman; `
    cmd /c "$env:temp\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri $env:temp\visualstudio.chman `
    --installChannelUri $env:temp\visualstudio.chman `
    --add Microsoft.VisualStudio.Workload.AzureBuildTools `
    --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools `
    --add Microsoft.VisualStudio.Workload.MSBuildTools `
    --add Microsoft.VisualStudio.Workload.NetCoreBuildTools `
    --add Microsoft.VisualStudio.Workload.UniversalBuildTools `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Workload.VisualStudioExtensionBuildTools `
    --add Microsoft.VisualStudio.Workload.WebBuildTools `
    --add Microsoft.VisualStudio.Workload.XamarinBuildTools `
    --add Microsoft.VisualStudio.Component.Windows10SDK.18362"; `
    $exitCode = $LastExitCode; `
    if (($exitCode -ne 0) -and ($exitCode -ne 3010)) { exit $exitCode }; `
    Push-Location $env:temp; `
    remove-item * -Recurse -Force -ErrorAction SilentlyContinue; `
    Pop-Location
# netcore 2.1 (3.1 is already installed)
RUN Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1; `
    .\dotnet-install.ps1 -Channel 2.1 -InstallDir $env:ProgramFiles\dotnet; `
    [Environment]::SetEnvironmentVariable('PATH', \"$HOME\.dotnet\tools;$env:PATH\", [EnvironmentVariableTarget]::Machine); `
    Remove-Item dotnet-install.ps1
# az cli:
RUN Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; `
    Remove-Item AzureCLI.msi
#choco
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); `
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramData\chocolatey\bin\;$env:PATH\", [EnvironmentVariableTarget]::Machine)
# pwsh:
RUN Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi -OutFile pwsh.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I pwsh.msi /quiet'; `
    Remove-Item pwsh.msi; `
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramFiles\PowerShell\7\;$env:PATH\", [EnvironmentVariableTarget]::Machine)
SHELL ["pwsh.exe", "-NoLogo", "-Command"]
# kubectl, helm, terraform, git, iis express, node, npm, yarn:
RUN choco install --no-progress -y kubernetes-cli kubernetes-helm terraform git.install iisexpress nodejs.install yarn nvm.portable
# chrome, ignores checksum because they cannot be safely verified
RUN choco install --no-progress --ignore-checksum -y GoogleChrome
# openjdk
RUN choco install --no-progress -y openjdk --version 11.0.2.01
# vim
RUN Invoke-WebRequest http://ftp.vim.org/pub/vim/pc/vim81w32.zip -outfile vim.zip; `
    Add-Type -AssemblyName System.IO.Compression.FileSystem; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory(\"$(pwd)\vim.zip\", \"$env:ProgramFiles\"); `
    rm vim.zip; `
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramFiles\vim\vim81\;$env:PATH\", [EnvironmentVariableTarget]::Machine)
# azurerm
RUN $ProgressPreference=’SilentlyContinue’; `
    Install-Module -Name AzureRM -Repository PSGallery -Force -Scope AllUsers -AllowClobber
# azureps
RUN $ProgressPreference=’SilentlyContinue’; `
    Install-Module -Name Az -Repository PSGallery -Force -Scope AllUsers -AllowClobber
# setup iis permissions
RUN . 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Aspnet_regiis.exe' -ga containeradministrator; `
    . 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Aspnet_regiis.exe' -ga agentuser; `
    . 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Aspnet_regiis.exe' -ga containeradministrator; `
    . 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Aspnet_regiis.exe' -ga agentuser
# docker
RUN mkdir $env:temp\docker\extracted\ | out-null; `
    mkdir $env:ProgramFiles\Docker\ | out-null; `
    Invoke-WebRequest https://dockermsft.azureedge.net/dockercontainer/docker-20-10-6.zip -OutFile $env:temp\docker\docker.zip; `
    Add-Type -AssemblyName System.IO.Compression.FileSystem ; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory(\"$env:temp\docker\docker.zip\", \"$env:temp\docker\extracted\"); `
    get-childitem -Recurse \"$env:temp\docker\extracted\docker\" | Move-Item -Destination \"$env:ProgramFiles\Docker\"; `
    Remove-Item $env:temp\docker\ -Recurse -Force; `
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramFiles\Docker\;$env:PATH\", [EnvironmentVariableTarget]::Machine);
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe -UseBasicParsing -OutFile $Env:ProgramFiles\Docker\docker-compose.exe
# agent:
# auto download latest release, wait for bug
# https://github.com/microsoft/azure-pipelines-agent/issues/2688 to be fixed
#RUN $releases = Invoke-RestMethod https://api.github.com/repos/microsoft/azure-pipelines-agent/releases; `
#    $releaseTag = npx -q semvermaxcli ( $releases | ? { ! $_.prerelease } | % { $_.tag_name }); `
#    $assetsUrl = Invoke-RestMethod ($releases | ? { $_.tag_name -eq $releaseTag }).assets_url; `
#    $assets = Invoke-RestMethod $assetsUrl.browser_download_url; `
#    $agentUrl = ($assets | ? { $_.platform -eq 'win-x64' }).downloadUrl; `
#    Invoke-WebRequest $agentUrl -OutFile agent.zip; `
#    Add-Type -AssemblyName System.IO.Compression.FileSystem ; `
#    [System.IO.Compression.ZipFile]::ExtractToDirectory('agent.zip', \"$PWD\"); `
#    Remove-Item agent.zip
RUN Invoke-WebRequest https://vstsagentpackage.azureedge.net/agent/2.190.0/vsts-agent-win-x64-2.190.0.zip -OutFile agent.zip; `
    Add-Type -AssemblyName System.IO.Compression.FileSystem ; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory('agent.zip', \"$PWD\"); `
    Remove-Item agent.zip
COPY *.ps1 c:\agent\
RUN $acl = Get-Acl c:\agent\; `
    $acl.SetOwner([System.Security.Principal.NTAccount] 'agentuser'); `
    get-childitem -File c:\agent\ | % { Set-Acl -Path $_ -AclObject $acl }; `
    Set-Acl -Path c:\agent\ -AclObject $acl
USER agentuser

CMD ["pwsh", "-f", "configureAndRun.ps1"]