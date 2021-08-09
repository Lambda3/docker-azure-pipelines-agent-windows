# escape=`
FROM lambda3/azure-pipelines-agent-windows

USER containeradministrator
#SHELL ["powershell.exe", "-Command"]
#RUN Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force
#RUN Install-Module DockerMsftProvider -Force
# there is a bug on the docker installation, so we have to do a workaround,
# which is the next 3 lines
# bug: https://github.com/OneGet/MicrosoftDockerProvider/issues/15
#RUN mkdir $env:temp\DockerMsftProvider\
#RUN Start-BitsTransfer -Source https://dockermsft.blob.core.windows.net/dockercontainer/docker-19-03-1.zip -Destination $env:temp\DockerMsftProvider\Docker-19-03-1.zip
#RUN Get-FileHash -Path $env:temp\DockerMsftProvider\Docker-19-03-1.zip -Algorithm SHA256
#RUN Install-Package Docker -ProviderName DockerMsftProvider -Force -Verbose -RequiredVersion 19.03.1
COPY *.ps1 c:\agent\
RUN $acl = Get-Acl c:\agent\; `
    $acl.SetOwner([System.Security.Principal.NTAccount] 'agentuser'); `
    get-childitem -File c:\agent\*.ps1 | % { Set-Acl -Path $_ -AclObject $acl };
#USER agentuser # can't run as agentuser, or the bind to the docker named pipe will not work