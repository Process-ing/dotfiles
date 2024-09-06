#!/bin/bash

function setup_nvidia() {
    install_official nvidia nvidia-lts

    log "Setting up NVIDIA modules..."
    sudo sed -i '/^MODULES=/s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P

    install_aur optimus-manager-git
    sudo systemctl enable optimus-manager
}