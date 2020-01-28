param (
    [parameter(Mandatory = $false)]$undo = $False
)
$ScriptName = $MyInvocation.MyCommand.Name
Function Publish-Log{
    Param (
        [parameter(Mandatory = $true)]
        $Message,

        [Parameter(Mandatory = $true)]
        $Source
    )

    Try {
        $Date = Get-Date
        $LogFileName = "$ScriptName $(Get-Date -UFormat "%m-%d-%y").txt"
        # Specify path to log file
        $Path = "$env:windir\Logs\$LogFileName"
        Out-File -FilePath $Path -InputObject "$Message -- $Source -- $Date" -Append
    }
    Catch {

    }
}

if ($undo -eq $False) {
    If ([System.Environment]::Is64BitOperatingSystem -eq $True) {
        Publish-Log -Message "64-bit OS detected. Implementing CVE-2020-0674 mitigation." -Source "$ScriptName"
        $TakeOwn = takeown /f $env:windir\syswow64\jscript.dll
        Publish-Log -Message "$TakeOwn" -Source "$ScriptName"
        $Cacls = cacls $env:windir\syswow64\jscript.dll /E /P everyone:N
        Publish-Log -Message "$Cacls" -Source "$ScriptName"
        takeown /f $env:windir\system32\jscript.dll
        Publish-Log -Message "$TakeOwn" -Source "$ScriptName"
        $Cacls = cacls $env:windir\system32\jscript.dll /E /P everyone:N
        Publish-Log -Message "$Cacls" -Source "$ScriptName"
    }
    Else {
        Publish-Log -Message "32-bit OS detected. Implementing CVE-2020-0674 mitigation." -Source "$ScriptName"
        $TakeOwn = takeown /f %windir%\system32\jscript.dll
        Publish-Log -Message "$TakeOwn" -Source "$ScriptName"
        $Cacls = cacls $env:windir\system32\jscript.dll /E /P everyone:N
        Publish-Log -Message "$Cacls" -Source "$ScriptName"
    }
}
elseif ($undo -eq $True) {
    If ([System.Environment]::Is64BitOperatingSystem -eq $True) {
        Publish-Log -Message "64-bit OS detected. Reverting the CVE-2020-0674 mitigation." -Source "$ScriptName"
        $Cacls = cacls $env:windir\system32\jscript.dll /E /R everyone
        Publish-Log -Message "$Cacls" -Source "$ScriptName"
        $Cacls = cacls $env:windir\syswow64\jscript.dll /E /R everyone
        Publish-Log -Message "$Cacls" -Source "$ScriptName"
    } 
    Else {
        Publish-Log -Message "32-bit OS detected. Reverting the CVE-2020-0674 mitigation." -Source "$ScriptName"
        $Cacls = cacls $env:windir\system32\jscript.dll /E /R everyone
        Publish-Log -Message "$Cacls" -Source "$ScriptName"
    }
}
