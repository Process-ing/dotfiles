#!/bin/bash

OLD_DOTFILES="$HOME/.old-dotfiles"

function setup_old_dotfiles() {
	mkdir $OLD_DOTFILES &> /dev/null
}

function backup() {
	mv -f $1 $OLD_DOTFILES/$(basename $1) &> /dev/null
}

function sudo_backup() {
	sudo mv -f $1 $OLD_DOTFILES/$(basename $1) &> /dev/null
}

function place() {
	backup $2
	mkdir $(dirname $2) &> /dev/null
	ln $1 $2 &> /dev/null
}

function sudo_place() {
	sudo_backup $2
	sudo mkdir $(dirname $2) &> /dev/null
	sudo ln $1 $2 &> /dev/null
}

function place_dir() {
	backup $2
	mkdir $2 &> /dev/null
	for file in $1/*; do
		ln $file $2/$(basename $file) &> /dev/null
	done
}

function log() {
    case $2 in
        "Warn") prefix="\033[93m[Script]\033[0m";;
        "Err") prefix="\033[91m[Script]\033[0m";;
        *) prefix="\033[96m[Script]\033[0m";;
    esac

    echo -e "$prefix $1"
}

function ask() {
    echo -en "\033[92m[Script]\033[0m $1 $([[ $2 = "Y" ]] && echo "[Y/n]" || echo "[y/N]"): "
    read answer
    if [[ ("$answer" =~ ^[Yy]$) || ($2 = "Y" && "$answer" =~ ^$) ]]; then return 0; else return 1; fi
}

function wait_for_enter() {
    echo -en "\033[96m[Script]\033[0m$([[ -n "$1" ]] && echo " $1") Press ENTER to continue..."
    read
}