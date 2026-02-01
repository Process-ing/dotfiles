#!/bin/bash

COMMANDS=$(cat << EOF
fastfetch
if yay --sudoloop; then
	notify-send "System updated!" -i $HOME/.config/icons/update.png
else
	notify-send 'System failed to update. Please try again.'
fi
read -p 'Press ENTER to continue...'
EOF
)

kitty sh -c "$COMMANDS"
