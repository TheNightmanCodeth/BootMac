on run argv
	set usb to item 1 of argv
	do shell script "sudo diskutil unmountDisk " & usb with administrator privileges
end run