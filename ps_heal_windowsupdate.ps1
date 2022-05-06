
$arch = Get-WMIObject -Class Win32_Processor -ComputerName LocalHost | Select-Object AddressWidth
 
Write-Host "1. Stopping Windows Update Services..."

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

Rename-Item  $path $path_bak


}


Write-Host "2. Remove QMGR Data file…"

Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" 
 

Write-Host "3. Renaming the Software Distribution and CatRoot Folder..."

if(test-path $env:systemroot\SoftwareDistribution) {
	save_and_delete( $env:systemroot + "\SoftwareDistribution" )
	#"Delete SoftwareDistribution.bak"
	#takeown /f $env:systemroot\SoftwareDistribution.bak
#Remove-Item $env:systemroot\SoftwareDistribution.bak}
}
if(test-path $env:systemroot\SoftwareDistribution ){
Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak

}
if (test-path $env:systemroot\System32\catroot2.bak ){
Remove-Item $env:systemroot\System32\catroot2.bak 
}
if(test-path $env:systemroot\System32\Catroot2){
Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak }
 
if(test-path $env:systemroot\winsxs\pending.xml.bak){
Remove-Item $env:systemroot\winsxs\pending.xml.bak}

#    takeown /f "%SYSTEMROOT%\winsxs\pending.xml" 
 #   attrib -r -s -h /s /d "%SYSTEMROOT%\winsxs\pending.xml" 
 

if(test-path $env:SYSTEMROOT\winsxs\pending.xml){
rename-item $env:SYSTEMROOT\winsxs\pending.xml $env:SYSTEMROOT\pending.xml.bak 
}
if(test-path $env:systemroot\SoftwareDistribution.bak){
Remove-Item $env:systemroot\SoftwareDistribution.bak
#if exist "%SYSTEMROOT%\SoftwareDistribution" ( 
#   attrib -r -s -h /s /d "%SYSTEMROOT%\SoftwareDistribution" 
}
if(test-path $env:SYSTEMROOT\SoftwareDistribution  ){
rename-item $env:SYSTEMROOT\SoftwareDistribution  $env:SYSTEMROOT\SoftwareDistribution.bak 
}

 
 
Remove-Item "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
Remove-Item $env:ALLUSERSPROFILE\ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat
Remove-Item $env:systemroot\Logs\WindowsUpdate\*
 
Write-Host "4. Removing old Windows Update log..."
Remove-Item $env:systemroot\WindowsUpdate.log 
 
#Write-Host "5. Resetting the Windows Update Services to defualt settings..."
#"sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
#"sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
 
push-Location $env:systemroot\system32
 
Write-Host "6. Registering some DLLs..."
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
 
#Write-Host "7) Removing WSUS client settings..."
#REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v AccountDomainSid /f
#REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v PingID /f
#REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /f
 
#Write-Host "8) Resetting the WinSock…"
#netsh winsock reset
#netsh winhttp reset proxy
 
Write-Host "9) Delete all BITS jobs…"
Get-BitsTransfer | Remove-BitsTransfer
 
Write-Host "10) Attempting to install the Windows Update Agent..."
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

"sfc /scannow"
sfc /scannow

"dism /online /cleanup-image /scanhealth"
dism /online /cleanup-image /scanhealth
"dism /Online /Cleanup-Image /CheckHealth"
dism /Online /Cleanup-Image /CheckHealth
"dism /online /cleanup-image /restorehealth"
dism /online /cleanup-image /restorehealth




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

