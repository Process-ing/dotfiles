#!/bin/bash

function config_sddm() {
    # sudo_place $ROOT/config/sddm/sddm.conf /etc/sddm.conf
    # sudo_place $ROOT/config/sddm/sugar-candy/theme.conf /usr/share/sddm/themes/sugar-candy/theme.conf
    # sudo_place $ROOT/config/sddm/sugar-candy/wallpaper.jpg /usr/share/sddm/themes/sugar-candy/wallpaper.jpg
    sudo systemctl enable sddm
}

function config_fonts() {
    mkdir $HOME/.local/share/ &> /dev/null
    mkdir $HOME/.local/share/fonts/ &> /dev/null
    cp -r $ROOT/config/fonts/MesloLGS $HOME/.local/share/fonts/
    fc-cache
}

function place_scripts() {
    mkdir $HOME/.config/scripts &> /dev/null
    for script in $ROOT/config/scripts/*; do
        chmod +x $script
        place $script "$HOME/.config/scripts/$(basename $script)"
    done
}

function config_misc() {
    place $ROOT/config/dunst/dunstrc $HOME/.config/dunst/dunstrc
    place $ROOT/config/fastfetch/config.jsonc $HOME/.config/fastfetch/config.jsonc
    mkdir $HOME/.config/gtk-2.0 &> /dev/null
    mkdir $HOME/.config/gtk-3.0 &> /dev/null
    place $ROOT/config/gtk/.gtkrc-2.0 $HOME/.gtkrc-2.0
    place $ROOT/config/gtk/gtk-2.0/gtkfilechooser.ini $HOME/.config/gtk-2.0/gtkfilechooser.ini
    place $ROOT/config/gtk/gtk-3.0/settings.ini $HOME/.config/gtk-3.0/settings.ini
    place $ROOT/config/i3/config $HOME/.config/i3/config
    place_dir $ROOT/config/kitty/ $HOME/.config/kitty/
    place $ROOT/config/picom/picom.conf $HOME/.config/picom/picom.conf
    place_dir $ROOT/config/polybar/ $HOME/.config/polybar/
    place_dir $ROOT/config/rofi/ $HOME/.config/rofi/
    place_dir $ROOT/config/wallpapers $HOME/.config/wallpapers/
}