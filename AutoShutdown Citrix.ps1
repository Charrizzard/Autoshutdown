# Static Parameters
$ServerIP="192.168.100.4"
$UserName="root"
$Password="P@ssw0rd"

# Blacklist of VM name_labels
$blacklist=@("Control domain on host: xenserver-brmwifdj")

function GetVMS(){
    #get all the vms and filters out all the templates and blacklisted ones
    $VMList=Get-XenVM | Where {-Not($_.is_a_template)`
                        -and $blacklist -notcontains $_.name_label}
    return $VMList
}

# Shuts down a VM
function ShutdownVM($VMObject){
    "Shutting down $($VMObject.name_label)"
    Invoke-XenVM $VMObject -XenAction Shutdown -Async -PassThru | Wait-XenTask -ShowProgress
}

# Disables the host and shutsdown
function ShutdownHost(){
    "Shutting down host $($XenHost.hostname)"
    Invoke-XenHost -XenAction Disable -XenHost $XenHost -PassThru
    Invoke-XenHost -XenAction Shutdown -XenHost $XenHost -Async -PassThru | Wait-XenTask -ShowProgress
}

# Connect to xen server
Connect-XenServer -Server $ServerIP -UserName $UserName -Password $Password

# Get XenServer host
$XenHost=Get-XenHost

# Get list of VMs and filter out all the Templates 
$VMS=GetVMS

# Loop throug the list of VMs
ForEach($VM in $VMS){

    # Check if the VM is powered on first
    if($VM.power_state -eq "Running"){
        ShutdownVM($VM)
    }
    else{
        "$($VM.name_label) is currently not running, skipping shutdown task..."
    }

}

#shutdown XenServer host
ShutdownHost

# Close connection when done
Disconnect-XenServer
