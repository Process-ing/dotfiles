#!/usr/bin/env bash

# Based on a script by adi1090x

uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -no-config -theme $HOME/.config/rofi/powermenu.rasi"

# Options
shutdown="  Shutdown"
reboot="  Restart"
lock="  Lock"
suspend="  Sleep"
logout="  Logout"
hibernate="  Hibernate"

# Confirmation
confirm_exit() {
	rofi -dmenu\
        -no-config\
		-i\
		-no-fixed-num-lines\
		-p "Are You Sure? : "\
		-theme $dir/confirm.rasi
}

# Message
msg() {
	rofi -no-config -theme "$dir/message.rasi" -e "Available Options  -  yes / y / no / n"
}

# Variable passed to rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown\n$hibernate"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
case $chosen in
    $shutdown)
		ans=$(confirm_exit &)
		if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
			systemctl poweroff
		elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
			exit 0
        else
			msg
        fi
        ;;
    $reboot)
		ans=$(confirm_exit &)
		if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
			systemctl reboot
		elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
			exit 0
        else
			msg
        fi
        ;;
    $lock)
		sleep 0.15
		$HOME/.config/scripts/lock.sh
	;;
    $suspend)
		sleep 0.15
		$HOME/.config/scripts/suspend.sh
	;;
    $logout)
		ans=$(confirm_exit &)
		if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
			i3-msg exit
		elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
			exit 0
        else
			msg
        fi
        ;;
    $hibernate)
		ans=$(confirm_exit &)
		if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
			sleep 0.35
			$HOME/.config/scripts/hibernate.sh
		elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
			exit 0
        else
			msg
        fi
        ;;

esac
