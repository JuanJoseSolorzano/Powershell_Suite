<#
Copyright (c) 2021-2025 Solorzano, Juan Jose
All rights reserved.

This file is part of the PowerShell Suite project and is licensed under the MIT License.
See the LICENSE file in the project root for more information.
#>
#REQUIRES -Version 1.0
<#
.SYNOPSIS
	GitComCom is a module created to facilte the git commands in powershell.
.DESCRIPTION
	There are many commands that you can use with the powershell profile.
.NOTES
	File Name      : GitComCom.psm1
	Author         : Solorzano, Juan Jose (uiv06924)
	Prerequisite   : PowerShell V 1.0
#>

# Constants for GIT commands
$USER_NAME = "<Name of the user>" # Replace with your GitHub username.
$SUITE_PATH = "C:\LegacyApp\Powershell_Suite" # Path to the PowerShell Suite directory.

# Imports
$exe_path = Get-Location
Set-Location $HOME
$modules_path = "$SUITE_PATH\lib\{0}.psm1"
Import-Module -Name ($modules_path -f "Helpers") -DisableNameChecking
Set-Location $exe_path

<#
.SYNOPSIS
	Write-BranchName function displays the current branch name and its status in the terminal.
	DO NOT MODIFY THIS FUNCTION, IT IS USED IN THE PROMPT.
#>
function Write-BranchName {
	$marks = "<{}>"

	if((test-path -Path ".git") -or (git rev-parse --abbrev-ref HEAD) ){
		try {
			# Get the current branch name
			$branch = git rev-parse --abbrev-ref HEAD
			# Check if the branch is null (detached HEAD) or if we're in a newly initialized repo
			if ($null -eq $branch -or $branch -eq "HEAD") {
				# In detached HEAD state, show the short SHA
				$commitCount = git status --porcelain
				$commitHead = git rev-parse --short HEAD
				if (($null -eq $commitCount) -and ($null -eq $commitHead)) {
					# Repository is empty
					Write-Host $marks.Replace("{}", " None") -ForegroundColor "yellow" -NoNewLine
					return
				}
				elseif((git status --porcelain).Contains('??')){
					Write-Host $marks.Replace("{}", " None") -ForegroundColor "yellow" -NoNewLine
					return
				}
				elseif($commitHead){
					Write-Host $marks.Replace("{}", "$branch") -ForegroundColor "yellow" -NoNewLine
					return
				}
				elseif ((git status --porcelain).Contains('A')) {
					Write-Host $marks.Replace("{}", "None") -ForegroundColor "yellow" -NoNewLine
					return
				}else{
					Write-Host $marks.Replace("{}", "None") -ForegroundColor "yellow" -NoNewLine
					return
				}
			} else {
				# We're on an actual branch
				$status = git status --porcelain
				if ($status -match '^\?\?') {
					# Untracked files exist
					Write-Host $marks.Replace("{}", " $branch") -ForegroundColor "blue" -NoNewLine
				} elseif ($status -match '^[AM]') {
					# Files have been added (A) or modified (M)
					Write-Host $marks.Replace("{}", " $branch") -ForegroundColor "blue" -NoNewLine
				} elseif ($status -notmatch '^\s*$') {
					# Uncommitted changes exist but no staged files
					Write-Host $marks.Replace("{}", " $branch") -ForegroundColor "blue" -NoNewLine
				} else {
					# The tree is clean; check for pending commits
					$upstream = "origin/$branch"
					$commitsAhead = git rev-list --count "$upstream..HEAD"

					if ($commitsAhead -gt 0) {
						# There are commits that are pending a push
						Write-Host $marks.Replace("{}", " $branch") -ForegroundColor "blue" -NoNewLine
					} else {
						if($branch.Contains("master")){
							Write-Host $marks.Replace("{}", " $branch") -ForegroundColor "blue" -NoNewLine
						}
						elseif ($branch.ToLower().Contains("develop")) {
							Write-Host $marks.Replace("{}", "$branch") -ForegroundColor "blue" -NoNewLine
						}
						else{
						# The tree is clean and up to date
							Write-Host $marks.Replace("{}", "$branch") -ForegroundColor "blue" -NoNewLine
						}
					}
				}
			}
		} catch {
			$commitHead = git rev-parse --short HEAD
			# Handle error, e.g., if in a newly initialized git repo
			Write-Host "< $commitHead>" -ForegroundColor "yellow" -NoNewLine
		}
	}
}

<#
.SYNOPSIS
	mbr (MyBRanch) function returns the current branch name.
#>
function mbr{
	$br_name = git rev-parse --abbrev-ref HEAD
	return $br_name
}

<#
.SYNOPSIS
	Git-Graph function displays the git graph view of the current repository.
#>
function Git-Graph{
	echo "************************************************"
	echo "            GIT GRAPH VIEW "
	echo "************************************************"
	git log --all --decorate --oneline --graph
}

<#
.SYNOPSIS
	Git-Branch function allows you to switch branches in a git repository.
#>
function Git-Branch {
	[CmdletBinding()]
	param (
		[string]$n, #the branch name given
		[switch]$s #search all branches
	)
	$all_branches = git branch -a
	$idx = 0 
	$branches_name = @()
	if($n){
		$name = $n
		foreach($branch in $all_branches){
			if($branch.Contains($name))
			{
				$branch = $branch.replace("remotes/origin/","")
				git checkout $branch.Trim()
				break
			}
		}
	}
	elseif($s){
		foreach($br in $all_branches)
		{	
			Write-Host $idx ':' $br.replace('remotes/origin/','') -ForegroundColor "green" 
			$branches_name += $br
			$idx = $idx + 1
		}
		setBra($branches_name)
	}
	else{
		echo "[help] Usages:"
		echo "Git-Bran -n <[the branch's name or the Jira card number]> -s <shows all branches>"
		echo ">> Git-Bra -n 'SETV-####' | >> Git-Bra -n 'ewdt' "
		echo ">> Git-Bra -s"
	}
}

