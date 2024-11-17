#REQUIRES -Version 1.0
<#
.SYNOPSIS
	Helpers is a module created to facilte commands in powershell.
.DESCRIPTION
	There are many commands that you can use with the powershell profile.
.NOTES
    File Name      : GitComCom.psm1
    Author         : Solorzano, Juan Jose (uiv06924)
    Prerequisite   : PowerShell V1
#>

# Define ANSI escape codes for colors
$RESET = "`e[0m"
$RED = "`e[31m"
$GREEN = "`e[32m"
$GRAY = "`e[37m"
$YELLOW = "`e[33m"
$BLUE = "`e[34m"
$MAGENTA = "`e[38;5;13m"
$CYAN = "`e[36m"
$WHITE = "`e[37m"
$HELP = "${YELLOW}[?] Usage:`n    ${GREEN}PS> {0}${MAGENTA} {1}${RESET}"

function temp {
	cd "C:\Users\uiv06924\temp"
}
function BinToDec{
	param($value,[switch]$ToHex)
	$output = [convert]::ToInt32($value, 2)
	if($ToHex){
		return "0x$([convert]::ToString($output, 16))"
	}
	else {
		return $output
	}
}

function DecToBin {
	param($value,[switch]$ToHex)
	$output = [convert]::ToString($value, 2)
	if($ToHex){
		return BinToDec $output -ToHex
	}
	else {
		return "b$output"
	}
}

function Get-RecHours{
	[CmdletBinding()]
	$filePartialName = "Vitesco Technologies Jira 20"
	$baseFileName = "$home/Downloads/jira.csv"
	$exists = test-path -path $baseFileName
	if($exists){
		echo "[!] $baseFileName already exists"
		$ans = read-Host "[?]  Do you want remove it? [y/yes/n/no]"
		if($ans.contains("y")){
			remove-item $baseFileName
			$exists = $false
		}
	}
	if(-not $exists){
		$latestFile = (Get-ChildItem "$home\Downloads" | 
              Where-Object { $_.Name -like "*$filePartialName*" } | 
              Sort-Object LastWriteTime -Descending | 
              Select-Object -First 1).FullName
		$fileName = $latestFile.Name
		try{
			mv $latestFile $baseFileName
		}
		catch{
			echo "$RED[!] .csv files does not found.$RESET"
			return
		}
	}
	c:/LegacyApp/Python36/python.exe $home\Documents\PowerShell\lib\getJiraInfo.py
}
function Sum-Num {
	param([string[]]$parameters)
	return ($parameters | measure -sum).sum
}
function net {
    [CmdletBinding()]
    $command = $args
    $process = Start-Process -NoNewWindow -File C:\LegacyApp\dotnet\dotnet.exe -ArgumentList $command -PassThru -Wait
    # Wait for the process to complete
    $process.WaitForExit()
    # Check the exit code
    if ($process.ExitCode -ne 0) {
        Write-Host "Command failed with exit code: $($process.ExitCode)"
    }
}

function recycle{
    [CmdletBinding()]
    param([switch]$rmAll,[switch]$l)
    $shellComO = New-Object -ComObject Shell.Application
    $recycleF = $shellComO.Namespace(10)
    if($l){
        $recycleF.Items() | ForEach-Object{$_.Name}
    }
    elseif ($rmAll) {
        Clear-RecycleBin -Confirm:$false
    }
    else {
        Write-Host "$($HELP -f 'recycle','[-l <list items>] [-rmAll <Clear RecycleBin>]')"
    }
}

function del-pyc {
    $pycPath = Get-ChildItem -Recurse -Include "*.pyc"
    $pycachePath = Get-ChildItem -Recurse -Directory -Filter "__pycache__"
    if ($pycPath -or $pycachePath) {
        $pycPath | Remove-Item -Force
        $pycachePath | Remove-Item -Recurse -Force
        Start-Sleep -Seconds 1
    	Clear-Host
		Start-Sleep -Seconds 1
        echo "[+] Python cache files and directories removed."
    } else {
        echo "[!] No Python cache data found."
    }
}

function bat{
  param([string]$file,[string]$l)
  if($l){
      C:/LegacyApp/Python36/python.exe $home/Documents/PowerShell/lib/bat.py $file $l
  }
  else{
      C:/LegacyApp/Python36/python.exe $home/Documents/PowerShell/lib/bat.py $file
  }
}

