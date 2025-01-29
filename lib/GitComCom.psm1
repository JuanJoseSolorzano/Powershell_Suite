#REQUIRES -Version 1.0
<#
.SYNOPSIS
	GitComCom is a module created to facilte the git commands in powershell.
.DESCRIPTION
	There are many commands that you can use with the powershell profile.
.NOTES
    File Name      : GitComCom.psm1
    Author         : Solorzano, Juan Jose (uiv06924)
    Prerequisite   : PowerShell V1
#>
#------ Importing PS1 Modules ------#
$exe_path = Get-Location
Set-Location $HOME
#$root_path = Get-Location
$modules_path = 'C:\\LegacyApp\\powershell\\powershell-master\\lib\\{0}.psm1'
Import-Module -Name ($modules_path -f "Helpers") -DisableNameChecking
Set-Location $exe_path
#--------- MAIN FUNCTION <prompt> -----------#
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


function mbr{
	$br_name = git rev-parse --abbrev-ref HEAD
	return $br_name
}
function Git-Graph{
    echo "************************************************"
    echo "            GIT GRAPH VIEW "
    echo "************************************************"
	git log --all --decorate --oneline --graph
}
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
function Git-History {
	[CmdletBinding()]param([string]$user)
	if($user){
		git for-each-ref --sort=-committerdate refs/remotes/ --format='%(committerdate:relative) %(committername) %(refname:short)' | grep -i $user
	}
	else{
		git for-each-ref --sort=-committerdate refs/remotes/ --format='%(committerdate:relative) %(committername) %(refname:short)'
	}
}
function Repo($repo) {
	try {
		$repo=$repo.ToUpper()  
		$None=$false
	}
	catch {
		Write-Output "Which repo???"
		$None=$true
	}
	if(-not $None){
	    if($repo -eq "G80")
	    {
	        return 'https://github.vitesco.io/EnDS-Test-Automation/VT.PRJ.GM.G80.CVR.git'
	    }
	    elseif($repo -eq "G70") 
	    {
	        return 'https://github.vitesco.io/EnDS-Test-Automation/VT.PRJ.GM.G70.CVR.git'
	    }
	    elseif($repo -eq "FC1") 
	    {
	        return 'https://github.vitesco.io/EnDS-Test-Automation/VT.PRJ.FORD.FC1.REGR_TEST.git'
	    }
	    elseif($repo -eq "FB0")
	    {
	        return 'https://github.vitesco.io/EnDS-Test-Automation/VT.PRJ.FORD.FB0.REGR_TEST.git'
	    }
	    elseif ($repo -eq "FB1"){
	        return 'https://gitlab-ec-na.aws1583.vitesco.io/ec/se/aet/tas/ford/fofb0_ta_suite.git'
	    }
		elseif($repo -eq "E42A"){
			return 'https://github.vitesco.io/EnDS-Test-Automation/VT.PRJ.GM.G55.FAST.git'
		}
		elseif($repo -eq "CONTEST"){
			return 'https://github.vitesco.io/EnDS-Test-Automation/VT.GEN.TOOL.CONTEST.git'
		}
		elseif($repo -eq "FC1_"){
			return 'https://github.vitesco.io/uiv06924/fo_fc1_ta_suite.git'
		}
		elseif($repo -eq "H02") {
			return 'https://github.vitesco.io/EnDS-Test-Automation/vt.prj.ford.foh02.sys_test.git'
		}
		elseif($repo -eq "myrecorder"){
			return 'https://github.vitesco.io/uiv06924/MyRecorder.git'
		}
	    else{echo "Repository <$repo> don't found !!!!!!!!!"}
	}
}
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
