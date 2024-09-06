#!/bin/bash

root=$(dirname $0)
scripts_dir="$root/setup-scripts"

source $scripts_dir/utils.sh
source $scripts_dir/nvidia.sh
source $scripts_dir/packages.sh
source $scripts_dir/shell.sh
source $scripts_dir/config.sh


cat << "EOF"

 __    __     _                            _        
/ / /\ \ \___| | ___ ___  _ __ ___   ___  | |_ ___  
\ \/  \/ / _ \ |/ __/ _ \| '_ ` _ \ / _ \ | __/ _ \ 
 \  /\  /  __/ | (_| (_) | | | | | |  __/ | || (_) |
  \/  \/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/ 
                                                    
                   ___      _    __ _ _             
  /\/\  _   _     /   \___ | |_ / _(_) | ___  ___   
 /    \| | | |   / /\ / _ \| __| |_| | |/ _ \/ __|  
/ /\/\ \ |_| |  / /_// (_) | |_|  _| | |  __/\__ \  
\/    \/\__, | /___,' \___/ \__|_| |_|_|\___||___/  
        |___/                                       


EOF

log "This script will setup the Arch installation."
log "It should be run from the root of the repository."
log "All the replaced files will be placed on '~/.old-dotfiles/'."
echo

if ! ask "Begin the installation?" "N"; then
	wait_for_enter "Exiting."
	exit 0
fi


cat << "EOF"

   ___                 _____           _        _ _ 
  / _ \_ __ ___        \_   \_ __  ___| |_ __ _| | |
 / /_)/ '__/ _ \_____   / /\/ '_ \/ __| __/ _` | | |
/ ___/| | |  __/_____/\/ /_ | | | \__ \ || (_| | | |
\/    |_|  \___|     \____/ |_| |_|___/\__\__,_|_|_|
                                                    


EOF

log "Creating old dotfiles directory..."
mkdir $old_dotfiles &> /dev/null


cat << "EOF"

   ___           _                         
  / _ \__ _  ___| | ____ _  __ _  ___  ___ 
 / /_)/ _` |/ __| |/ / _` |/ _` |/ _ \/ __|
/ ___/ (_| | (__|   < (_| | (_| |  __/\__ \
\/    \__,_|\___|_|\_\__,_|\__, |\___||___/
                           |___/           
       

EOF

exit 0

official_packages=("base-devel" "xorg" "i3-wm" "sddm" "firefox" "discord"
	"kitty" "dunst" "picom" "polybar" "rofi" "zsh" "fastfetch" "dolphin" "feh"
	"xclip" "playerctl" "flameshot" "ttf-jetbrains-mono-nerd" "bluez"
	"trash-cli" "man-db" "man-pages" "udiskie" "vim" "neovim" "chromium"
	"gnome-themes-extra" "sl" "arandr" "autorandr" "linux-lts" "linux-headers"
	"linux-lts-headers" "pipewire" "pipewire-pulse" "pipewire-alsa"
	"pipewire-jack" "btop" "powertop")

aur_packages=("visual-studio-code-bin" "cmatrix-git" "sddm-sugar-candy-git"
	"i3lock-color" "peaclock" "pwvu-control")

log "Configuring pacman..."
sudo_place ./config/pacman/pacman.conf /etc/pacman.conf

log "Updating the system..."
sudo pacman -Syu --noconfirm

install_official "${official_packages[@]}"

log "Installing yay..."
if install_yay; then
	install_aur "${aur_packages[@]}"
else
	log "Failed installing yay. Skipping AUR packages..." "Err"
fi


cat << "EOF"

     __        _____  ___ _____  _   
  /\ \ \/\   /\\_   \/   \\_   \/_\  
 /  \/ /\ \ / / / /\/ /\ / / /\//_\\ 
/ /\  /  \ V /\/ /_/ /_//\/ /_/  _  \
\_\ \/    \_/\____/___,'\____/\_/ \_/
                                     

EOF

if ask "Setup NVIDIA drivers?" "Y"; then
	setup_nvidia
	if ask "Setup Optimus Manager (for deactivating NVIDIA card on laptops)?" "Y"; then
		setup_optimus
	fi
fi


cat << "EOF"

 __ _          _ _ 
/ _\ |__   ___| | |
\ \| '_ \ / _ \ | |
_\ \ | | |  __/ | |
\__/_| |_|\___|_|_|
                   


EOF

log "\nConfiguring zsh with Oh My Zsh and powerlevel10k..."
flavor_shell

log "Configuring vim and neovim"
flavor_vim

if ask "Setup Emacs with Doom?" "Y"; then
	setup_doom
fi

cat << "EOF"

   ___             __ _       
  / __\___  _ __  / _(_) __ _ 
 / /  / _ \| '_ \| |_| |/ _` |
/ /__| (_) | | | |  _| | (_| |
\____/\___/|_| |_|_| |_|\__, |
                        |___/ 


EOF

log "\nConfiguring SDDM..."
config_sddm

log "Configuring fonts..."
config_fonts

log "Setting up scripts..."
place_scripts

log "Setting up the remaining configuration files..."
config_misc


cat << "EOF"

   ___ _       _     _     _             
  / __(_)_ __ (_)___| |__ (_)_ __   __ _ 
 / _\ | | '_ \| / __| '_ \| | '_ \ / _` |
/ /   | | | | | \__ \ | | | | | | | (_| |
\/    |_|_| |_|_|___/_| |_|_|_| |_|\__, |
                                   |___/ 


EOF

echo
if ask -p "Installation completed. Reboot now?" "Y"; then
	sudo reboot
fi