function rec2json {
	[CmdletBinding()]
	param (
		[string]$file,
		[switch]$plot,
		[switch]$show
	)
	if($plot -And $show){
		C:\LegacyApp\Python36\py3.exe C:\Users\uiv06924\rec2json.py $file --plot --show
	}
	elseif($show){
		echo "show"
		C:\LegacyApp\Python36\py3.exe C:\Users\uiv06924\rec2json.py $file --show
	}
	elseif($plot){
		C:\LegacyApp\Python36\py3.exe C:\Users\uiv06924\rec2json.py $file --plot
	}
	else{
		C:\LegacyApp\Python36\py3.exe C:\Users\uiv06924\rec2json.py $file
	}
}

function juso {
	return '\\vt1.vitesco.com\loc\abh5\didf2412\P_H02\user\JuSo'
}
function profile{
	return 'C:\Users\uiv06924\documents\WindowsPowerShell'
}

function del-recurse($item){
	$command = "del $item /s"
	Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/C", $command
    Clear-Host
}

function goprofile {
	set-location 'C:\Users\uiv06924\Documents\WindowsPowerShell\'
}
function rm-readonly{
    Set-ItemProperty -Path "." -Name Attributes -Value ((Get-Item ".").Attributes -band -not [System.IO.FileAttributes]::ReadOnly)
}
function rc {
	#!/usr/bin/env pwsh
	echo "`e[6 q"
}
function bash {
    $curr_location = get-location
    $curr_location = $curr_location.path
    &"C:\Program Files\Git\bin\bash.exe"
    set-location $curr_location
}
function onedrive {
	Set-Location 'C:\Users\uiv06924\OneDrive - Vitesco Technologies'
}
function frepo{
	set-location "C:\Users\uids7040\git"
}

function Edge($page) {
	try {
		$temp_dir = Get-Location
		Set-Location "C:\Program Files (x86)\Microsoft\Edge\Application\"
		Start-Process "msedge.exe" $page 
		Set-Location $temp_dir.Path
	}
	catch {
		Start-Process "msedge.exe"
		Set-Location $temp_dir.Path
	}
}

function Google($page) {
	try {
		$temp_dir = Get-Location
		Set-Location "C:\Program Files\Google\Chrome\Application\"
		Start-Process "chrome.exe" $page 
		Set-Location $temp_dir.Path
	}
	catch {
		Start-Process "chrome.exe"
		Set-Location $temp_dir.Path
	}
}

function New-TaImplementation {
	<#
	.SYNOPSIS
		This functions is used to created new files for a new TA implementation.

	.DESCRIPTION
		Usage: New-TaImplementation [-parentFolder] [-filesName] [-project]
		Args:
			Write-Host "  [-parentFolder]: The folder where will be create the files, e.g. 'ISR' or 'core'."
        	Write-Host "  [-filesName]: The IRS or functionality name, e.g. 'Leakage' or 'core'."
        	jWrite-Host "  [-project]: The project name, e.g. 'ECU' or 'BMS'. If none, ECU is set."
        	Write-Host "Example: New-TaImplementation -parentFolder 'core' -filesName 'ewdt' -project 'ECU'"
		Exmple:
		    New-TaImplementation -parentFolder 'core' -filesName 'ewdt' -project 'ECU'.
			
	.PARAMETER ParameterName
		[-parentFolder]: The folder where will be create the files, e.g. 'ISR' or 'core'.
        [-filesName]: The IRS or functionality name, e.g. 'Leakage' or 'core'.
        [-project]: The project name, e.g. 'ECU' or 'BMS'. If none, ECU is set.

	.EXAMPLE
		New-TaImplementation -parentFolder 'core' -filesName 'ewdt' -project 'ECU'.

	.NOTES
	   Additional notes or information.
	#>
	[CmdletBinding()]
	param (
		[string]$parentFolder,
		[string]$filesName,
		[string]$project,
		[switch]$h
	)
	if ($h) {
        # Display help information
        Write-Host "Usage: New-TaImplementation [-parentFolder] [-filesName] [-project] [-h]"
        Write-Host "  [-parentFolder]: The folder where will be create the files, e.g. 'ISR' or 'core'."
        Write-Host "  [-filesName]: The IRS or functionality name, e.g. 'Leakage' or 'core'."
        Write-Host "  [-project]: The project name, e.g. 'ECU' or 'BMS'. If none, ECU is set."
        Write-Host "Example: New-TaImplementation -parentFolder 'core' -filesName 'ewdt' -project 'ECU'"
        return
    }
	if($null -ne $parentFolder){
		if($project -eq "ecu"){
			$zip_name = "ECU" 
		}
		elseif ($project -eq "bms") {
			$zip_name = "BMS"
		}
		else{$zip_name = "ECU"}
		$cwd = Get-Location
		$dirs = ls
		if($cwd.Path.Contains('work\ta') -or $dirs.Name.Contains('work')){
			$path = whereis -item $parentFolder -nV
			if($path){
				echo $path
				$psprofile = $PROFILE
				$lib_ps_path = $psprofile.replace('Microsoft.PowerShell_profile.ps1','lib')
				cp "$lib_ps_path\$zip_name.7z" $path
			}
			try {
				$current_location = pwd		
				cd $path
				if(-not $filesName){
					$filesName = "XXXX"
				}
				7z e "$zip_name.7z" -o"$filesName"
				rm "$zip_name.7z"
				Start-Sleep -Milliseconds 30
				cd $filesName
				$funct_items = ls
				foreach($item in $funct_items){
					if($item.Name.contains('XXXX')){
						mv $item $item.Name.replace('XXXX',$filesName)
					}
				}
				ls
				cd $current_location
			}
			catch {
			}
		}else{
			echo "No Suite Folder"
		}
	}else{
		echo "Type functionality is needed."
	}
	
}

