# escape=`
FROM lambda3/azure-pipelines-agent-windows

USER containeradministrator
COPY *.ps1 c:\agent\
RUN $acl = Get-Acl c:\agent\; `
    $acl.SetOwner([System.Security.Principal.NTAccount] 'agentuser'); `
    get-childitem -File c:\agent\*.ps1 | % { Set-Acl -Path $_ -AclObject $acl };
#USER agentuser # can't run as agentuser, or the bind to the docker named pipe will not work