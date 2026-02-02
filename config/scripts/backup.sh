#!/bin/bash

# This script requires servers with SSH support and passwordless login.
# Each line in dest.txt should contain: server destination_folder [port]
# Example:
#   user@host1.com /backup/location 22
#   user@host2.com /backup/location 2222

# Inside folders.txt should be the list of folders to backup, as paths relative
# to the home directory.
declare -a FOLDERS
FOLDERS=( $(cat $HOME/.config/backup/folders.txt) )

# Read all server configurations
declare -a SERVERS
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    SERVERS+=("$line")
done < "$HOME/.config/backup/dest.txt"

if [ ${#SERVERS[@]} -eq 0 ]; then
    echo 'Error: No servers configured in dest.txt'
    exit 1
fi

backup_to_server() {
    local server_line="$1"
    read -r server folder port <<< "$server_line"
    port=${port:-22}

    # Check if server is reachable
    if ! ssh -i ~/.ssh/id_ed25519_2 -p "$port" "$server" 'exit' 2> /dev/null; then
        echo "Server $server is unreachable"
        return 1
    fi

    echo "Backing up to $server..."
    for folder_path in "${FOLDERS[@]}"; do
        rsync -a --delete --quiet -e "ssh -i ~/.ssh/id_ed25519_2 -p $port" "$HOME/$folder_path" "$server:$folder" || return 1
    done

    echo "Backup to $server completed successfully"
    return 0
}

notify-send "Backup started!" -i $HOME/.config/icons/backup.png

# Track PIDs and results
declare -A pids
declare -a results_files
successful=0

# Start backup jobs in parallel
for server_config in "${SERVERS[@]}"; do
    result_file=$(mktemp)
    results_files+=("$result_file")

    (
        if backup_to_server "$server_config"; then
            echo "success" > "$result_file"
        else
            echo "failure" > "$result_file"
        fi
    ) &

    pids["$!"]="$result_file"
done

# Wait for all background jobs
for pid in "${!pids[@]}"; do
    wait "$pid"
done

# Check results
for result_file in "${results_files[@]}"; do
    if [ -f "$result_file" ]; then
        result=$(cat "$result_file")
        [ "$result" == "success" ] && ((successful++))
        rm -f "$result_file"
    fi
done

# Check if at least one server was successful
if [ $successful -eq 0 ]; then
    notify-send "Backup failed!" "All servers are unreachable" -i $HOME/.config/icons/backup.png -u critical
    echo 'Error: All servers are unreachable'
    exit 1
fi

notify-send "Backup finished!" "Successfully backed up to $successful/${#SERVERS[@]} server(s)" -i $HOME/.config/icons/backup.png
