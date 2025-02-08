#!/bin/sh

# This script requires a server with SSH support and passwordless login.

# Place the server (remoteuser@remotehost), destination folder
# (/location/of/backup) and port in dest.txt.
declare -a DEST
DEST=( $(cat $HOME/.config/backup/dest.txt) )
SERVER=${DEST[0]}
SERVER_FOLDER=${DEST[1]}
PORT=${DEST[2]:-4222}

# Inside folders.txt should be the list of folders to backup, as paths relative
# to the home directory.
declare -a FOLDERS
FOLDERS=( $(cat $HOME/.config/backup/folders.txt) )

if ! $(ssh -p $PORT $SERVER 'exit' 2> /dev/null); then
    exit 1;
fi

notify-send "Backup started!" -i $HOME/.config/icons/backup.png

for folder in "${FOLDERS[@]}"; do
    rsync -a --delete --quiet -e "ssh -p $PORT" "$HOME/$folder" "$SERVER:$SERVER_FOLDER"
done

notify-send "Backup finished!" -i $HOME/.config/icons/backup.png
