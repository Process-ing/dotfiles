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

function log() {
    echo -e "\033[96m[Script]\033[0m $1"
}

function ask() {
    echo -en "\033[96m[Script]\033[0m $1 $([[ $2 = "Y" ]] && echo "[Y/n]" || echo "[y/N]"): "
    read answer
    if [[ ("$answer" =~ ^[Yy]$) || ($2 = "Y" && "$answer" =~ ^$) ]]; then return 0; else return 1; fi
}

function wait_for_enter() {
    echo -en "\033[96m[Script]\033[0m $1 Press ENTER to continue..."
    read
}