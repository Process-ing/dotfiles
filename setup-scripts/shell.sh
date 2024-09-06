#!/bin/bash

function flavor_shell() {
    chsh -s $(which zsh)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    place ./config/zsh/.zshrc $HOME/.zshrc
    place ./config/zsh/.p10k.zsh $HOME/.p10k.zsh
}

function flavor_vim() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    place ./config/vim/.vimrc $HOME/.vimrc
    place_dir ./config/nvim/ $HOME/.config/nvim/
    vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"
}

function setup_doom() {
    log "Installing emacs..."
    install_official emacs

    log "Installing doom-emacs..."
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    echo -e '# Add Doom Emacs command to the path\nexport PATH="$HOME/.config/emacs/bin:$PATH"' >> $HOME/.zshrc
    ~/.config/emacs/bin/doom install
}