function setup_passwordless_ssh() {
    ssh-keygen -t ed25519 -N "" -f $HOME/.ssh/id_ed25519
}

function setup_passworded_ssh() {
    ssh-keygen -t ed25519 -f $HOME/.ssh/id_ed25519_2
}