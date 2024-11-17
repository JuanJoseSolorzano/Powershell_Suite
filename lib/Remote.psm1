
function Remote {
    [CmdletBinding()]
    param (
        [string]$bench,
        [switch]$h
    )
    if("" -eq $bench){
        $bench = Read-Host "Which bench?"; 
        $w_host = $bench.Split(' ')[1]; 
        if($w_host -ne $null){
            $get_host = "sht"
            $bench = $bench.Split(' ')[0]
        }
    } 

    $current_location = Get-Location
    $rootPath = "D:\Tebenator\"
    Set-Location $rootPath
    $allTB = $(Get-ChildItem)
    function Get-Host-Bench{
        param($bench)
        $cont = get-content $bench
        $_host = $cont.get(23)
        $_host = $_host.split(':')[2]
        Set-Clipboard $_host
        echo "$($_host)"
    }
    try{
        $bench = $bench.ToString()
        $bench = $bench.ToUpper()+".rdp"
        $bench = $bench.Trim(' ')
    }catch {
        echo "Parameter needed [bench name]"
        Set-Location $current_location
    }

    foreach($TB in $allTB)
    {
        if($bench -eq $TB.Name)
        {
            try 
            {
                $n = $rootPath + $TB.Name
    			if($h){Get-Host-Bench $n}
    			else{
    			    Start-Process $n
                    Set-Location $current_location
                    echo "[+] passwd copied to clipboard."
                    get-passwd $bench
                }
            }
            catch 
            {
                echo "Bench $n not fond !!!!!!"
                Set-Location $current_location
            }
        }
    }
    Set-Location $current_location
}
