<#
EXAMPLE:

cd C:\scripts
.\Install-ADV200005-Workaround.ps1 -Target dc1
.\Install-ADV200005-Workaround.ps1 -Target dc1,dc2,fs1,prn2 -undo $true

Run this script with -Undo $True appended to remove the workaround after installing the relevant security patches which should remediate this vulnerability.
#>

param(
    [parameter(Mandatory = $false)]$Undo = $false,

    [parameter(Mandatory = $true)]$Target
)

Function Set-SMBCompression {

    if($Undo -eq $true)
    {
        Invoke-Command $target -ScriptBlock {Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" DisableCompression -Type DWORD -Value 0 -Force}
    }
    else{
        Invoke-Command $target -ScriptBlock {Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" DisableCompression -Type DWORD -Value 1 -Force}
    }
}

Set-SMBCompression