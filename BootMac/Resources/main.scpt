on run argv
    #Set CL arguments to variables
    #USB identifier
	set usb to item 1 of argv
    #img location
    set iso to item 2 of argv
    log "1"
    #First, we unmount the USB
    do shell script "sudo diskutil unmountDisk " & usb with administrator privileges
    log "2"
    #Second, we convert the iso into an img for use with dd
    do shell script "sudo hdiutil convert -format UDRW -o ~/BootMac.img " & iso with administrator privileges
    log "3"
    #And lastly, we cd into the Home directory (where the img is located) and run dd
	do shell script "cd ~/ && sudo dd if=BootMac.img.dmg of=" & usb & " bs=1m && sudo rm -Rf ~/BootMac.img.dmg" with administrator privileges
    log "4"

    #Isn't AppleScript great!?
end run