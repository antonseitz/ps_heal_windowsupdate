
$arch = Get-WMIObject -Class Win32_Processor -ComputerName LocalHost | Select-Object AddressWidth
 
Write-Host "1. Stopping Windows Update Services..."
$answer=read-host "Do so? Hit ENTER"
Stop-Service -Name BITS
Stop-Service -Name wuauserv
Stop-Service -Name usosvc
Stop-Service -Name appidsvc
Stop-Service -Name cryptsvc -force
 


function save_and_delete($path){
$path_bak=$path + ".bak"
if(test-path $path_bak) {
	"Delete " +  $path_bak
	takeown /r /f $path_bak

Remove-Item -recurse $path_bak



}
"backup  " + $path
takeown /r /f $path
Rename-Item  $path $path_bak


}


Write-Host "2. Remove QMGR Data file…"
$answer=read-host "Do so? Hit ENTER"
Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" 
 

Write-Host "3. Backup and delete the Software Distribution ..."
$answer=read-host "Do so? Hit ENTER"
if(test-path $env:systemroot\SoftwareDistribution) {
	save_and_delete( $env:systemroot + "\SoftwareDistribution" )
	
}
Write-Host "3. Backup and delete the CatRoot Folder..."

$answer=read-host "Do so? Hit ENTER"

if (test-path $env:systemroot\System32\catroot2 ){
save_and_delete( $env:systemroot + "\System32\catroot2") 
}

Write-Host "3. Backup and delete the pending.xml ..."
 $answer=read-host "Do so? Hit ENTER"
if(test-path $env:systemroot\winsxs\pending.xml){
save_and_delete ($env:systemroot + "\winsxs\pending.xml")}





#if exist "%SYSTEMROOT%\SoftwareDistribution" ( 
#   attrib -r -s -h /s /d "%SYSTEMROOT%\SoftwareDistribution" 

 $answer=read-host "Continue with ENTER"
# PROBABLY OLD PATH
if(test-path "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader"){
Remove-Item "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat"}
Remove-Item $env:systemroot\Logs\WindowsUpdate\*


$answer=read-host "Continue with ENTER"
# PROBABLY OLD PATH
Write-Host "4. Removing old Windows Update log..."
if (test-path $env:systemroot\WindowsUpdate.log ){
Remove-Item $env:systemroot\WindowsUpdate.log }
 
#Write-Host "5. Resetting the Windows Update Services to defualt settings..."
#"sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
#"sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
 
push-Location $env:systemroot\system32
 
Write-Host "6. Registering some DLLs..."
 $answer=read-host "Do so? Hit ENTER"
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll
 

 
Write-Host "9) Delete all BITS jobs…"
 $answer=read-host "Do so? Hit ENTER"
Get-BitsTransfer | Remove-BitsTransfer
 
Write-Host "10) Attempting to install the Windows Update Agent..."
 $answer=read-host "Do so? Hit ENTER"
if($arch -eq 64){
    wusa Windows8-RT-KB2937636-x64 /quiet
}
else{
    wusa Windows8-RT-KB2937636-x86 /quiet
}
 
pop-Location

"

OK! 


Repair is done !


Do you want to do a SFC and DISM scanns now ? "
$answer=read-host "Enter SCAN and press ENTER to do Sfc /scannow "

if ($answer -eq "SCAN" ) {

"dism /online /cleanup-image /scanhealth"
dism /online /cleanup-image /scanhealth
"dism /Online /Cleanup-Image /CheckHealth"
dism /Online /Cleanup-Image /CheckHealth
"dism /online /cleanup-image /restorehealth"
dism /online /cleanup-image /restorehealth

"sfc /scannow"
sfc /scannow




}


"Do you want to do CHKSDK after next Reboot ?"
$answer=read-host "Schedule chkdsk after next reboot ? Just hit ENTER to do so"
if ($answer -eq "" ) {

chkdsk.exe /f c:


}
"RESTART PC NOW ?"
$answer=read-host "RESTART PC NOW ? Type RESTART and hit ENTER to Restart now"
if ($answer -eq "RESTART" ) {


restart-computer
}

$answer=read-host "Retry Windows Update? Hit ENTER to Retry Updating"
if ($answer -eq "" ) {


Write-Host "11) Starting Windows Update Services…"
Start-Service -Name BITS
Start-Service -Name wuauserv
Start-Service -Name appidsvc
Start-Service -Name cryptsvc
Start-Service -Name usosvc
 
Write-Host "12) Forcing discovery…"
wuauclt /resetauthorization 
	
	"Now try to update again!"
}

