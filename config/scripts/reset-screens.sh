#!/bin/bash

case $1 in	
	ph)
		autorandr portable-horizontal
		;;
	pv)
		autorandr portable-vertical
		;;
	"")
		autorandr --change
		;;
	*)
		autorandr $1
		;;
esac

wait $BACK_PID
feh --bg-fill $HOME/.config/wallpapers/main.jpg
$HOME/.config/polybar/launch.sh 2> /dev/null
