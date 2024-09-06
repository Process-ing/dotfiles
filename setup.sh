#!/bin/bash

root=$(dirname $0)
scripts_dir="$root/setup-scripts"

source $scripts_dir/utils.sh

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

   ___           _                         
  / _ \__ _  ___| | ____ _  __ _  ___  ___ 
 / /_)/ _` |/ __| |/ / _` |/ _` |/ _ \/ __|
/ ___/ (_| | (__|   < (_| | (_| |  __/\__ \
\/    \__,_|\___|_|\_\__,_|\__, |\___||___/
                           |___/           
       

EOF

exit 0

pacman_packages=("base-devel" "xorg" "i3-wm" "sddm" "firefox" "discord" "kitty"
	"dunst" "picom" "polybar" "rofi" "zsh" "fastfetch" "dolphin" "feh" "xclip"
	"playerctl" "flameshot" "ttf-jetbrains-mono-nerd" "bluez" "trash-cli"
	"man-db" "man-pages" "udiskie" "vim" "neovim" "gnome-themes-extra" "sl"
	"arandr" "autorandr")

aur_packages=("visual-studio-code-bin" "cmatrix-git" "sddm-sugar-candy-git"
	"i3lock-color" "peaclock")

mkdir $old_dotfiles &> /dev/null
log "Configuring pacman..."
sudo_place ./config/pacman/pacman.conf /etc/pacman.conf

log "Updating the system..."
sudo pacman -Syu --noconfirm

log "Installing the following packages with pacman: ${pacman_packages[*]}"
wait_for_enter

for pkg in "${pacman_packages[@]}"; do
	if ! pacman -Qi "$pkg" &> /dev/null; then
		sudo pacman -S "$pkg" --noconfirm
	else
		log "$pkg already installed. Skipping..."
	fi
done

log "Installing yay..."
git clone https://aur.archlinux.org/yay.git $HOME/yay

if (cd $HOME/yay && makepkg -si --noconfirm); then
	log "Installing the following AUR packages with yay: ${aur_packages[*]}"
	wait_for_enter

	for pkg in "${aur_packages[@]}"; do
		if ! yay -Qi "$pkg" &> /dev/null; then
			yay -S "$pkg" --noconfirm
		else
			log "$pkg already installed. Skipping..."
		fi
	done
else
	log "Failed installing yay. Skipping AUR packages..."
fi

cat << "EOF"

 __ _          _ _ 
/ _\ |__   ___| | |
\ \| '_ \ / _ \ | |
_\ \ | | |  __/ | |
\__/_| |_|\___|_|_|
                   

EOF

log "\nConfiguring zsh with Oh My Zsh and powerlevel10k..."

chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
place ./config/zsh/.zshrc $HOME/.zshrc
place ./config/zsh/.p10k.zsh $HOME/.p10k.zsh

log "Configuring vim and neovim"

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
place ./config/vim/.vimrc $HOME/.vimrc
place_dir ./config/nvim/ $HOME/.config/nvim/
vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"

cat << "EOF"

   ___             __ _       
  / __\___  _ __  / _(_) __ _ 
 / /  / _ \| '_ \| |_| |/ _` |
/ /__| (_) | | | |  _| | (_| |
\____/\___/|_| |_|_| |_|\__, |
                        |___/ 


EOF

log "\nConfiguring SDDM..."

sudo_place ./config/sddm/sddm.conf /etc/sddm.conf
sudo_place ./config/sddm/sugar-candy/theme.conf /usr/share/sddm/themes/sugar-candy/theme.conf
sudo_place ./config/sddm/sugar-candy/wallpaper.jpg /usr/share/sddm/themes/sugar-candy/wallpaper.jpg
sudo systemctl enable sddm

log "Configuring fonts..."

mkdir $HOME/.local/share/ &> /dev/null
mkdir $HOME/.local/share/fonts/ &> /dev/null
cp -r ./config/fonts/MesloLGS $HOME/.local/share/fonts/
fc-cache

log "Setting up scripts..."

mkdir $HOME/.config/scripts &> /dev/null
for script in ./config/scripts/*; do
	chmod +x $script
	place $script "$HOME/.config/scripts/$(basename $script)"
done

log "Setting up the remaining configuration files..."

place ./config/dunst/dunstrc $HOME/.config/dunst/dunstrc
place ./config/fastfetch/config.jsonc $HOME/.config/fastfetch/config.jsonc
mkdir $HOME/.config/gtk-2.0 &> /dev/null
mkdir $HOME/.config/gtk-3.0 &> /dev/null
place ./config/gtk/.gtkrc-2.0 $HOME/.gtkrc-2.0
place ./config/gtk/gtk-2.0/gtkfilechooser.ini $HOME/.config/gtk-2.0/gtkfilechooser.ini
place ./config/gtk/gtk-3.0/settings.ini $HOME/.config/gtk-3.0/settings.ini
place ./config/i3/config $HOME/.config/i3/config
place_dir ./config/kitty/ $HOME/.config/kitty/
place ./config/picom/picom.conf $HOME/.config/picom/picom.conf
place_dir ./config/polybar/ $HOME/.config/polybar/
place_dir ./config/rofi/ $HOME/.config/rofi/
place_dir ./config/wallpapers $HOME/.config/wallpapers

echo
if ask -p "Installation completed. Reboot now?" "Y"; then
	sudo reboot
fi
