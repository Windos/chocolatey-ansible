#Requires -Module Ansible.ModuleUtils.ArgvParser
#Requires -Module Ansible.ModuleUtils.CommandUtil

#AnsibleRequires -PowerShell ansible_collections.chocolatey.chocolatey.plugins.module_utils.Common

function Get-ChocolateyGuiConfig {
    <#
        .SYNOPSIS
        Outputs a hashtable containing the Chocolatey GUI configuration information.

        .DESCRIPTION
        Outputs a hashtable containing the Chocolatey GUI containing all the avilable
        settings and their configured values.
        Optionally, outputs the name and configured value for a specified configuration
        setting.
    #>
    [CmdletBinding()]
    param(
        # A CommandInfo object containing the path to chocolateyguicli.exe.
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.CommandInfo]
        $ChocoCommand,

        [Parameter()]
        [String[]]
        $ConfigName
    )

    $arguments = @(
        $ChocoCommand.Path
        "config", "list"
        "-r"
    )

    $command = Argv-ToString -Arguments $arguments
    $result = Run-Command -Command $command

    if ($result.rc -ne 0) {
        $message = "Failed to list Chocolatey features: $($result.stderr)"
        Assert-TaskFailed -Message $message -CommandResult $result
    }

    # Build a hashtable of configuration settings
    $config = @{}
    $result |
        ConvertFrom-Stdout |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object {
            $name, $value, $null = $_ -split "\|"
            if (-not $ConfigName -or $name -in $ConfigName) {
                $config.$name = $value
            }
        }

    $config
}

Export-ModuleMember -Function Get-ChocolateyGuiConfig