function polarion {
	param ($item
	)
	$main_url = 'https://polarion.vitesco.io/polarion/#/project/FO020/'
	
	if($item){

		$request = $main_url + 'workitem?id=FO020-'+ $item
		Edge $request
		return
	}
	Edge $main_url
}

function Mlink ($target, $link){
	New-Item -Force -Path $link -ItemType SymbolicLink -Value $target
}
function b($n){

	$back_patern = '../'
	$multiplier = $n
	# Empty string to store the result.
	$total_back = ''

	if($null -eq $n){
		Set-Location $back_patern
	}
	else{
		# Repeating the string.
		for ($i = 1; $i -le $multiplier; $i++) {
		    $total_back += $back_patern
		}
		Set-Location $total_back
	}
}
function L($prj){
    
	$path = '\\vt1.vitesco.com\SMT\didt6804\99_Users\JuanJoseSolorzano\{0}'
	if($prj){$path = $path -f $prj}
	else{$path = $path -f ''}
	return $path
}
function L-User($user, $l){
	$path = 'L:\didt6804\99_Users\{0}'
	if($user){$path = $path -f $user}
	else{$path = $path -f ''}
	if($l){ls $path}
	return $path
}
function ll {
	Get-ChildItem -Force | Sort-Object Extension
}
function note ($file){
	C:\LegacyApp\Notepad++\notepad++.exe $file
}
function re {
	pwsh.exe
    echo "`e[6 q"
}

function eclipse ($file){
	if($null -eq $file){
		Start-Process "C:\LegacyApp\Eclipse_Contest\eclipse.exe"
	}
	else{
		Start-Process "C:\LegacyApp\Eclipse_Contest\eclipse.exe" $file
	}
}

function delete ($item){
    rm -Force -Recurse $item
}

function edit-globals {
	start-Process C:\WINDOWS\system32\rundll32.exe sysdm.cpl,EditEnvironmentVariables
}

