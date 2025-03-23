# PowerShell Suite

## Overview
This repository contains a set of PowerShell scripts and modules designed to enhance your PowerShell environment with additional functionality and customization.

## Prerequisites
- PowerShell 7.4 or later
- Windows operating system

## Installation

### Step 1: Clone the Repository
Clone this repository into your "Documents" folder:
```sh
git clone https://github.com/your-repo/PowerShell-master.git $HOME\Documents\PowerShell-master
```

### Step 2: Verify PowerShell Profile Location
Verify your PowerShell profile location by running:
```powershell
test-path $PROFILE
```
If the output is `true`, proceed to the next step.

### Step 3: Restart PowerShell
Close PowerShell and open it again to apply the changes.

### Step 4: Edit User System Variables
1. Open the **"Run Command"** by pressing `Win + R`.
2. Run the following command:
```sh
%windir%\System32\rundll32.exe sysdm.cpl,EditEnvironmentVariables
```

## Windows Terminal Configuration
1. Locate the `wterminal_settings.json` file in the `PowerShell\lib` directory.
2. Rename the file to `settings.json`.
3. Copy the file to the following location:
```sh
C:/Users/[userName]/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/
```

## Usage
After completing the installation steps, your PowerShell environment will be enhanced with the following features:
- Custom prompt with directory and Git branch information
- Tab completion for directories and files
- Additional modules for Git, remote management, and more

## Modules Included
- `GitComCom`
- `Helpers`
- `Remote`
- `vs-suite`
- `Terminal-Icons`

## Author
- **Solorzano, Juan Jose**

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
