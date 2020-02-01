<#
Run this script with -Undo appended to remove the permissions block after installing the February 2020 patches which should remediate this vulnerability.

Microsoft's workaround comprises setting permissions on jscript.dll such that nobody will be able to read it. This workaround has an expected negative side effect that if you're using a web application that employs legacy JScript (and can as such only be used with Internet Explorer), this application will no longer work in your browser.

There also several other negative side effects:
Windows Media Player is reported to break on playing MP4 files.
The sfc (Resource Checker), a tool that scans the integrity of all protected system files and replaces incorrect versions with correct Microsoft versions, chokes on jscript.dll with altered permissions.
Printing to "Microsoft Print to PDF" is reported to break.
Proxy automatic configuration scripts (PAC scripts) may not work.
#>

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
        $TakeOwn = takeown /f $env:windir\system32\jscript.dll
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
