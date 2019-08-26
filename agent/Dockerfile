# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

LABEL maintainer="giggio@giggio.net"
SHELL ["powershell.exe", "-Command"]
#SHELL ["cmd", "/S", "/C"]
#users
RUN net user /add agentuser; `
    mkdir c:\agent
WORKDIR c:\agent
# netcore (2.1 only, 2.2 is already installed)
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
RUN Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v6.2.2/PowerShell-6.2.2-win-x64.msi -OutFile pwsh.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I pwsh.msi /quiet'; `
    Remove-Item pwsh.msi
SHELL ["pwsh.exe", "-Command"]
# nvm/node/yarn:
RUN Invoke-WebRequest -Uri https://nodejs.org/dist/v12.8.1/node-v12.8.1-x64.msi -OutFile node.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I node.msi /quiet'; `
    Remove-Item node.msi
RUN Invoke-WebRequest -Uri https://github.com/yarnpkg/yarn/releases/download/v1.17.3/yarn-1.17.3.msi -OutFile yarn.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I yarn.msi /quiet'; `
    Remove-Item yarn.msi
# kubectl, helm, terraform, git:
RUN choco install -y kubernetes-cli kubernetes-helm terraform git.install
# chrome, ignores checksum because they cannot be safely verified
RUN choco install --ignore-checksum -y GoogleChrome
# vim
RUN Invoke-WebRequest http://ftp.vim.org/pub/vim/pc/vim81w32.zip -outfile vim.zip; `
    Add-Type -AssemblyName System.IO.Compression.FileSystem; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory(\"$(pwd)\vim.zip\", \"$env:ProgramFiles\"); `
    rm vim.zip; `
    [Environment]::SetEnvironmentVariable('PATH', \"$env:ProgramFiles\vim\vim81\;$env:PATH\", [EnvironmentVariableTarget]::Machine)
# agent:
RUN Invoke-WebRequest https://vstsagentpackage.azureedge.net/agent/2.155.1/vsts-agent-win-x64-2.155.1.zip -OutFile agent.zip; `
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