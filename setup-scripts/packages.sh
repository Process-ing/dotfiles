#!/bin/bash

function install_official() {
    log "Installing the following packages with pacman: $*"
    wait_for_enter

    for pkg in "$@"; do
        if ! pacman -Qi "$pkg" &> /dev/null; then
            sudo pacman -S "$pkg" --noconfirm
        else
            log "$pkg already installed. Skipping..." "Warn"
        fi
    done
}

function install_yay() {
    git clone https://aur.archlinux.org/yay.git $HOME/yay
    (cd $HOME/yay && makepkg -si --noconfirm)
    return $?
}

function install_aur() {
    log "Installing the following AUR packages with yay: $*"
	wait_for_enter

	for pkg in "$@"; do
		if ! yay -Qi "$pkg" &> /dev/null; then
			yay -S "$pkg" --noconfirm
		else
			log "$pkg already installed. Skipping..." "Warn"
		fi
	done
}