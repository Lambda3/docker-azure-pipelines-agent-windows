# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019 as base
LABEL maintainer="giggio@giggio.net"
SHELL ["powershell.exe", "-NoLogo", "-Command"]
#users
WORKDIR c:\agent
RUN net user /add agentuser
#choco
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); `
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramData\chocolatey\bin\;$env:PATH\", [EnvironmentVariableTarget]::Machine)

FROM base as ancm
# (ANCM) ASP.NET Core 6.0 Runtime - Windows Hosting Bundle Installer (https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/aspnet-core-module)
RUN Install-WindowsFeature -name Web-Server,Web-Asp-Net45;
RUN choco install --no-progress -y dotnet-aspnetcoremodule-v2

FROM base
# node, npm:
RUN choco install --no-progress -y nodejs.install
# pwsh, auto download latest release
RUN $releases = Invoke-RestMethod https://api.github.com/repos/PowerShell/PowerShell/releases; `
    $releaseTag = npx -q --yes semvermaxcli ( $releases | ? { ! $_.prerelease } | % { $_.tag_name }); `
    $assets = Invoke-RestMethod ($releases | ? { $_.tag_name -eq $releaseTag }).assets_url; `
    $pwshUrl = ($assets | ? { $_.name -like '*-win-x64.msi' }).browser_download_url; `
    if ($pwshUrl.count -ne 1) { throw "Found more than one version." } `
    Invoke-WebRequest $pwshUrl -OutFile pwsh.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I pwsh.msi /quiet'; `
    Remove-Item pwsh.msi; `
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramFiles\PowerShell\7\;$env:PATH\", [EnvironmentVariableTarget]::Machine)
SHELL ["pwsh.exe", "-NoLogo", "-Command"]
# iis express
RUN choco install --no-progress -y iisexpress;
RUN mkdir \"$env:ProgramFiles/IIS Express/Asp.Net Core Module/\"; `
    mkdir \"${env:ProgramFiles(x86)}/IIS Express/Asp.Net Core Module/\"
COPY --from=ancm  [ "C:/Program Files (x86)/IIS/Asp.Net Core Module/", "C:/Program Files (x86)/IIS Express/Asp.Net Core Module/" ]
COPY --from=ancm  [ "C:/Program Files/IIS/Asp.Net Core Module/", "C:/Program Files/IIS Express/Asp.Net Core Module/" ]

# VS build tools
# See: https://docs.microsoft.com/visualstudio/install/build-tools-container
# See commandline: https://docs.microsoft.com/visualstudio/install/use-command-line-parameters-to-install-visual-studio
# See workloads: https://docs.microsoft.com/visualstudio/install/workload-component-id-vs-build-tools
RUN Invoke-WebRequest https://aka.ms/vs/17/release/vs_buildtools.exe -outfile $env:temp\vs_buildtools.exe; `
    cmd /c 'start /w %temp%\vs_buildtools.exe --quiet --wait --norestart --nocache modify `
    --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --remove Microsoft.VisualStudio.Component.Windows81SDK `
    --add Microsoft.VisualStudio.Workload.AzureBuildTools `
    --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools `
    --add Microsoft.VisualStudio.Workload.MSBuildTools `
    --add Microsoft.VisualStudio.Workload.UniversalBuildTools `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Workload.VisualStudioExtensionBuildTools `
    --add Microsoft.VisualStudio.Workload.WebBuildTools `
    --add Microsoft.VisualStudio.Workload.XamarinBuildTools `
    --add Microsoft.VisualStudio.Component.Windows10SDK.18362'; `
    $exitCode = $LastExitCode; `
    if (($exitCode -ne 0) -and ($exitCode -ne 3010)) { exit $exitCode }; `
    Push-Location $env:temp; `
    remove-item * -Recurse -Force -ErrorAction SilentlyContinue; `
    Pop-Location
# netcore 3.1 and 5 (6 is already installed)
RUN Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1; `
    .\dotnet-install.ps1 -Channel 3.1 -InstallDir $env:ProgramFiles\dotnet; `
    .\dotnet-install.ps1 -Channel 5.0 -InstallDir $env:ProgramFiles\dotnet; `
    [Environment]::SetEnvironmentVariable('PATH', \"$HOME\.dotnet\tools;$env:PATH\", [EnvironmentVariableTarget]::Machine); `
    Remove-Item dotnet-install.ps1
# (ANCM) ASP.NET Core 6.0 Runtime - Windows Hosting Bundle Installer (https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/aspnet-core-module)
RUN Invoke-WebRequest -OutFile dotnet-hosting.exe -Uri https://download.visualstudio.microsoft.com/download/pr/ae1014c7-a005-4a0e-9062-b6f3056ded09/da5d731f5ead9e385427a77412b88fb0/dotnet-hosting-6.0.5-win.exe
# az cli:
RUN Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; `
    Remove-Item AzureCLI.msi
# kubectl, helm, terraform, git, iis express, yarn:
RUN choco install --no-progress -y kubernetes-cli kubernetes-helm terraform git.install yarn nvm.portable
# chrome, ignores checksum because they cannot be safely verified
RUN choco install --no-progress --ignore-checksum -y GoogleChrome
# openjdk
RUN choco install --no-progress -y openjdk --version 11.0.2.01
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
# azurerm
RUN $ProgressPreference='SilentlyContinue'; `
    Install-Module -Name AzureRM -Repository PSGallery -Force -Scope AllUsers -AllowClobber
# azureps
RUN $ProgressPreference='SilentlyContinue'; `
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
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramFiles\Docker\;$env:PATH\", [EnvironmentVariableTarget]::Machine);
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
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
COPY _vimrc C:\Users\ContainerAdministrator\
COPY _vimrc C:\Users\agentuser\
RUN $acl = Get-Acl c:\agent\; `
    $acl.SetOwner([System.Security.Principal.NTAccount] 'agentuser'); `
    get-childitem -File c:\agent\ | % { Set-Acl -Path $_ -AclObject $acl }; `
    Set-Acl -Path c:\agent\ -AclObject $acl
USER agentuser

CMD ["pwsh", "-f", "configureAndRun.ps1"]