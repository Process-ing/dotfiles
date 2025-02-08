#!/bin/bash

COMMANDS=$(cat << EOF
fastfetch
yay
notify-send "System updated!" -i $HOME/.config/icons/update.png
read -p 'Press ENTER to continue...'
EOF
)

kitty sh -c "$COMMANDS"