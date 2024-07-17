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
cd ../../mnt/e/devMachineConfig/src/bash && \
sudo apt-get update && \
sudo apt-get install -y dos2unix && \
sudo dos2unix *.sh && \
sudo ./updateDependencies.sh
```
## Update and Install all dependencies for Windows
``` powershell
e:\devMachineConfig\srcpowershell\configureDevMachine.ps1
```