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
$POWERSHELL = "\PowerShell\"

function Get-CpuUsage {
  param([switch]$showProcess)
  $usage=[math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue,2)
  $mem = Get-CimInstance Win32_OperatingSystem
$memory = [math]::Round((($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100, 2)
  Write-Host "======================================================="
  Write-Host "          -       Cumputer Usage         -"
  Write-Host "======================================================="
  Write-Host "CPU: $usage%"
  Write-Host "Memory: $memory%"
  if($showProcess){
    Get-CimInstance Win32_Process | 
    Select-Object Name, @{Name="MemoryUsageMB"; Expression={[math]::Round($_.WorkingSetSize / 1MB, 2)}} |
    Sort-Object MemoryUsageMB -Descending | Select-Object -First 15 Name, MemoryUsageMB
  }
}

function RmProc {
	param([string]$name)
	if(-not $name){
		Write-Host "[?] Usage:`n`t>> rmProc [process name]"
		return
	}
	if($name.Contains('.')){
		$name = $name.split('.')[0]
	}
	try {
		kill -processName $name
		Write-Host "[+] The process `"$name`" was removed."
	}
	catch {
		Write-Host "[!] Error: $name is still running ..."
	}
}

function mktemp {
	[CmdletBinding()]
	param([string]$name,[switch]$go)
	$tmpPath = [System.IO.Path]::GetTempPath()
	if(-not $name){
		$tmpName="temp_folder"
		Remove-Item -Force -Recurse -Path "$tmpPath\$tmpName" 2>$null
	}
	else{$tmpName = $name}
	$rootTempPath = Join-Path $tmpPath $tmpName
	New-Item -Path $rootTempPath -ItemType Directory > $null
	write-host $rootTempPath
	if($go){set-location $rootTempPath}
}

function set-note {
	param([string]$head,[string]$note)
	if(-not $head){
		$head="[General]"
	}
	if($note){
		$outlook = New-Object -ComObject Outlook.Application
		$appointment = $outlook.CreateItem(1)
		$appointment.Subject = "[NOTES]$head".ToUpper()
		$appointment.Body = "$note"
		$appointment.AllDayEvent = $true
		$appointment.ReminderSet = $false
		$appointment.Save()
		$appointment = $null
		$outlook = $null
	}else{
		Write-Host "[!] The content note is necessary."
	}
}

function get-notes {
	[CmdletBinding()]
	param([string]$prj,[string]$date,[switch]$today,[switch]$month,[switch]$h)
	$outlook = New-Object -ComObject Outlook.Application
	$namespace = $outlook.GetNamespace("MAPI")
	$calendarFolder = $namespace.GetDefaultFolder(9) # 9 corresponds to olFolderCalendar
	if($h){
		Write-Host "> Get-Logwork -date '2023-10-25'"
		return
	}
	if(-not $date){
		$date=Get-Date
		$specific_date=$false
	}else{
		$specific_date=$true
	}
	$calendarItems = $calendarFolder.Items
	$calendarItems.Sort("[Start]")
	$calendarItems.IncludeRecurrences = $true
	if($month){
		$monthStart = Get-Date -Year (Get-Date).Year -Month (Get-Date).Month -Day 1
		$monthEnd = $monthStart.AddMonths(1)
		# Create a filter to get appointments for the current month
		$filter = "[Start] >= '" + $monthStart.ToString("g") + "' AND [Start] < '" + $monthEnd.ToString("g") + "'"
	}
	elseif($today){
		$start = $date.Date
		$end = $date.Date.AddDays(1)
		# Create a filter to get appointments for the specific date
		$filter = "[Start] >= '" + $start.ToString("g") + "' AND [Start] < '" + $end.ToString("g") + "'"
	}else{
		$yearStart = Get-Date -Year (Get-Date).Year -Month 1 -Day 1
		$yearEnd = Get-Date -Year (Get-Date).Year -Month 12 -Day 31 -Hour 23 -Minute 59 -Second 5
		# Create a filter to get appointments for the current year
		$filter = "[Start] >= '" + $yearStart.ToString("g") + "' AND [Start] < '" + $yearEnd.ToString("g") + "'"
	}
	$filteredItems = $calendarItems.Restrict($filter)
	# Initialize arrays to hold all-day and normal appointments
	$allDayAppointments = @()
	foreach($appointment in $filteredItems) {
    	if ($appointment.AllDayEvent -eq $true) {
        	$allDayAppointments += $appointment
    	}
	}
	# return
	if(-not $prj){
		foreach ($appointment in $allDayAppointments) {
			if($specific_date){
				$event_date = Get-Date "$($appointment.Start.ToString().Split(" ").Get(0))"
				$target_date = [datetime]::ParseExact($date, 'dd-MM-yyyy', $null)
				if($event_date -eq $target_date){
					Write-Host "$($appointment.Subject) - $($appointment.Start.ToString().Split(" ").Get(0))"
					Write-Host "$($appointment.Body)"
					Write-Host "-----"
				}
			}else{
				Write-Host "$($appointment.Subject) - $($appointment.Start.ToString().Split(" ").Get(0))"
				Write-Host "$($appointment.Body)"
				Write-Host "-----"
			}
		}	
	}else{
		foreach($appointment in $allDayAppointments) {
			if($appointment.Subject.Contains($prj.ToUpper())){
				if($specific_date){
					$event_date = Get-Date "$($appointment.Start.ToString().Split(" ").Get(0))"
					$target_date = [datetime]::ParseExact($date, 'dd-MM-yyyy', $null)
					if($event_date -eq $target_date){
						Write-Host "$($appointment.Subject) - $($appointment.Start.ToString().Split(" ").Get(0))"
						Write-Host "$($appointment.Body)"
						Write-Host "`n"
					}
				}else{
					Write-Host "$($appointment.Subject) - $($appointment.Start.ToString().Split(" ").Get(0))"
					Write-Host "$($appointment.Body)"
					Write-Host "`n"
				}
			}
		}
	}
}

