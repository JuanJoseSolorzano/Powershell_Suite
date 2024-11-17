
$DECORATION = '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-'
function vscenv {
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

  function CreateVSfile($suite_path) {
      echo " [*] Getting paths from project."
      $path_info =Get-ChildItem $suite_path -Recurse | Select Name, `
      @{ n = 'Folder'; e = { Convert-Path $_.PSParentPath } }, `
      @{ n = 'Foldername'; e = { ($_.PSPath -split '[\\]')[-2] } }
      $dir = Get-ChildItem $suite_path
      $name = $dir.Directory.Name[0]
      $suite_paths = $path_info.Folder
      $workSpaceName = "$name.code-workspace"
      $suite_paths = $suite_paths | Select-Object -Unique
      $root_dir = $suite_paths[0]
      $exists = [System.IO.File]::Exists($workSpaceName)
      if($exists){
        Remove-Item -Force $workSpaceName
      }else{
        New-Item $workSpaceName -ItemType "file" >> $null
      }
      echo " [*] Creating the workspace file."
      Add-Content $workSpaceName $cont
      foreach($path in $suite_paths){
        if(-not $path.contains('\out\ta\report\')){
          $test = $(ls $path)
          if($test.Name.EndsWith(".py") -eq "True"){
            $workspacepath = $path.Replace($root_dir,'${workspaceFolder}')
            $modules_path='                 "' + $workspacepath.Replace('\','/') + '"' + ','
            if($modules_path -ne " " -or $null -ne $modules_path)
            {
              Add-Content $workSpaceName $modules_path
              $pypaht = $modules_path.Replace(',',';')
              $pypaht = $pypaht.Replace('"','')
              $arr += @($pypaht) 
            }
          }
        }
      }
      $exec_modules_temp = echo "$arr".Replace(' ','')
      $exec_modules_temp = $exec_modules_temp.Insert(0,'"')
      $exec_modules = $exec_modules_temp.Insert(($exec_modules_temp.Length),'"')
      #$end_paths = '],"terminal.integrated.env.windows": {"PYTHONPATH":'+$exec_modules + '}},'
      $end_paths = '],"python.envFile": "${workspaceFolder}/.env"},'
      Add-Content $workSpaceName $end_paths
      Add-Content $workSpaceName $debug
      echo " [+] Python for Visual Code has been created."
      & code "$name.code-workspace"
      echo " [+] File name: '$name.code-workspace'"
      echo "--------------------------------------------------------------------------------------"
      echo "                 -------> WORKSPACE CREATED SUCCESSFULLY <--------"
      echo "--------------------------------------------------------------------------------------"
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
    echo " [+] File will be create at:"
    echo "        - $(pwd)"
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

# Main flow for .ps1 file.
$curr_dir = pwd
vscenv $curr_dir
Pause