
<#
.SYNOPSIS
	Script to auto-install the latest versions of 
  Visual Studio Code
  Git for Windows
  Terraform

.DESCRIPTION
	Script will scrape the following websites to install the latest versions of the software. This small set of software 
  is used as the base set for the Operations team to start using GitHub and Terraform. 


.LINK
   https://code.visualstudio.com
   https://gitforwindows.org/
   https://www.terraform.io/
   
#>




$UserName = Read-Host 'What is your user Display name e.g Bob Smtih?'
$UserEmail = Read-Host 'What is your FMG email address?'

# Check if user is a local administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")


#################################################################
####
###           Installing VSCode
###
###############################################################

Write-host -ForegroundColor Yellow "Installing Virtual Studio code"

if ($IsAdmin) {
    # Install Admin version of VSCode
    $exe = $env:TEMP + "\vscode.exe"
    Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"  -outfile $exe
    Start-Process -wait -filepath $exe  -ArgumentList "/SILENT /NORESTART /MERGETASKS=!runcode"
    $exelocation = "C:\Program Files\Microsoft VS Code\bin\code"
} else {
    # Install User version of VSCode
    $exe = $env:TEMP + "\vscode.exe"
    Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"  -outfile $exe
    Start-Process -wait -filepath $exe  -ArgumentList "/SILENT /NORESTART /MERGETASKS=!runcode"
    $exelocation = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code"
}

Write-host -ForegroundColor Yellow "Installing extensions for Virtual Studio code"

##########################
## installing extensions
#########################

Start-Process -wait -filepath $exelocation  -ArgumentList " --install-extension eamodio.gitlens" 
Start-Process -wait -filepath $exelocation  -ArgumentList " --install-extension hashicorp.terraform" 
Start-Process -wait -filepath $exelocation  -ArgumentList " --install-extension ms-azuretools.vscode-azureterraform" 
Start-Process -wait -filepath $exelocation  -ArgumentList " --install-extension ms-vscode.powershell" 
Start-Process -wait -filepath $exelocation  -ArgumentList " --install-extension ms-azuretools.vscode-logicapps" 
Start-Process -wait -filepath $exelocation  -ArgumentList " --install-extension azapi-vscode.azapi"
Start-Process -wait -filepath $exelocation  -ArgumentList " --install-extension jono.terraformregistrylookup







Write-host -ForegroundColor Yellow Installing Git

#################################################################
####
###           Installing git
###
###############################################################
# get latest download url for git-for-windows 64-bit exe
$git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$asset = Invoke-RestMethod -Method Get -Uri $git_url | % assets | where name -like "*64-bit.exe"
# download installer
$installer = "$env:temp\$($asset.name)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer
# run installer
$git_install_inf = "<install inf file>"
$install_args = "/SP- /SILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""
Start-Process -FilePath $installer -ArgumentList $install_args -Wait


Write-host -ForegroundColor Yellow Adding your username and email to git config
##############################
## adding required git config
#############################
if ($IsAdmin) {
    $exelocation = "c:\Program Files\Git\bin\git.exe"
}
else {
    $exelocation = "$env:LOCALAPPDATA\Programs\Git\bin\git.exe"
}
Start-process -FilePath $exelocation -ArgumentList ("config --global user.name """  + $UserName +"""")
Start-process -FilePath $exelocation -ArgumentList ("config --global user.email """ +$UserEmail +"""")








Write-host -ForegroundColor Yellow Installing Terraform

#################################################################
####
###           Installing Terraform
###
###############################################################




#read the latest version
$tf_release_url = "https://api.github.com/repos/hashicorp/terraform/releases/latest"
$web_content = Invoke-WebRequest -Uri $tf_release_url -UseBasicParsing | ConvertFrom-Json
$latest_tf_version = $web_content.tag_name.replace("v","")

#set the url on the above information
$url = "https://releases.hashicorp.com/terraform/"+ $latest_tf_version + "/terraform_"+ $latest_tf_version+"_windows_amd64.zip"
$asset = "Terraform_$latest_tf_version.zip"

#set the download location
$installer = "$env:temp\$($asset)"

#download
Invoke-WebRequest -Uri $url -OutFile $installer

Write-host -ForegroundColor yellow "Unzipping and updating path for Terraform"

#unzip
$tf_path = "C:\Terraform"
Expand-Archive -Path $installer -DestinationPath $tf_path -Force
$nulloutput = New-Item -ItemType SymbolicLink -Path $tf_path\tf.exe -Target $tf_path\Terraform.exe -ErrorAction SilentlyContinue

#add to path
if ($IsAdmin) {
    # Update system-wide Path environment variable
    if (-not(([Environment]::GetEnvironmentVariable("Path", "Machine")).split(";") -contains $tf_path)) {
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "Machine") + ";"+ $tf_path , "Machine")
    }
} else {
    # Update user-specific Path environment variable
    if (-not(([Environment]::GetEnvironmentVariable("Path", "User")).split(";") -contains $tf_path)) {
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";"+ $tf_path , "User")
    }
}




Write-host -ForegroundColor Yellow Installing Terraform Docs

#################################################################
####
###           Installing Terraform Docs
###
###############################################################


# Set the URL to the latest release page
$latestReleaseUrl = "https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest"

# Get the JSON data of the latest release
$latestRelease = Invoke-RestMethod -Uri $latestReleaseUrl

# Find the download URL for the Windows amd64 zip file
$downloadUrl = $latestRelease.assets | Where-Object { $_.name -like "*windows-amd64.zip" } | Select-Object -ExpandProperty browser_download_url

# Set the output file path
$outputFilePath = "$HOME\Downloads\terraform-docs-windows-amd64.zip"

# Download the file
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFilePath

# Unzip the downloaded file
Expand-Archive -Path $outputFilePath -DestinationPath "$HOME\Downloads\terraform-docs-windows-amd64"


#set the correct install path
if ($IsAdmin) { 
     $installPath = "C:\Program Files\terraform-docs" 
    }
else {
   
    $installPath = "$env:LOCALAPPDATA\terraform-docs" 
    }


# Create the installation directory if it doesn't exist
if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
}


# Copy the unzipped files to the installation directory
Copy-Item "$HOME\Downloads\terraform-docs-windows-amd64\*" $installPath -Force

if ($IsAdmin){
    # Update system-wide Path environment variable
    if (-not(([Environment]::GetEnvironmentVariable("Path", "Machine")).split(";") -contains $installPath)) {
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "Machine") + ";"+ $installPath , "Machine")
    }
} else {
    # Update user-specific Path environment variable
    if (-not(([Environment]::GetEnvironmentVariable("Path", "User")).split(";") -contains $installPath)) {
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";"+ $installPath , "User")
    }
}


# Clean up old files
Remove-Item $outputFilePath
Remove-Item "$HOME\Downloads\terraform-docs-windows-amd64" -Recurse



Write-host -ForegroundColor yellow "Completed"