function prj{
	[CmdletBinding()]
    param([string]$name,[string]$l30,[string]$l40,[switch]$g)
	$p_ta3 = "d:/p_ta3"
    $bms_suite = "vt.prj.ford.foh02.sys_test"
    function showDirOptions($directories) {
        Write-Host "${YELLOW}[!] ${CYAN}The project name given has multiple locations."
            $idx = 0
            foreach($location in $directories){
                $idx++
                Write-Host "  ${MAGENTA}[$idx] ${GREEN}$location"
            }
            $usr_selection = Read-Host "${YELLOW}[?]${CYAN} Which folder?${RESET}"
			echo "The user selection is: $usr_selection"
		    if($directories[$usr_selection-1]){
                $dir = $directories[$user_selection-1]
                if($g){
                    set-location (Get-ChildItem -Path $dir | Where-Object { $_.PSIsContainer -and $_.Name -eq "$bms_suite" }).FullName
                }
                else{
                    set-location $directories[$user_selection-1]
                }
            }
    }
    if($l30){
        $l30_path = "$p_ta3/FORD/BMS/H02/L30"
		if($l30 -eq "ls"){
			ls "$l30_path"
		}
		else{
        	$dir_match = $(Get-ChildItem -Recurse -Force -Path $l30_path -Filter "$l30" | Where-Object {$_.PSIsContainer}).FullName
        	if($dir_match){
        	    if($dir_match.GetType().BaseType.Name -eq "Array"){
        	        showDirOptions $dir_match
        	    }else{
        	        if($g){
        	            set-location (Get-ChildItem -Path $dir_match | Where-Object { $_.PSIsContainer -and $_.Name -eq "$bms_suite" }).FullName
        	        }
        	        else{
        	            set-location $dir_match
        	        }
        	    }
        	}else {
        	    Write-Host "${RED}[!] >> Directory not found. ${CYAN}'[$l30]'${RESET}"
        	}
		}
    }elseif ($l40) {
        $l40_path = "$p_ta3/FORD/BMS/H02/L40"
		if($l40 -eq "ls"){
			ls "$l40_path"
		}else{
        	$dir_match = $(Get-ChildItem -Recurse -Force -Path $l40_path -Filter "$l40" | Where-Object {$_.PSIsContainer}).FullName
        	if($dir_match){
        	    if($dir_match.GetType().BaseType.Name -eq "Array"){
        	        showDirOptions $dir_match
        	    }else{
        	        if($g){
        	            set-location (Get-ChildItem -Path $dir_match | Where-Object { $_.PSIsContainer -and $_.Name -eq "$bms_suite" }).FullName
        	        }
        	        else{
        	            set-location $dir_match
        	        }
        	    }
        	}else {
        	    Write-Host "${RED}[!] >> Directory not found. ${CYAN}'[$l40]'${RESET}"
        	}
		}
    }elseif ($name) {
		if($name -eq "l30"){
			Set-Location "D:\p_ta3\FORD\BMS\H02\L30"
			return
		}
		elseif($name -eq "l40") {
			Set-Location "D:\p_ta3\FORD\BMS\H02\L40"
			return
		}
		else{
        	$dir_match = $(Get-ChildItem -Recurse -Force -Path $p_ta3 -Filter "$name" | Where-Object {$_.PSIsContainer}).FullName
        	if($dir_match){
        	    if($dir_match.GetType().BaseType.Name -eq "Array"){
        	        showDirOptions $dir_match
        	    }else{
        	        if($g){
        	            set-location (Get-ChildItem -Path $dir_match | Where-Object { $_.PSIsContainer -and $_.Name -eq "$bms_suite" }).FullName
        	        }
        	        else{
        	            set-location $dir_match
        	        }
        	    }
        	}else {
        	    Write-Host "${RED}[!] >> Directory not found. ${CYAN}'/$name/'${RESET}"
        	}
		}
    }else{
        Write-Host "$($HELP -f 'prj','[-name<default>] [-L30<opt>] [-L40<opt>]')"
    }
}

function edge {
	param($target)
	try 
	{
	    start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" $target    
	}
	catch {
	    start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
	}	
}

function get-sw{
	[CmdletBinding()]
	param (
		[switch]$g70,
		[switch]$g80,
		[switch]$bms,
		[switch]$fc1,
		[switch]$fb0,
		[string]$r
	)

	if($g70){
		$root = "D:\p\GM\G70\"
		return 
	}
	elseif ($g80) {
		Write-Host "[!] No implemented yet."
	}
	elseif ($bms) {
		$root = "D:\p\Ford\bms\"
		$main_folder_name = '\_FOH02_0U0_NORMAL'
		if ($r){
			$target = $root+$r+"\"
		}
		else{

			$target = ((Get-ChildItem $root | Sort-Object Name | Select-Object -Last 1).FullName)
		}
		$main_folder = "$target$main_folder_name"
		Set-Clipboard (grep "GERRIT_PATCHSET_REVISION" ($target + "\gerrit_variables.properties") | awk -F"=" '{print $2}').replace(' ','')
		Set-Clipboard "$target$main_folder_name"
		echo "PATH = $main_folder"
		echo (grep "GERRIT_PATCHSET_REVISION" ($target + "\gerrit_variables.properties"))
	}
	elseif ($fc1){
		Write-Host "[!] No implemented yet."
	}
}

