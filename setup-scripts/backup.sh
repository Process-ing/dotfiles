function config_backups() {
    mkdir $HOME/.config/backup &> /dev/null
    touch $HOME/.config/backup/dest.txt
    mkdir $HOME/Pictures
    echo "Pictures" > $HOME/.config/backup/folders.txt
    echo "$1 $3 $2" > $HOME/.config/backup/dest.txt
    ssh-copy-id -i $HOME/.ssh/id_ed25519_2.pub -p $2 $1
    sudo cp $HOME/.config/scripts/backup.sh /etc/cron.daily/backup
}