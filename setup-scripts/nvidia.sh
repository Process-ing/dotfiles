#!/bin/bash

function setup_nvidia() {
    log "Installing NVIDIA drivers..."
    install_official nvidia nvidia-lts

    log "Setting up NVIDIA modules..."
    sudo sed -i '/^MODULES=/s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
}

function setup_optimus() {
    log "Installing Optimus Manager..."
    install_aur optimus-manager-git

    log "Setting up Optimus Manager..."
    sudo systemctl enable optimus-manager
}
