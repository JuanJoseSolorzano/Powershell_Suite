$RESET = "`e[0m"
$RED = "`e[31m"
$GREEN = "`e[32m"
$GRAY = "`e[37m"
$YELLOW = "`e[33m"
$BLUE = "`e[34m"
$MAGENTA = "`e[38;5;13m"
$CYAN = "`e[36m"
$WHITE = "`e[37m"
$DECORATION = "${YELLOW}+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-${RESET}"
function vsenv {
    param($target_path)
    # Global variables used to the file code structure
    $cont = '{
        "folders": [
          {
            "path": "."
          }
        ],
        "settings": {"python.analysis.extraPaths": ['
    
    $debug = '"launch": {
              "version": "0.2.0",
              "configurations": [{
              "name": "Python: DebugForTA",
              "type": "python",
              "request": "launch",
              "program": "${file}",
              "console": "integratedTerminal" },
            ]}
          }'

    $pyEnvFileName = ".env"

    function CreateVSfile($suite_path) {
        echo " ${YELLOW}[*]${RESET} Getting paths from project."
        $path_info =Get-ChildItem $suite_path -Recurse | Select Name, `
        @{ n = 'Folder'; e = { Convert-Path $_.PSParentPath } }, `
        @{ n = 'Foldername'; e = { ($_.PSPath -split '[\\]')[-2] } }
        if($path_info -eq $null){
            echo "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "${RED}                             [!] ${YELLOW}TA${RESET} SUITE NOT FOUND."
            echo "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "${YELLOW}---------------------------------------------------------------------------------------${RESET}`n"
            return
        }
        $dir = Get-ChildItem $suite_path
        $name = $dir.Directory.Name[0]
        $suite_paths = $path_info.Folder
        $workSpaceName = "$name.code-workspace"
        $suite_paths = $suite_paths | Select-Object -Unique
        $root_dir = $suite_paths[0]
        if(Test-Path "$root_dir\$workSpaceName"){
            echo "${YELLOW} [!] ${RESET}Workspace Exists"
            Remove-Item -Force $workSpaceName
        }else{
            New-Item $workSpaceName -ItemType "file" >> $null
        }
        if(Test-Path "$root_dir\$pyEnvFileName"){
            echo "${YELLOW} [!] ${RESET}.env file Exists"
            Remove-Item -Force $pyEnvFileName
        }else{
            New-Item $pyEnvFileName -ItemType "file" >> $null
        }
        echo " ${YELLOW}[*]${RESET} Creating the .env file."
        echo " ${YELLOW}[*]${RESET} Creating the workspace file."
        Add-Content $workSpaceName $cont
        foreach($path in $suite_paths){
          if(-not $path.contains('\out\ta\report\')){
            $test = $(ls $path)
            if($test.Name.EndsWith(".py") -eq "True"){
              $workspacepath = $path.Replace($root_dir,'${workspaceFolder}')
              $pyEnvPaths = $path.Replace($root_dir,'.').Replace('\','/') + '"' + ','
              $modules_path='                 "' + $workspacepath.Replace('\','/') + '"' + ','
              if($modules_path -ne " " -or $null -ne $modules_path){
                Add-Content $workSpaceName $modules_path
                $pypath = $modules_path.Replace(',',';')
                $pypath = $pypath.Replace('"','')
                $arr += @($pypath) 
                #pyEnvFile
                $env_str_path += ($pyEnvPaths).Replace('",',';')
                $pyArray = $env_str_path
              }
            }
          }
        }
        $exec_modules_temp = echo "$arr".Replace(' ','')
        $exec_modules_temp = $exec_modules_temp.Insert(0,'"')
        $exec_modules = $exec_modules_temp.Insert(($exec_modules_temp.Length),'"')
        $end_paths = ']},'
        Add-Content $workSpaceName $end_paths
        Add-Content $workSpaceName $debug
        Add-Content $pyEnvFileName "PYTHONPATH=$pyArray"
        Add-Content $pyEnvFileName "PYTHON_PATH=C:\LegacyApp\Python27_x64\python.exe"
        echo " ${YELLOW}[+]${RESET} Python for Visual Code has been created."
        $out = start-process -NoNewWindow code "$name.code-workspace" > $null 2>&1 &
        echo " ${YELLOW}[+]${RESET} File name: '$name.code-workspace'"
        echo " ${YELLOW}[+]${RESET} .env file created."
        echo "${YELLOW}----------------------------------------------------------------------------------------${RESET}"
        echo "                 -------> WORKSPACE CREATED SUCCESSFULLY <--------"
        echo "${YELLOW}----------------------------------------------------------------------------------------${RESET}"

    }
    function title {
        echo $DECORATION
        echo "                         PYTHON ENVIRONMENT CONFIGURATION"
        echo "                                 Powershell script"
        echo $DECORATION
    }
    # Main
    if(($null -eq $target_path) -or ('.' -eq $target_path)){
      title
      echo " ${YELLOW}[+]${RESET} File will be created at:"
      echo "        ${CYAN}- $(pwd)${RESET}"
      CreateVSfile('.')
    }
    else 
    {
      title
      echo " [*] Finding TA suite..."
      if(Test-Path $target_path){
        echo " [+] Path Found At:"
        echo "       - $target_path"
        CreateVSfile($target_path)
      }
      else {
        echo "[!] Error: Path not found !!!"
      }
    }
}
