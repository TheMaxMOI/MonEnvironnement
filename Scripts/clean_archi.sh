#!/bin/sh

# --- USER SETTINGS ---

path_to_save_archi_sh="$HOME/Desktop/save_archi.sh"

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

if [ ! -e $path_to_save_archi_sh ]; then
    echo "Save Shell Script not found. Please modify the path in clean_archi.sh."
    exit
fi
saved_archi=$(grep -E -o "[_a-zA-Z]+.txt" "$path_to_save_archi_sh")
saved_archi="$HOME/$saved_archi"
if [ ! -e $saved_archi ]; then
    echo "Save file not found. Please save your architecture before."
    echo "Use the command : save"
    exit
fi

# --- Main Script ---
flag=0
while IFS= read -r line; do
    if [ $flag -eq 0 ]; then
        flag=$(($flag+1))
        path="$line"
        echo $path
        temp_fold="$path/$temp_fold"
        mkdir "$temp_fold"
    else
        move "$line"
    fi
done < "$saved_archi"

echo done retrieving what was saved

rm -rf "$path"/*
echo removed extra files

mv "$temp_fold"/* "$path"
rmdir "$temp_fold"
echo everything is cleaned up
