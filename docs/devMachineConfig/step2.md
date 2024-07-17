## Step 2 - Update Packages, Installs VS Code Extensions and Updates Dotnet Workloads 

- [Update and Install all dependencies for Windows](#update-and-install-all-dependencies-for-windows)
- [Update and Install all dependencies for Linux](#update-and-install-all-dependencies-for-linux)

### Update and Install all dependencies for Windows
``` powershell
e:\devMachineConfig\srcpowershell\configureDevMachine.ps1
```

### Update and Install all dependencies for Linux
``` bash
cd ../../mnt/e/devMachineConfig/src/bash && \
sudo apt-get update && \
sudo apt-get install -y dos2unix && \
sudo dos2unix *.sh && \
sudo ./updateDependencies.sh
```