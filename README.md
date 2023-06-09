# SoftwareOperations
(PUBLIC REPO) This repo holds a script that is used to install sofrware that is used for a new Operations team member 

## How to install the software

#If you are a local Administrator of your computer
Open up a Powershell prompt in Administration Mode
```
Set-ExecutionPolicy Bypass -Scope Process -Force; 
$script = Invoke-WebRequest https://raw.githubusercontent.com/fmgplatform/SoftwareOperations/master/OperationsSoftwareInstalls.ps1 -UseBasicParsing; 
invoke-expression $($script.Content)
```

#If you are NOT a local Administrator of your computer
Open up a Powershell prompt
```
Set-ExecutionPolicy Bypass -Scope Process -Force; 
$script = Invoke-WebRequest https://raw.githubusercontent.com/fmgplatform/SoftwareOperations/master/OperationsSoftwareInstalls.ps1 -UseBasicParsing; 
invoke-expression $($script.Content)
```



## This script will perform the following actions

* Download and install the latest Microsoft Visual Studio Code
* Download and install a small set of extensions for VS Code
* Download and install the latest Git for Windows
* Apply your chosen username and password to the Git config
* Downlad and install Terraform 
* Add the Terraform path to windows search path
* create symbolic link called tf for Terraform 
* If you are a local Administrator this software will be installed to all-users, if you are not then it will only be installed for your login. 



At the start of the script it will ask for your username, this is your display name when you log into your computer, the email address is your normal fmg email address.
