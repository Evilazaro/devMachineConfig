# Enginer Dev Machine Configuration


- Update Windows
- Install Windows Subsystem Linux - WSL
- Reboot the computer
- Run Powershell
- Run Bash
- Configure Visual Studio
- Reboot computer
- Configure Docker


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
.\configureDevMachine.ps1
```