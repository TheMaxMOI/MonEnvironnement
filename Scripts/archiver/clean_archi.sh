#!/bin/sh

SCRIPT_DIR=$(dirname "$0")
# --- Imports ---

. "$SCRIPT_DIR/config.sh"

# --- Functions ---
path_strip(){
    echo "$2" | sed "s,$1\/,,"
}

move(){
    local_path=$(path_strip $path $1)

    if [ -d "$1" ]; then
        mkdir "$temp_fold/$local_path"
    fi
    if [ -f "$1" ]; then
        mv "$1" "$temp_fold/$local_path"
    fi
}

# --- Global Variables ---
temp_fold=".tmp"
path=""

saved_archi="$SAVE_FILE"
if [ ! -e $saved_archi ]; then
    echo "Save file not found. Please save your architecture before."
    echo "Use the command : save"
    exit
fi

# --- Main Script ---
flag=0
while IFS= read -r line; do
    if [ $flag -eq 0 ]; then # reading first line to get the root folder
        flag=$(($flag+1))
        path="$line"
        echo "Restoring $path"
        temp_fold="$path/$temp_fold"
        mkdir "$temp_fold"
    else
        move "$line"
    fi
done < "$saved_archi"

echo done retrieving what was saved

for file in "$path"/* "$path"/.[!.]* "$path"/..?*; do
    [ -e "$file" ] && [ "$file" != "$temp_fold" ] && rm -rf "$file"
done
echo removed extra files

for file in "$temp_fold"/* "$temp_fold"/.[!.]* "$temp_fold"/..?*; do
    [ -e "$file" ] && mv "$file" "$path"/
done
rmdir "$temp_fold"
echo everything is cleaned up
