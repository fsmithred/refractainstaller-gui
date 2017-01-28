#!/usr/bin/env bash
#
# New wrapper for refractainstaller-gui/yad 9.1.2



if [[ -f /usr/bin/yad ]]; then
	yadversion=$(yad --version | cut -d. -f2)
	if (( $yadversion >= 17 )); then
		installer="/usr/bin/refractainstaller-yad"
	fi
elif
	[[ -f /usr/bin/zenity ]]; then
		installer="/usr/bin/refractainstaller-gui"
else
	xterm -hold -fa monaco -fs 14 -geometry 80x20+0+0 -e echo $"
  Neither Yad nor Zenity is installed, or the version of Yad is too old.
  You can't run the GUI version of Refracta Installer without one of 
  those. Instead, you can run 'refractainstaller' from a terminal 
  or console for the CLI version.
  " &
fi


yad --question --title=$"Admin Mode"  --button=$" use 'su' ":0 \
	--button=$" use sudo ":1 --button=$"Exit":2 \
	--text=$"What method do you use to become Administrator / root?

Note: This is only for the purpose of starting this script.
It does not change anything.
You will be asked later to choose the method you
want to use in the installed system."
	
	ans="$?"
	if [[ $ans -eq 0 ]] ; then
		xterm -fa mono -fs 12 -e su -c "$installer"
	elif [[ $ans -eq 1 ]] ;then
		xterm -fa mono -fs 12 -e  "sudo $installer"
	elif [[ $ans -eq 2 ]]; then
		echo "Good-bye."
		exit 0
	fi

echo "Done."
exit 0

