# WindowsPowerShell
>[!NOTE]
> _**How to use:**_
> 
> You must have > pswh 7.4
> Check: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4
>  -----
> 
> _Clone this repo in the "Documents" folder._
> - Verify you windows profile location by: 
>     - `test-path $PRFILE` #output: true if exists
>     - `cd $home\Documents\`
> - close powershell and open it again. 
> ---------------------------------------------
> _Edit user system variables:_
> 
> Open **"Run Command"** by pressing  _**win+R**_
> 
> **RUN:**
> 
> `%windir%\System32\rundll32.exe sysdm.cpl,EditEnvironmentVariables`
> 
> ---------------------------------------------
> ## Windows Terminal configuration:
>  1. Located the \PowerShell\lib\wterminal_settings.json
>  2. Change the name of the .json file as: settings.json
>  3. Paste this file into: C:/Users/[userName]/AppData/Local/Packages/Microsoft.WidowsTerminal_8wekyb3d8bbwe/LocateState/
> 