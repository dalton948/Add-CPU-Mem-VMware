<# Script made by 
 .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .-----------------.
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |  ________    | || |      __      | || |   _____      | || |  _________   | || |     ____     | || | ____  _____  | |
| | |_   ___ `.  | || |     /  \     | || |  |_   _|     | || | |  _   _  |  | || |   .'    `.   | || ||_   \|_   _| | |
| |   | |   `. \ | || |    / /\ \    | || |    | |       | || | |_/ | | \_|  | || |  /  .--.  \  | || |  |   \ | |   | |
| |   | |    | | | || |   / ____ \   | || |    | |   _   | || |     | |      | || |  | |    | |  | || |  | |\ \| |   | |
| |  _| |___.' / | || | _/ /    \ \_ | || |   _| |__/ |  | || |    _| |_     | || |  \  `--'  /  | || | _| |_\   |_  | |
| | |________.'  | || ||____|  |____|| || |  |________|  | || |   |_____|    | || |   `.____.'   | || ||_____|\____| | |
| |              | || |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 
 let me know if you have any questions
 #>



#Has to be run when connected to vspheres
#Does not work with more than one instance if using the one by one method

write-host "
 _____ ______ _   _           ___  ___ ________  ___   ___ ____________ ___________ 
/  __ \| ___ \ | | |   ___    |  \/  ||  ___|  \/  |  / _ \|  _  \  _  \  ___| ___ \
| /  \/| |_/ / | | |  ( _ )   | .  . || |__ | .  . | / /_\ \ | | | | | | |__ | |_/ /
| |    |  __/| | | |  / _ \/\ | |\/| ||  __|| |\/| | |  _  | | | | | | |  __||    / 
| \__/\| |   | |_| | | (_>  < | |  | || |___| |  | | | | | | |/ /| |/ /| |___| |\ \ 
 \____/\_|    \___/   \___/\/ \_|  |_/\____/\_|  |_/ \_| |_/___/ |___/ \____/\_| \_|
                                                                                                                                                                        
"


#####fucntions
#Gets current VM Data Name, Powerstate, CPU, MEM
function getData {
    $global:server = Read-Host "Please enter your Server Name".trim()
    Get-VM $server
    $global:cpu = get-vm $server | Select-Object *num* -ExpandProperty *num*
    $global:mem = get-vm $server | Select-Object *MemoryGB* -ExpandProperty MemoryGB
}


#Pulls up explorer to select your file
Function get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}
#####End functions


#Menu to select what you need to do. Add CPU & MEM one server at a time or with a list
#Only use list option if all the added values from the CHG ticket are the same EX: adding 8cpu or 32GB RAM to all servers listed.
    Write-Host ""
    Write-Host "Adding CPU & Memory - Please choose an option:"
    Write-Host ""
    Write-Host "1: Modify One Server at a Time"
    Write-Host "2: Modify a List of Servers"
    $selection = Read-Host "Please enter which option you need".trim()

#Section for the One by one method
if ($selection -eq 1) {
    do {
    getdata
        #Confirms that the server has been powered off and will loop until it is
        $powerstate = get-vm $server | Select-Object PowerState -ExpandProperty *power*
            if ($powerstate -eq "PoweredOff") {
            } elseif ([int]$powerstate.Length -ge "2" ) {
                Write-Host "You have duplicates and will be unable to continue this script"
                Write-Host "Exiting"
                exit
            } else {
                Stop-VM $server
            }
        $powerstate = get-vm $server | Select-Object PowerState -ExpandProperty *power*
            do {
                $powerstate = get-vm $server | Select-Object PowerState -ExpandProperty *power*
                start-sleep -s 3
                Write-Host $powerstate
            } until ($powerstate -eq "PoweredOff")
        [int]$addedcpu = Read-host "How many CPUs need to be added?".Trim()
        [int]$addedmem = Read-host "How much MEMORY is to be added?".Trim()
        $totalcpu = $cpu + $addedcpu
        $totalmem = $mem + $addedmem
        Get-VM $server | Set-VM –NumCpu $totalcpu -MemoryGB $totalmem -WhatIf
        $finalvalidation = Read-Host "Are the new Total Values correct? y/N".ToUpper()
            if ($finalvalidation -eq "N") {
                Write-Host "Please re-review what has been entered and try again."
            } elseif ($finalvalidation -eq "Y") {
                Write-Host "Updating CPU & Memory"
                Get-VM $server | set-VM –NumCpu $totalcpu -MemoryGB $totalmem -Confirm:$false
                Start-Sleep -S 1
                Write-Host "Starting VM"
                Start-VM $server
            } else {
                Write-Host "Incorrect value entered."
                exit
            } 
    $anotherone = Read-host "Do you have any other servers? Y/n".ToUpper()                   
    } Until ($anotherone -eq 'N')

#Section for List method
} elseif ($selection -eq 2) {
    $path = Get-FileName
    $thelist = Get-Content -path $path
    $listcpu = get-vm $thelist | Select-Object *num* -ExpandProperty *num*
    $listmem = get-vm $thelist | Select-Object *MemoryGB* -ExpandProperty MemoryGB
    #Checks the first server for power status. If off, continues through, if on it shuts down the list
    Get-vm $thelist
    if ($thelist.length -eq $listcpu.length ) {
        Stop-VM $thelist    
        Write-Host "Make sure all servers have powered off"
        [int]$addedcpu = Read-host "How many CPUs need to be added?".Trim()
        [int]$addedmem = Read-host "How much MEMORY is to be added?".Trim()
        foreach ($cpuvalue in $listcpu) {
            $totalcpu += @($cpuvalue + $addedcpu)
        }
        foreach ($memvalue in $listmem) {
            $totalmem += @($memvalue + $addedmem)
        }
        Write-Host "Updating CPU & Memory for listed VMs"
        For ($i=0; $i -le [int]$thelist.Length -1; $i++) {
            $powerstate = get-vm $thelist[-$i] | Select-Object PowerState -ExpandProperty *power*
            if ($powerstate -eq "PoweredOff") {
                Get-VM $thelist[$i] | Set-VM –NumCpu $totalcpu[$i] -MemoryGB $totalmem[$i] -Confirm:$false
            } else {
                Write-Host "VMs are not powered off"
                Write-Host "Exiting"
                exit
				}         
		}
        Write-Host "Starting VMs"
        Start-VM $thelist
        Write-Host "Please Verify the end results are correct."
        #Rewrites the total arrays
        $totalmem = @()
        $totalcpu = @() 
    } else {
        Write-Host "
        You will have to enter these manually as there are duplicates. Usually due to a placeholder in Vsphere.
        "
        Write-Host "Exiting"
        exit
        }
    } else {
    #if the user enters anything but 1 or 2 they receive this output.
    Write-Host "Please enter a valid selection"
    } 