function vi {
	[CmdletBinding()]
    param ([string]$file,[switch]$w)
	try{
		# Remove the ./ character 
		if($file.Contains('.\')){$file=$file.replace('.\','')}
	}catch{}
	$temp_path = Get-Location
	$root_file = $temp_path.Path +'\'+ $file
	Set-Location "C:\Program Files\Git\usr\bin\" 
	if($w){
		Start-Process "vim.exe"$root_file
	}else{
		.\vim.exe $root_file
	}
	Set-Location $temp_path.path
}
#####################################################
#get the parameters by console line
#####################################################
function whereis{
	[CmdletBinding()]
    param([string]$item,[string]$path,[switch]$nV,[switch]$setClipboard)

	#Constants
	$vvv = "
		------------- Searching for < $item > -------------
		----- you can stop the search using 'ctr+c' -----
	searching...
	"
	$help_str = "Parameters:
		-item:: the file that you want to search
		-path:: the location where you want to search
		-vvv:: it shows the information"

	#Search the file.
	if($item -And -not $path){
		$ret_path = Get-ChildItem -Force -Filter $item -Recurse 2> $null
	}
	elseif($item -and $path){
		$ret_path = Get-ChildItem -Force -Path $path -Filter $item -Recurse 2> $null
	}	
	else
	{
		help $MyInvocation.MyCommand.Name
		Write-Host $help_str
	}
	##### returns #####
	if(-not $ret_path){
		return "[!]>> '$item' NOT FOUND !!!!!"
	}
	if(-not $nV){
		Write-Host $vvv
		Write-Host "Item found at:"
		if($ret_path.GetType().FullName -eq 'System.IO.FileInfo'){
			Set-Clipboard $ret_path.FullName
		}
		if($setClipboard){
			$i = 0
			foreach($_path in $ret_path){
				$i++
				Write-Host "[$i]>>"$_path.FullName
			}
			$idx = Read-Host "Select the number of the desire path"
			if($idx){
				if($ret_path[$idx-1]){Set-Clipboard $ret_path[$idx-1].FullName.trim()}
				else{"$idx not in the array."}
			}
		}else{
			return $ret_path.FullName
		}
	}
	else{
		return $ret_path.FullName
	}
}
function Get-ComMethods {
	<#
	.SYNOPSIS
	    Lists the methods and properties of a specified COM object.
	.DESCRIPTION
	    The Get-ComMethods function retrieves and displays the names of methods and properties
	    available for a given object in PowerShell. This is particularly useful for exploring COM objects,
	    such as those used for Microsoft Excel, to understand the functionalities they offer.
	.PARAMETER obj
	    [object] The COM object whose methods and properties are to be listed. This parameter is mandatory.
	.PARAMETER name
	    [string] Optional. A string that specifies the name of the object being examined. This is used for 
	    display purposes to indicate which object's methods and properties are being listed.
	.EXAMPLE
	    Get-MethodsAndProperties -obj $excel -name "Excel.Application"
	    This example lists the methods and properties of the Excel Application object.
	.EXAMPLE
	    Get-MethodsAndProperties -obj $workbooks -name "Workbooks"
	    This example lists the methods and properties of the Workbooks collection object.
	.NOTES
	    Author: Solorzano, Juan Jose
	    Version: 1.0
	#>
    param (
        [Parameter(Mandatory=$true)]
        [object]$obj,
        [string]$name = ""
    )
    Write-Host "`n$name Methods and Properties:"
    $members = $obj | Get-Member

    foreach ($member in $members) {
        if ($member.MemberType -eq "Method" -or $member.MemberType -eq "Property") {
            Write-Host $member.Name
        }
    }
}

function Get-ComObject{
	param($name)
	return New-Object -ComObject $name
}
function Insert-line($filePath,$stringToFind,$insertedString){
	# Specify the string you want to insert with a line break
	$insertedString = "`r`n$insertedString"  # Use `r`n for a line break
	$fileContent = Get-Content -Path $filePath
	# Find the line number that contains the specified string
	$lineNumber = 1
	foreach ($line in $fileContent) {
    	if ($line.contains($stringToFind)) {
        		break
    		}
    	$lineNumber++
	}
	# Check if the string was found
	if ($lineNumber -le $fileContent.Count) {
    # Insert the string with a line break after the line that contains the specified string
		if($lineNumber -eq 1){
    		$fileContent[$lineNumber - 1] += $insertedString
		}else{
			$class_name = $fileContent[$lineNumber-2]
    		$fileContent[$lineNumber - 2] += $insertedString
		}
	} else {
    	Write-Host "String '$stringToFind' not found in file."
	}
	# Write the modified content back to the file
	$fileContent | Set-Content -Path $filePath
	try {
		return $class_name.split()[1].split(':')[0].Split('(')[0]
	}
	catch {
		return
	}
}

function gerrit{

	Edge "https://gerrit.vitesco.io/gitweb?p=SW/10_PRJ/FOH02_0U0_000.git;a=summary"

}

function set-globals {
    [CmdletBinding()]
    param (
        [string]$VarName,     # The environment variable name
        [string]$Value,      # The value to set (ignored if removing)
        [string]$rm          # To indicate if we are removing the variable
    )
    if ($rm -ne $null -and $rm -ne "") {
        [System.Environment]::SetEnvironmentVariable($rm, $null, 'User')
        Remove-Item "Env:$rm" -ErrorAction SilentlyContinue
        Write-Host "Environment variable '$rm' removed."
    }
    else {
        [System.Environment]::SetEnvironmentVariable($VarName, $Value, 'User')
		Set-Variable -Name $VarName -Value $Value -Scope Global
        Write-Host "Environment variable '$VarName' set to '$Value'."
    }
}

function psgrep{
    param($string)
    Where-Object {$_.name -like "$string"}
}

function cdll {
	param($cfile,$name)
	if($cfile){
		if($name){
			$name=$name.split(".")[0]
			$dll_name="$name.dll"
		}else{
			$_cfile=$cfile.replace(".c","")
			$dll_name="$_cfile.dll"
		}
	}else{
		echo "$($HELP -f 'cdll','[<file.c>]')"
        echo "      ${YELLOW}-or: ${GREEN}gcc ${MAGENTA}-shared -o [<dll_name.dll>] [<file.c>]${RESET}"
		return
	}
	gcc -shared -o $dll_name $cfile	
	echo "[+] $dll_name created"
}
function Del-line($filePath,$stringToFind){
	# Specify the string you want to insert with a line break
	$insertedString = ""  # Use `r`n for a line break
	$fileContent = Get-Content -Path $filePath
	# Find the line number that contains the specified string
	$lineNumber = 1
	foreach ($line in $fileContent) {
    	if ($line.contains($stringToFind)) {
        		break
    		}
    	$lineNumber++
	}
	# Check if the string was found
	if ($lineNumber -le $fileContent.Count) {
    # Insert the string with a line break after the line that contains the specified string
		if($lineNumber -eq 1){
    		$fileContent[$lineNumber-1] += $insertedString
		}else{
    		$fileContent[$lineNumber - 2] += $insertedString
		}
	} else {
    	Write-Host "String '$stringToFind' not found in file."
	}
	# Write the modified content back to the file
	$fileContent | Set-Content -Path $filePath
}

function get-passwd([string]$target){
	if($target){
		if($target.Contains("BLN")){get-bln -h}
		elseif($target.Contains("CHN")){get-chn -h}
		elseif($target.Contains("GDL")){get-gdl -h}
		elseif($target.Contains("ABH")){get-abh -h}
		elseif($target.Contains("RGB")){get-rgb -h}
		else {"[!] $target no found"}
	}else{
		echo "[!] Parameter needed"
	}
}
function infopath($file){
    $temp_loc = get-location
	$root_file = $temp_loc.Path +'\'+ $file
    set-location 'C:\Program Files (x86)\Microsoft Office\Office15'
    start-process 'INFOPATH.EXE' $root_file
    set-location $temp_loc
}

function Set-PyEnv() {
	echo "*********************************************************************"
	echo "*********************************************************************"
	echo "		Wellcome to Python environment :) "
	echo "*********************************************************************"
	echo "[!] Searching for Python interperter..."
	echo " "
	Start-Sleep -Seconds 0.6
	$pythonPaths = Get-Command python*.exe -All
	$pythonPaths = $pythonPaths | Sort-Object
	if ($pythonPaths) {
		$cnt=0
	    Write-Host "Python is installed in the following locations:"
	    foreach ($path in $pythonPaths) {
	        Write-Host "  $cnt-"$path.Source
			$cnt++
	    }
		echo " "
		$interpreter = Read-Host "Select a python interperter"
		echo ""
		$tst = $pythonPaths[$interpreter].Source
		$lib = "Lib"
		$site_module = "\site.py"
		$ta_module = "\own_env.py"
		$py_exe = $pythonPaths[$interpreter].Name
		$py_rootpath = $pythonPaths[$interpreter].Source
		$py_path = $py_rootpath.replace($py_exe,'')
		$py_lib = $py_path + $lib 
		$py_lib_dir = $py_lib + $ta_module
		$site_path = $py_lib + $site_module
		$ta_file = ($PROFILE | Split-Path) + "\lib\own_env"
		cp $ta_file $py_lib_dir 
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo "[+] '$py_rootpath' has been updated."
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
	} else {
	    Write-Host "Python is not installed or not in the system's PATH."
	}
}

function pydocstring {
	[CmdletBinding()]
    param([string]$file)
	$docstring = '    """
	@Public_class: <class_name>.
    @Implementation_comments:
        The @Test_objective, @Test_procedure, and @Expected_values sections are not official Test Specification documents.
        These definitions serve as a guide for TA implementation and are based on the "<test_spec_name" test spec file: 
			<link>//https:
        If you need to review official documentation, please contact the TA team members first.
    @Test_objective:
		_summary_
    @Test_procedure (stimulation phase):
		1. _step_
		2. _step_
    @Expected_values:
        -------------------------------------------------------------
        | Steps |                    Expected                       |
        =============================================================
        |   1   | _summary_						                    |
        -------------------------------------------------------------
    @Attributes:
        - _summary_.
	"""'
	if($file){
		if(-not $file.Contains('.py')){
			$file = "$file.py"
		}
		$file_path = whereis $file -nV
		$class_name = Insert-line $file_path "#{class}#" $docstring
		Insert-line $file_path "<class_name>" "    @Public_class: $class_name"
	}else{
		Write-Host "[!] A file name is required."
	}
}
function Get-Size{
    param([string]$item,[switch]$m,[switch]$b,[switch]$g,[switch]$h)
    if(($null -eq $item) -or $h){
       Write-Host "$($HELP -f 'Get-Size','[-item] [-m <show size in Megasbytes] [-b <show size in Bytes]')"
       return
    }
    elseif ($m) {
       echo "${YELLOW}$((gci -path $item -recurse | measure-object -property length -sum).sum /1Mb) Mb${RESET}"
    }
    elseif ($b) {
       echo "${YELLOW}$((gci -path $item -recurse | measure-object -property length -sum).sum) B${RESET}"
    }
    elseif ($g) {
       echo "${YELLOW}$((gci -path $item -recurse | measure-object -property length -sum).sum /1Gb) Gb${RESET}"
    }
    elseif ($item) {
       echo "${GREEN}$item -> ${YELLOW}$((gci -path $item -recurse | measure-object -property length -sum).sum /1Mb) Mb${RESET}"
    }
    else {
       echo "${GREEN}$(Get-Location) -> ${YELLOW}$((gci -path $item -recurse | measure-object -property length -sum).sum /1Mb) Mb${RESET}"
    }

}

function cpright {
	[CmdletBinding()]
    param([string]$file)
	$docstring = '# -*- coding: UTF-8 -*-
# ************************************************************************************************************#
# COPYRIGHT (C) Vitesco Technologies                                                                          #
# ALL RIGHTS RESERVED.                                                                                        #
#                                                                                                             #
# The reproduction, transmission or use of this document or its                                               #
# contents is not permitted without express written authority.                                                #
# Offenders will be liable for damages. All rights, including rights                                          #
# created by patent grant or registration of a utility model or design,                                       #
# are reserved.                                                                                               #
# ------------------------------------------------------------------------------------------------------------#
# Purpose:    Test Automation Framework                                                                       #
# ************************************************************************************************************#
# Tool chain: $Python:    3.6                                                                                 #
# Filename:   $WorkFile:  <module_name>.py                                                                    #
# Depencies:  $WorkFile:  <libraries used> 												       				  #
# Revision:   $Revision:  1.0                                                                                 #
# Author:     $Author:    <developer_name> <(uid12345)>                                                       #
# Date:       $Date:      --/--/--                                                                            #
# ************************************************************************************************************#
# Module information:                                                                                         #
# ------------------------------------------------------------------------------------------------------------#
# Revisions:                                                                                                  #
# ************************************************************************************************************#
'
	if($file){
		if(-not $file.Contains('.py')){
			$file = "$file.py"
		}
		$file_path = whereis $file -nV
		Insert-line $file_path "#{cpright}#" $docstring
	}else{
		Write-Host "[!] A file name is required."
	}
}
