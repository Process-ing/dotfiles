#!/bin/bash

ROOT=$(dirname $0)

source $ROOT/setup-scripts/utils.sh
source $ROOT/setup-scripts/nvidia.sh
source $ROOT/setup-scripts/packages.sh
source $ROOT/setup-scripts/shell.sh
source $ROOT/setup-scripts/ssh.sh
source $ROOT/setup-scripts/config.sh
source $ROOT/setup-scripts/backup.sh

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
setup_old_dotfiles

cat << "EOF"

   ___           _
  / _ \__ _  ___| | ____ _  __ _  ___  ___
 / /_)/ _` |/ __| |/ / _` |/ _` |/ _ \/ __|
/ ___/ (_| | (__|   < (_| | (_| |  __/\__ \
\/    \__,_|\___|_|\_\__,_|\__, |\___||___/
                           |___/


EOF

official_packages=("base-devel"                                                    # AUR helper
    "linux-lts" "linux-lts-headers"                                                # Kernel
    "os-prober" "efibootmgr" "grub" "sbctl"                                        # Bootloader
    "xorg" "xorg-xinit" "i3-wm"                                                    # Xorg adn i3
    "networkmanager"                                                               # Network
    "firefox" "discord" "nemo" "feh" "vim" "neovim"                                # Apps
    "kitty" "dunst" "picom" "polybar" "rofi" "zsh" "fastfetch"                     # Terminal and status bar
    "pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "pavucontrol"      # Audio
    "sl" "xclip" "playerctl" "flameshot" "bluez" "trash-cli" "man-db" "man-pages"
    "udiskie" "arandr" "autorandr" "btop" "powertop" "tlp" "brightnessctl"
    "polkit-gnome" "unzip" "rsync" "cronie"                                        # Utilities
    "sddm" "qt5-graphicaleffects" "qt5-quickcontrols2" "qt5-svg"                   # Login manager
    "gnome-themes-extra"                                                           # Themes
    "ttf-jetbrains-mono-nerd" "ttf-droid"                                          # Fonts
)

aur_packages=("visual-studio-code-bin" "cmatrix-git" "i3lock-color" "peaclock"
    "adwaita-qt5-git" "adwaita-qt6-git" "checkupdates-with-aur")

log "Configuring pacman..."
sudo_place $ROOT/config/pacman/pacman.conf /etc/pacman.conf

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

if ask "Setup Emacs with Doom? [DEPRECATED - MIGHT NOT WORK]" "N"; then
	setup_doom
fi

cat << "EOF"

 __  __
/ _\/ _\  /\  /\
\ \ \ \  / /_/ /
_\ \_\ \/ __  /
\__/\__/\/ /_/



EOF

if ask "Setup SSH keys?" "Y"; then
   log "Setting passwordless SSH key (stored in $HOME/.ssh/id_ed25519_2)..."
   setup_passwordless_ssh

   log "Setting SSH key with password..."
   prompt "Enter your email" "EMAIL"
   setup_passworded_ssh $EMAIL

   SSH_KEYS_SETUP=true
else
   SSH_KEYS_SETUP=false
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

log "Configuring power management settings..."
config_power_management

log "Configuring hibernation..."
config_hibernation

log "Configuring touchpad settings..."
config_touchpad

log "Configuring cron..."
config_cron

log "Configuring permissions..."
config_perms

log "Setting up the remaining configuration files..."
config_misc

if $SSH_KEYS_SETUP; then
   cat << "EOF"

   ___            _
  / __\ __ _  ___| | ___   _ _ __  ___
 /__\/// _` |/ __| |/ / | | | '_ \/ __|
/ \/  \ (_| | (__|   <| |_| | |_) \__ \
\_____/\__,_|\___|_|\_\\__,_| .__/|___/
                            |_|


EOF

   log "Setting up automatic backups requires a server with passwordless SSH." "Warn"
   if ask "Setup automatic backups?" "N"; then
      prompt "Enter the server destination (remoteuser@remotehost)" "SERVER_HOST"
      prompt "Enter the server port" "SERVER_PORT"
      prompt "Enter the server destination folder" "SERVER_FOLDER"
      config_backups $SERVER_HOST $SERVER_PORT $SERVER_FOLDER

      log "Later, you can specify the folders to backup in '~/.config/backup/folders.txt'."
      log "To restore the backups, use the 'rbackup' command."
      wait_for_enter
   fi
fi

cat << "EOF"

   ___ _       _     _     _
  / __(_)_ __ (_)___| |__ (_)_ __   __ _
 / _\ | | '_ \| / __| '_ \| | '_ \ / _` |
/ /   | | | | | \__ \ | | | | | | | (_| |
\/    |_|_| |_|_|___/_| |_|_|_| |_|\__, |
                                   |___/


EOF

echo
if ask "Installation completed. Reboot now?" "Y"; then
	sudo reboot
fi
