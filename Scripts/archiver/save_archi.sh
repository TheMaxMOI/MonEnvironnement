#!/bin/sh

# --- USER SETTINGS ---

file_name=last_save_archi.txt

# --- Functions ---
archi_dfs() {
    for file in "$*"/*; do
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
    echo ""
    echo "Usage: save [OPTION or FOLDER]"
    echo "Options:"
    echo "\t-h,--help\tDisplay some help about the command"
    echo "\t-i,--info\tShow if possible the saved architecture"
    echo "\t-c,--clear\tRemove if possible the saved architecture"
    echo ""
    echo "Usage examples:"
    echo "  save\t\t\t\t --> save \$PWD"
    echo "  save my_folder\t\t --> save everything in my_folder"
}

parse(){
    while [ $# -gt 0 ]; do
        case "$1" in
            -i|--info) 
                cat "$save_file"
                err=1
                return
                ;;
            -c|--clear)
                rm "$save_file"
                err=1
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
save_file="$HOME/$file_name"
path="$PWD"

# --- Main Script ---
if [ $# -ge 1 ]; then
    file=""
    err=0
    parse "$@"
    [ $err -eq 0 ] && path="$path/$file"
    [ $err -eq 1 ] && exit 1
fi

if [ -e "$save_file" ]; then
    rm "$save_file"
fi

echo "$path" > "$save_file"
archi_dfs "$path" >> "$save_file"

echo done saving