<#
.SYNOPSIS
	SetBra function allows you to select a branch from a list of branches and switch to it.
	You can also copy the branch name to the clipboard.
#>
function SetBra($branches) {
	$idx = read-host "[+] Select branch number"
	if($idx)
	{
		if($branches[$idx].Contains("*"))
		{
			$branch = $branches[$idx].replace("* ","")
		}else
		{
			$branch = $branches[$idx].replace("remotes/origin/","")
		}
		Set-Clipboard $branch.Trim()
		git checkout $branch.Trim()
	}
}

<#
.SYNOPSIS
	Git-History function retrieves the commit history of a Git repository.
	You can filter the history by a specific user.
#>
function Git-History {
	[CmdletBinding()]param([string]$user)
	if($user){
		git for-each-ref --sort=-committerdate refs/remotes/ --format='%(committerdate:relative) %(committername) %(refname:short)' | grep -i $user
	}
	else{
		git for-each-ref --sort=-committerdate refs/remotes/ --format='%(committerdate:relative) %(committername) %(refname:short)'
	}
}

<#
.SYNOPSIS
	Show-GitRepos function retrieves and displays the list of GitHub repositories for a user.
	You can filter the repositories by a specific name.
#>
function Show-GitRepos{
	$links = Invoke-RestMethod -Uri "https://api.github.com/users/$USER_NAME/repos?per_page=200" | ForEach-Object { $_.clone_url }
	foreach($link in $links){
		Write-Host $link -ForegroundColor "DarkYellow"
	}
}

<#
.SYNOPSIS
	Get-LinkRepo function retrieves the link of a GitHub repository by its name.
	NOTES:
	 - This function uses the GitHub API to fetch the repository links.
#>
function Get-LinkRepo{
	[CmdletBinding()]
	param ([Parameter(Mandatory=$true)][string]$repoName)
	$dict_repos = @{}
	$array_repos = @()
	$links = Invoke-RestMethod -Uri "https://api.github.com/users/$USER_NAME/repos?per_page=200" | ForEach-Object { $_.clone_url }
	foreach($link in $links){
		$repo_name = Split-Path $link -Leaf
		if($repo_name -like "*$repoName*"){
			$array_repos += $repo_name
			$dict_repos[$repo_name] = $link
		}
	}
	if($array_repos.Count -eq 0){
		Write-Output "No repositories found for user '$USER_NAME' with the name '$repoName'."
		return $null
	}
	elseif($array_repos.Count -eq 1){
		return $dict_repos[$array_repos[0]]
	}
	else {
		Write-Host "Found multiple repositories:"
		$idx = 1
		foreach($repo in $array_repos){
			Write-Host " * $idx -> $repo"
			$idx++
		}
		Write-Host "Please, select one, enter the number of the repository to clone."
		$user_input = Read-Host "Which number?"
		$selected_repo = $array_repos[$user_input - 1]
		return $dict_repos[$selected_repo]
	}
}

<#
.SYNOPSIS
	Repo function returns the link of the repository and copies it to the clipboard.
	Notes:
	- The function uses a JSON file to map repository names to their URLs. The 
#>
function Repo([Parameter(Mandatory=$true)][string]$repo,[switch]$github=$true) {

	if(Test-Path -Path "$SUITE_PATH\lib\utils\configurations.json"){
		# Read the configurations.json file to get the repository link or the repository name.
		$conf = Get-Content -Path "$SUITE_PATH\lib\utils\configurations.json" -Raw | ConvertFrom-Json	
		$repoKey = $conf.GitRepos.PSObject.Properties | Where-Object { $_.Name -eq $repo}
	}else {
		Write-Host "[!] >> The configurations.json file does not exist in the expected path."
		return
	}

	if($repoKey){
		$repo = $repoKey.Value
	}
	if($github -eq $true){
		$repoLink = Get-LinkRepo -repoName $repo
		set-Clipboard $repoLink
		return $repoLink
	}else{
		Set-Clipboard $repo
		return $repo
	}
	
}

<#
.SYNOPSIS
	Git-Clone function clones a repository from GitHub in a easy way.
	Dummy but useful if you want to clone a repository without typing the full URL.
#>
function Git-Clone {
	[CmdletBinding()]
	param ([Parameter(Mandatory=$true)][string]$repo)
	Repo -repo $repo	
}

#==============================================#
# [!] DEPRECATED: Use Ignore function instead.
#==============================================#

function Ignore{
	[CmdletBinding()]
	param ([string]$folder)
	if($folder){
		$output = whereis -item $folder -verbose $false
		if($output.GetType().BaseType.Name -eq 'Array'){
			foreach($item in $output){
				if(-not $item.contains('out')){
					$output = $item
					break
				}
			}
		}
		$add_string = $output + "\*"
		Write-Host ">>Adding: $add_string"
		git add $add_string
		Write-Host ">> adding $folder to git tracking. (done)"
	}
	else {
		echo "[!] >>The folder for commit is needed."
	}
}

function Git-Push{
	[CmdletBinding()]
	param (
		[string]$folder,
		[string]$commit
	)
	Write-Host ">> git pull --all (done)"
	git pull --all
	if($folder){
		Ignore $folder
	}else{
		git add "."
		Write-Host ">> git add --all (done)"
	}
	if($commit){
		git commit -m $commit
		Write-Output ">> commit added: '$commit'"
		Write-Host "-------------------------------------------------------------"
		git push origin (mbr)
	}
	else {
		Write-Output "push command needs to have a commit!!!"
	}
}
