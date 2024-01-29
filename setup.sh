#!/bin/bash

old_dotfiles="$HOME/.old-dotfiles"

function backup() {
	mv -f $1 $old_dotfiles/$(basename $1) &> /dev/null
}

function sudo_backup() {
	sudo mv -f $1 $old_dotfiles/$(basename $1) &> /dev/null
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

cat << "EOF"

 __      __          ___                                            __             
/\ \  __/\ \        /\_ \                                          /\ \__          
\ \ \/\ \ \ \     __\//\ \     ___    ___     ___ ___      __      \ \ ,_\   ___   
 \ \ \ \ \ \ \  /'__`\\ \ \   /'___\ / __`\ /' __` __`\  /'__`\     \ \ \/  / __`\ 
  \ \ \_/ \_\ \/\  __/ \_\ \_/\ \__//\ \L\ \/\ \/\ \/\ \/\  __/      \ \ \_/\ \L\ \
   \ `\___x___/\ \____\/\____\ \____\ \____/\ \_\ \_\ \_\ \____\      \ \__\ \____/
    '\/__//__/  \/____/\/____/\/____/\/___/  \/_/\/_/\/_/\/____/       \/__/\/___/ 
                                                                                   
                                                                                   
                     ____            __       ___      ___                         
 /'\_/`\            /\  _`\         /\ \__  /'___\ __ /\_ \                        
/\      \  __  __   \ \ \/\ \    ___\ \ ,_\/\ \__//\_\\//\ \      __    ____       
\ \ \__\ \/\ \/\ \   \ \ \ \ \  / __`\ \ \/\ \ ,__\/\ \ \ \ \   /'__`\ /',__\      
 \ \ \_/\ \ \ \_\ \   \ \ \_\ \/\ \L\ \ \ \_\ \ \_/\ \ \ \_\ \_/\  __//\__, `\     
  \ \_\\ \_\/`____ \   \ \____/\ \____/\ \__\\ \_\  \ \_\/\____\ \____\/\____/     
   \/_/ \/_/`/___/> \   \/___/  \/___/  \/__/ \/_/   \/_/\/____/\/____/\/___/      
               /\___/                                                              
               \/__/                                                               

This script will setup the Arch installation.
It should be run from the root of the repository.
All the replaced files will be placed on '~/.old-dotfiles/'.

EOF

read -p "Begin the installation? [Y/n]: " answer
if [[ ! "$answer" =~ ^[Yy]$|^$ ]]; then
	read -p "Exiting. Press ENTER to continue..."
	exit 0
fi
cat << "EOF"

 ____                 __                                        
/\  _`\              /\ \                                       
\ \ \L\ \ __      ___\ \ \/'\      __       __      __    ____  
 \ \ ,__/'__`\   /'___\ \ , <    /'__`\   /'_ `\  /'__`\ /',__\ 
  \ \ \/\ \L\.\_/\ \__/\ \ \\`\ /\ \L\.\_/\ \L\ \/\  __//\__, `\
   \ \_\ \__/.\_\ \____\\ \_\ \_\ \__/.\_\ \____ \ \____\/\____/
    \/_/\/__/\/_/\/____/ \/_/\/_/\/__/\/_/\/___L\ \/____/\/___/ 
                                            /\____/             
                                            \_/__/              

EOF

pacman_packages=("base-devel" "xorg" "i3-wm" "sddm" "firefox" "discord" "kitty" "dunst" "picom" "polybar" "rofi" "zsh" "fastfetch" "nemo" "feh" "xclip" "playerctl" "flameshot" "os-prober" "ttf-jetbrains-mono-nerd" "bluez" "trash-cli" "man-db" "man-pages" "udisks2" "vim" "neovim" "materia-gtk-theme" "sl")
aur_packages=("visual-studio-code-bin" "cmatrix-git" "sddm-sugar-candy-git" "i3lock-color")

mkdir $old_dotfiles &> /dev/null
echo -e "Configuring pacman..."
sudo_place ./config/pacman/pacman.conf /etc/pacman.conf

echo "Updating the system..."
sudo pacman -Syu --noconfirm

echo "Installing the following packages with pacman: ${pacman_packages[*]}"
read -p "Press ENTER to continue..."

for pkg in "${pacman_packages[@]}"; do
	if ! pacman -Qi "$pkg" &> /dev/null; then
		sudo pacman -S "$pkg" --noconfirm
	else
		echo "$pkg already installed. Skipping..."
	fi
done

echo -e "Installing paru..."
git clone https://aur.archlinux.org/paru.git $HOME/paru

if (cd $HOME/paru && makepkg -si --noconfirm); then
	echo "Installing the following packages with aur: ${aur_packages[*]}"
	read -p "Press ENTER to continue..."
	for pkg in "${aur_packages[@]}"; do
		if ! paru -Qi "$pkg" &> /dev/null; then
			paru -S "$pkg" --noconfirm
		else
			echo "$pkg already installed. Skipping..."
		fi
	done
else
	echo "Failed installing paru. Skipping AUR packages..."
fi

cat << "EOF"

 ____    __              ___    ___      
/\  _`\ /\ \            /\_ \  /\_ \     
\ \,\L\_\ \ \___      __\//\ \ \//\ \    
 \/_\__ \\ \  _ `\  /'__`\\ \ \  \ \ \   
   /\ \L\ \ \ \ \ \/\  __/ \_\ \_ \_\ \_ 
   \ `\____\ \_\ \_\ \____\/\____\/\____\
    \/_____/\/_/\/_/\/____/\/____/\/____/

EOF

echo -e "\nConfiguring zsh with Oh My Zsh and powerlevel10k..."
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
place ./config/zsh/.zshrc $HOME/.zshrc
place ./config/zsh/.p10k.zsh $HOME/.p10k.zsh

echo "Configuring vim and neovim"

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
place ./config/vim/.vimrc $HOME/.vimrc
place_dir ./config/nvim/ $HOME/.config/nvim/
vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"

cat << "EOF"

 ____                       ___                 
/\  _`\                   /'___\ __             
\ \ \/\_\    ___     ___ /\ \__//\_\     __     
 \ \ \/_/_  / __`\ /' _ `\ \ ,__\/\ \  /'_ `\   
  \ \ \L\ \/\ \L\ \/\ \/\ \ \ \_/\ \ \/\ \L\ \  
   \ \____/\ \____/\ \_\ \_\ \_\  \ \_\ \____ \ 
    \/___/  \/___/  \/_/\/_/\/_/   \/_/\/___L\ \
                                         /\____/
                                         \_/__/ 

EOF

echo -e "\nConfiguring SDDM..."

sudo_place ./config/sddm/sddm.conf /etc/sddm.conf
sudo_place ./config/sddm/sugar-candy/theme.conf /usr/share/sddm/themes/sugar-candy/theme.conf
sudo_place ./config/sddm/sugar-candy/wallpaper.jpg /usr/share/sddm/themes/sugar-candy/wallpaper.jpg
sudo systemctl enable sddm

echo "Configuring fonts..."

mkdir $HOME/.local/share/ &> /dev/null
mkdir $HOME/.local/share/fonts/ &> /dev/null
cp -r ./config/fonts/MesloLGS $HOME/.local/share/fonts/
fc-cache

echo "Setting up scripts..."
mkdir $HOME/.config/scripts &> /dev/null
for script in ./config/scripts/*; do
	chmod +x $script
	place $script "$HOME/.config/scripts/$(basename $script)"
done

echo "Setting up the remaining configuration files..."

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
read -p "Installation completed. Reboot now? [Y/n]: " answer
if [[ "$answer" =~ ^[Yy]$|^$ ]]; then
	sudo reboot
fi
