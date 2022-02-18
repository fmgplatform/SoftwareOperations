

$Username = Read-Host 'What is your user name?'
$UserEmail = Read-Host 'What is your email address?'



#################################################################
####
###           Installing VSCode
###
###############################################################

Write-host -ForegroundColor Yellow Installing Virtual Studio code
$exe = $env:TEMP + "\vscode.exe"
Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"  -outfile $exe
Start-Process -wait -filepath $exe  -ArgumentList "/SILENT /NORESTART /MERGETASKS=!runcode"


Write-host -ForegroundColor Yellow Installing extensions for Virtual Studio code

##########################
## installing extensions
#########################
$exe = "C:\Program Files\Microsoft VS Code\bin\code"
Start-Process -wait -filepath $exe  -ArgumentList " --install-extension eamodio.gitlens" 
Start-Process -wait -filepath $exe  -ArgumentList " --install-extension hashicorp.terraform" 
Start-Process -wait -filepath $exe  -ArgumentList " --install-extension ms-azuretools.vscode-azureterraform" 
Start-Process -wait -filepath $exe  -ArgumentList " --install-extension ms-vscode.powershell" 






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
$exe = "c:\Program Files\Git\bin\git.exe"
Start-process -FilePath $exe -ArgumentList ("config --global user.name """  + $Username +"""")
Start-process -FilePath $exe -ArgumentList ("config --global user.email """ +$UserEmail +"""")








Write-host -ForegroundColor Yellow Installing Terraform

#################################################################
####
###           Installing Terraform
###
###############################################################




#read the latest version
$tf_release_url = "https://api.github.com/repos/hashicorp/terraform/releases/latest"
$web_content = Invoke-WebRequest -Uri $tf_release_url -UseBasicParsing |	ConvertFrom-Json
$latest_tf_version = $web_content.tag_name.replace("v","")

#set the url on the above information
$url = "https://releases.hashicorp.com/terraform/"+ $latest_tf_version + "/terraform_"+ $latest_tf_version+"_windows_amd64.zip"
$asset = "Terraform_$latest_tf_version.zip"

#set the download location
$installer = "$env:temp\$($asset)"

#download
Invoke-WebRequest -Uri $url -OutFile $installer

Write-host -ForegroundColor yellow unzipping and updateing path for Terraform
#unzip
$tf_path = "C:\Terraform"
Expand-Archive -Path $installer -DestinationPath $tf_path -Force
$nulloutput = New-Item -ItemType SymbolicLink -Path $tf_path\tf.exe -Target $tf_path\Terraform.exe -ErrorAction SilentlyContinue


#add to path

if (-not($env:Path.split(";") -contains $tf_path)) {[Environment]::SetEnvironmentVariable("Path", $env:Path + ";"+ $tf_path , "Machine") }

Write-host -ForegroundColor yellow Completed
