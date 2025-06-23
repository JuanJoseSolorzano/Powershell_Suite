<#
.SYNOPSIS
    PowerShell profile script for setting up the environment and importing necessary modules.

.DESCRIPTION
    This script sets up the PowerShell environment by defining color variables, clearing the console,
    importing necessary modules, and configuring the prompt and tab completion behavior.

.NOTES
    Author: Solorzano, Juan Jose.
    Date: [2021-09-01]
    Version: 3.1
#>
$RESET = "`e[0m"
$RED = "`e[31m"
$GREEN = "`e[32m"
$YELLOW = "`e[33m"
$BLUE = "`e[34m"
$MAGENTA = "`e[1;38;5;13m"
$CYAN = "`e[36m"
$WHITE = "`e[37m"
Clear-Host # clear the console.
# Import the necessary modules.
$exe_path = Get-Location # get the current directory.
Set-Location $HOME
$modules_path = 'C:\LegacyApp\Powershell_Suite\lib\{0}.psm1'
Import-Module -Name ($modules_path -f "GitComCom") -DisableNameChecking
Import-Module -Name ($modules_path -f "Helpers") -DisableNameChecking
Import-Module -Name ($modules_path -f "Remote") -DisableNameChecking
Import-Module -Name ($modules_path -f "vs-suite") -DisableNameChecking
Import-Module Terminal-Icons
$module_name = ($HOME + "\{0}.psm1" -f ".decode")
$module_exists = [System.IO.File]::Exists($module_name)
if($module_exists){Import-Module -Name $module_name -DisableNameChecking}
Set-Location $exe_path # return to the current directory.
# Shows the directories options.
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Shift+Tab -Function MenuComplete

# Sets the main prompt in the terminal
function prompt{
    $Host.UI.RawUI.WindowTitle = (Get-Location).Path
    Set-PSReadLineOption -Colors @{ Command = 'green' }
    Invoke-Starship
    # set icons in the terminal.
    $currentDir = (get-location).Path
    if($currentDir.Contains($HOME)){
        $currentDir = $currentDir.Replace($HOME, "🏠")
    }
    elseif($currentDir.Contains("D:\")) {
        $currentDir = $currentDir.Replace("D:\","📍\")
    }
    elseif($currentDir.Contains("C:\")) {
        $currentDir = $currentDir.Replace("C:\","\🐧")
    }
    if((Get-Location).Path.Contains("temp")){ # If the current directory is temp and the home directory
        if((Get-Location).Path.Contains($HOME)){
            $currentDir = "🏠\ "
        }
        else{
            $currentDir = "📍\ "
        }
    }
    # If the current directory is a work directory (VT, VT.prj)
    if((Get-Location).Path.ToLower().Contains("vt.prj.")){
        $tmp=$false
        $lct = $(Get-Location).Path
        if($lct.Contains("temp")){
            $tmp=$true
        }
        $suite_name=$(((Get-Location).Path).Split('\').where({$_ -like '*vt.prj*'}))
        if ($suite_name) {
            $name_part = $suite_name.ToLower().Split('vt.prj.')[1].Split('.')
            $suite_name = $name_part[1] #-join "."
        }
        $suite_child = ""
        if ((Get-Location).Path.Contains('vt.prj.ford.foh02.sys_test')) {
            $suite_child=$((Get-Location).Path).Split('vt.prj.ford.foh02.sys_test')[1]
        }
        $ta="${BLUE}[TA||$suite_name]${MAGENTA}"
        if ($tmp) {
            $currentDir = "$ta $($suite_child)"
        }
        else{
            $currentDir = "$ta$($suite_child)"
        }
    }
    # Print the current directories in the terminal.
    if ((Test-Path .git) -or (git rev-parse --abbrev-ref HEAD) ) {
        # If the current directory has a git repository.
        Write-Host ("" + $currentDir + "\\") -NoNewLine ` -ForegroundColor 13
        Write-BranchName
        Write-Host ("📝🔧") -NoNewLine ` -ForegroundColor 10
        return " "
    }else{
        Write-Host ("" + $currentDir+"\\") -NoNewLine ` -ForegroundColor 13
        Write-BranchName
        Write-Host ("-->") -NoNewLine ` -ForegroundColor 10
        return " "
    }
}
# This function writes the special characters of the current terminal used. 
function Invoke-Starship{
  $loc = $executionContext.SessionState.Path.CurrentLocation;
  $prompt = "$([char]27)]9;12$([char]7)"
  if ($loc.Provider.Name -eq "FileSystem")
  {
    $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
  }
  $host.ui.Write($prompt)
}
# This function overwrite the behavior of the 'tab' when you will select a new derectory.
function Tab-Completion {
    param([string]$Path = '.')
    # Get the list of directories and files
    $items = Get-ChildItem -Path $Path -Force | Select-Object -ExpandProperty Name
    # Show all items in a list
    if ($items.Count -gt 0) {
        $items | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "No items found"
    }
}
