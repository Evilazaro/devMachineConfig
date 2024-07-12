# Enginer Dev Machine Configuration


- Update Windows
- Update Windows Apps on Microsoft App Store
- Install Windows Subsystem Linux - WSL
- Reboot the computer
- Install DevHome
- Run DevHome config file
- Reboot computer
- Configure Docker
- Clone this repo
- Run Powershell
- Run Bash
- Configure Visual Studio


``` bash
cd src\bash
sudo apt-get update && \
     apt-get upgrade -y && \
     apt-get install -y dos2linux && \
     dos2unix *.sh && \
     ./updateDependencies.sh
````

```` powershell
cd src\powershell
.\updateDependencies.ps1
````