function deprecated_notes{
    [CmdletBinding()]
    param([string]$data,
          [string]$date,
		  [string]$grep,
          [switch]$open,
          [string]$go,
          [switch]$ls,
          [string]$get,
          [switch]$b,
          [string]$prj)
    $availableProjects = @("fc1","fb0","l30","l40","g70","g80","general")
    $notesPath = "C:\Users\uiv06924\OneDrive - Vitesco Technologies\mynotes\"
    function help {Write-Host "$> notes -prj [$availableProjects]"}
    $currLocation = (Get-Location).Path
    if($go){
		if($go -eq "."){set-location $notesPath}
		else{Set-Location $notesPath$go}
		return
	}
    elseif(-not $prj -and -not $get) {help; return}
    if($prj -and -not $get){
        $prj = $prj.ToLower()
        # WRITE NOTES
        if($availableProjects.Contains($prj)){
            if ($ls){Get-ChildItem "$notesPath$prj";return}
            Set-Location "$notesPath$prj"
            $currentDate = (Get-Date -Format "dd_MM_yyyy").ToString()
            $dayNote = $currentDate+".txt"
            if(Test-Path $dayNote){
                nvim $dayNote
            }else{
                New-Item -ItemType file -Name $dayNote
                nvim $dayNote
            }
        }else{Write-Host "Project `"$prj`" not found."}
    }
    # GET NOTES DATA
    elseif($get){
        Set-Location "$notesPath$get"
        if($date){
            $dayFormated = $("$date-$(get-date -Format "yyyy")").ToString().Replace("-","_")
            $dateNote=$dayFormated+".txt"
            if(Test-Path $dateNote){
                if($b){bat $dateNote}else{cat $dateNote}
            }else{Write-Host "No date note found."}
        }else{
            $currentDate = (Get-Date -Format "dd_MM_yyyy").ToString()+".txt"
            if(Test-Path $currentDate){
                if($b){bat $currentDate}else{cat $currentDate}
            }else{Write-Host "Nothing to read ..."}
        }
    }
	elseif($grep){
		
	}
	else{Write-Host "Project `"$prj`" not found."}
    Set-Location $currLocation
}

function whatis {
	[CmdletBinding()]
	param([string]$word,[switch]$pronunce)
	if(-not $word){Write-Host "Usage: `n>> whatis -word 'any' -pronunce[optional]";return}
	$response = Invoke-WebRequest -Uri "https://api.dictionaryapi.dev/api/v2/entries/en/$word"
	$meaning = ($response.Content | ConvertFrom-Json -Depth 1000).meanings
	Write-Host $meaning.definitions.definition	
	Write-Host "[?] Synonyms:"
	Write-Host $meaning.synonyms
	if($pronunce){
		$phonetics = ($response.Content | ConvertFrom-Json -Depth 1000).phonetics
		google $phonetics.audio.get(1)
	}
}

function Set-Logwork {
	[CmdletBinding()]
	param([string]$title,[string]$start,[string]$end,[string]$note)
	try {
	    $outlook = New-Object -ComObject Outlook.Application
	} catch {
	    Write-Host "Error: Unable to start Outlook. Ensure it is installed."
		return
	}
	if(-not $start.Contains(":")){
		$start = "$start"+":00"
	}
	if(-not $end.Contains(":")){
		$end = "$end"+":00"
	}
	$date = Get-Date
	$start_date = Get-Date "$($date.Year)-$($date.Month.ToString("00"))-$($date.Day.ToString("00")) $start"
	$end_date = Get-Date "$($date.Year)-$($date.Month.ToString("00"))-$($date.Day.ToString("00")) $end"
	# Create a new appointment item
	$appointment = $outlook.CreateItem(1) # 1 indicates an AppointmentItem
	# Set the appointment properties
	$appointment.Subject = "$title"
	$appointment.Body = "NOTES: `n$note"   
	$appointment.Start = $start_date
	$appointment.End = $end_date
	$appointment.ReminderSet = $false                                             
	#$appointment.ReminderMinutesBeforeStart = 15                                     
	$appointment.Save()
	$appointment = $null
	# Optionally, you can quit Outlook if you opened it
	# $outlook.Quit()  # Uncomment to close Outlook
	$outlook = $null
	Write-Host ">> Work Logged"
}

function Get-Logwork {
	[CmdletBinding()]
	param([string]$date,[switch]$h)
	if($h){
		Write-Host "> Get-Logwork -date '2023-10-25'"
		return
	}
	if(-not $date){
		$date=Get-Date
	}
	write-host "===================================================================="
	write-host "  		  TIME WORKED"
	write-host "===================================================================="
	# Create an Outlook Application COM object
	$outlook = New-Object -ComObject Outlook.Application
	$namespace = $outlook.GetNamespace("MAPI")
	$calendarFolder = $namespace.GetDefaultFolder(9) # 9 corresponds to olFolderCalendar
	$specificDate = Get-Date $date # Change this to your desired date
	$start = $specificDate.Date
	$end = $specificDate.Date.AddDays(1)
	$calendarItems = $calendarFolder.Items
	$calendarItems.Sort("[Start]")
	$calendarItems.IncludeRecurrences = $true
	$results = @()  # Initialize as an empty array
	$totalDuration = [System.TimeSpan]::Zero
	$filter = "[Start] >= '" + $start.ToString("g") + "' AND [Start] < '" + $end.ToString("g") + "'"
	$filteredItems = $calendarItems.Restrict($filter)
	$bms_time = 0
	$ecu_time = 0
	# Iterate through filtered appointments and output details
	foreach ($item in $filteredItems) {
		if($item.Subject.Contains("[BMS]") -or $item.Subject.Contains("[ECU]") -and -not $item.Subject.Contains("[NOTES]")){
	    	$duration = $item.End - $item.Start
			if($item.Subject.Contains("[BMS]")){
				$bms_time += $duration
			}elseif($item.Subject.Contains("[ECU]")){
				$ecu_time += $duration
			}
			$totalDuration += $duration
			$result = [PSCustomObject]@{
            Subject  = $item.Subject
            Duration = $duration
			Note = $item.Body}
        	$results += $result
		}
	}
	$sortedResults = $results | Sort-Object {
    	if ($_.Subject -like "*[BMS]*") { 0 }
    	elseif ($_.Subject -like "*[ECU]*") { 1 }
    	else { 2 }
	}, { $_.Subject }  # Optionally sort alphabetically within groups

	if ($sortedResults.Count -gt 0) {
	    $sortedResults | Format-Table -AutoSize
		Write-Host " BMS: $bms_time"
		Write-Host " ECU: $ecu_time"
		Write-Host " Total: $totalDuration"
	} else {
	    Write-Output "No appointments found with the specified criteria."
	}
	write-host "===================================================================="
}

function temp {
	cd "$($home)\temp"
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
    $process = Start-Process -NoNewWindow -File C:\LegacyApp\dotnet8\dotnet.exe -ArgumentList $command -PassThru -Wait
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
      C:/LegacyApp/Python39/python.exe $home/PowerShell/lib/bat.py $file $l
  }
  else{
      C:/LegacyApp/Python39/python.exe $home/PowerShell/lib/bat.py $file
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
		C:\LegacyApp\Python39\python3.exe $home\rec2json.py $file --plot --show
	}
	elseif($show){
		echo "show"
		C:\LegacyApp\Python39\python3.exe $home\rec2json.py $file --show
	}
	elseif($plot){
		C:\LegacyApp\Python39\python3.exe $home\rec2json.py $file --plot
	}
	else{
		C:\LegacyApp\Python39\python3.exe $home\rec2json.py $file
	}
}

function juso {
	[CmdletBinding()]
	param([switch]$go)
	$path = '\\vt1.vitesco.com\loc\abh5\didf2412\P_H02\user\JuSo'
	if($go){
		set-location $path
	}else{
		return $path
	}
}
function profile{
	[CmdletBinding()]
	param([switch]$go)
	$path = "$($home)\PowerShell"
	if($go){
		set-location $path	
	}else{
	return $path
	}
}

function del-recurse($item){
	$command = "del $item /s"
	Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/C", $command
    Clear-Host
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
    param([string]$name,[string]$opt,[switch]$go)
	$p_ta3 = "d:/p_ta3"
    $bms_suite = "vt.prj.ford.foh02.sys_test"
    function showDirOptions($directories,$opt) {
        Write-Host "${YELLOW}[!] ${CYAN}The project name given has multiple locations."
            $idx = 0
            foreach($location in $directories){
                Write-Host "  ${MAGENTA}[$idx] ${GREEN}$location"
                $idx++
            }
            $usr_selection = Read-Host "${YELLOW}[?]${CYAN} Which folder?${RESET}"
			$selection = [int]$usr_selection
		    if($directories){
                $dir = $directories.Item($selection)
				if($opt -eq "ls"){
					ls $dir
					return
				}
                if($go){
                    set-location (Get-ChildItem -Path $dir | Where-Object { $_.PSIsContainer -and $_.Name -eq "$bms_suite" }).FullName
                }
                else{
                    set-location $dir
                }
            }
    }
    if($name -eq "l30"){
        $l30_path = "$p_ta3/FORD/BMS/H02/L30"
		if($opt -eq "ls"){
			ls "$l30_path"
			return
		}else{
			set-location $l30_path
			return
		}
    }elseif($name -eq "l40"){
        $l40_path = "$p_ta3/FORD/BMS/H02/L40"
		if($opt -eq "ls"){
			ls "$l40_path"
			return
		}else{
			set-location $l40_path
			return
		}
	}elseif($name){
        	$dir_match = $(Get-ChildItem -Recurse -Force -Path $p_ta3 -Filter "$name" | Where-Object {$_.PSIsContainer}).FullName
        	if($dir_match){
        	    if($dir_match.GetType().BaseType.Name -eq "Array"){
        	        showDirOptions $dir_match $opt
        	    }else{
        	        if($g){
        	            set-location (Get-ChildItem -Path $dir_match | Where-Object { $_.PSIsContainer -and $_.Name -eq "$bms_suite" }).FullName
        	        }
					elseif($opt -eq "ls"){
						ls $dir_match
					}
        	        else{
        	            set-location $dir_match
        	        }
        	    }
        	}else {
        	    Write-Host "${RED}[!] >> Directory not found. ${CYAN}'$p_ta3/$name/'${RESET}"
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
		set-Clipboard $docstring
		Write-Host $docstring
	}
}
