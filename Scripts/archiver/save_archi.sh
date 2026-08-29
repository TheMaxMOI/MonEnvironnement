#!/bin/sh

SCRIPT_DIR=$(dirname "$0")
# --- Imports ---

. "$SCRIPT_DIR/config.sh"

# --- Functions ---
archi_dfs() {
    for file in "$*"/* "$*"/.[!.]* "$*"/..?*; do
        if [ -d "$file" ]; then
            echo "$file"
            archi_dfs "$file"
        elif [ -f "$file" ]; then
            echo "$file"
        fi
    done
}

print_help(){
    echo "Description:"
    echo "  This command allows to save an architecture (recursivily)."
    echo "  Then using the clean command,"
    echo "  it removes any added file/folder to your architecture."
    echo 
    echo "Usage: save [OPTION or FOLDER]"
    echo "Options:"
    echo "    -h,--help    Display some help about the command"
    echo "    -i,--info    Show the saved architecture"
    echo "    -c,--clear   Remove the saved architecture"
    echo
    echo "Usage examples:"
    echo "  save                  #save \$PWD"
    echo "  save my_folder        #save everything in my_folder"
}

info(){
    cat "$SAVE_FILE" 2> /dev/null
    if [ "$?" -eq 1 ]; then
        echo "The save file has not yet been created at $SAVE_FILE"
    fi
    err=1
}

clear_save_file(){
    if [ ! -f "$SAVE_FILE" ];then
        echo "The save file has already been deleted"
    else
        rm "$SAVE_FILE"
    fi
    err=1
}

parse(){
    while [ $# -gt 0 ]; do
        case "$1" in
            -i|--info) 
                info
                return
                ;;
            -c|--clear)
                clear_save_file
                return
                ;;
            -h|--help)
                print_help
                err=1
                return
                ;;
            *)
                file="$1"
                shift
                ;;
        esac
    done
}

# --- Global Variables ---
path="$PWD"

# --- Main Script ---
if [ $# -ge 1 ]; then
    file=""
    err=0
    parse "$@"
    [ $err -eq 0 ] && path="$path/$file"
    [ $err -eq 1 ] && exit 1
fi

if [ -e "$SAVE_FILE" ]; then
    rm "$SAVE_FILE"
fi

if [ ! -d "$path" ]; then
    echo "The path $path is not a valid folder."
    exit 1
fi

echo "$path" > "$SAVE_FILE"
archi_dfs "$path" >> "$SAVE_FILE"

echo done saving
