# Enginer Dev Machine Configuration


- Update Windows
- Update Windows Apps on Microsoft App Store
- Install Windows Subsystem Linux - WSL
- Reboot the computer
- Install DevHome
- Run DevHome config file
- Configure Visual Studio
- Reboot computer
- Configure Docker
- Run Powershell
- Run Bash

## Update and Install all dependencies for Linux
``` bash
cd ../../mnt/c && \
git clone https://github.com/Evilazaro/dotnetCustomDeveloperMachineConfiguration.git devMachine && \
cd devMachine/src/bash && \
sudo ./updateDependencies.sh
```
## Update and Install all dependencies for Windows
``` powershell
cd src\powershell
.\updateDependencies.ps1
```