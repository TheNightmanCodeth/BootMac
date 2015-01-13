on run argv
	set iso to item 1 of argv
	do shell script "sudo hdiutil convert -format UDRW -o ~/BootMac.img " & iso with administrator privileges
end run