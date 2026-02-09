#!/bin/sh

### --- USER PARAMETERS ---

bin_pathname=/home/virtual.maximilien/Desktop/recycle_bin

### --- Global Variables ---
mode=""
files=""

### --- Functions ---
create_bin(){
    if [ ! -e "$bin_pathname" ]; then
        mkdir "$bin_pathname"
        echo "Created bin"
    else
        echo "bin path is : $bin_pathname"
    fi
}

abspath() {
    path=$1
    case "$path" in
        /*) ;;
        *)  path=$(pwd -P)/$path ;;
    esac

    saved_IFS=$IFS
    IFS=/
    set -- $path
    IFS=$saved_IFS
    out=
    for part do
        case "$part" in
            ""|.)
                continue
                ;;
            ..)
                out=${out%/*}
                ;;
            *)
                out=$out/$part
                ;;
        esac
    done
    out="${out:-/}"
    echo "${out%/*}"
}

strip_path(){
    echo "$*" | sed "s,^.*/,,"
}

delete(){
    while [ $# -ne 0 ]; do
        full_path=$(abspath "$1")
        if [ ! -e $full_path ]; then
            echo "$1 was not been found"
            shift
            continue
        fi

        mv "$1" "$bin_pathname"
        name=$(strip_path "$1")
        echo  $full_path > "$bin_pathname/.log_$name"
        echo "moved $1 to the bin"
        shift
    done
}

empty(){
    if [ ! -e "$bin_pathname" ]; then
        echo "bin doesn't exist"
        exit
    fi
    rm -rf "$bin_pathname"/*
    rm -rf "$bin_pathname"/.log_*
    echo "The bin has been emptied"
}

restore(){
    while [ $# -ne 0 ]; do
        log_path="$bin_pathname/.log_$1"
        if [ ! -e $log_path ]; then
            echo "$1 is an untracked file"
            shift
            continue
        fi

        previous_path=""
        IFS= read -r previous_path < "$log_path"
        echo "restoring $1 to $previous_path"
        mv "$bin_pathname/$1" "$previous_path"
        rm $log_path
        shift
    done
}

print_help(){
    echo "Here is some help"
}

parse_cmd(){
    while [ $# -ne 0 ]; do
        case "$1" in
            delete)
                mode="delete"
                shift
                ;;
            empty)
                mode="empty"
                shift
                ;;
            restore)
                mode="restore"
                shift
                ;;
            -h|--help)
                print_help
                exit
                ;;
            -p|--path)
                echo "Bin is located to : $bin_pathname"
                exit
                ;;
            -i|--info)
                ls $bin_pathname
                exit
                ;;
            -i+|--info+)
                ls -a $bin_pathname
                exit
                ;;
            *)
                break
                ;;
        esac
    done
    files=$@
}

### --- Main Script ---

parse_cmd $@

if [ -z "$files" ] && [ "$mode" = "delete" ]; then 
    echo "Please provide files or folders to delete" 
    exit
fi
if [ -z "$files" ] && [ "$mode" = "restore" ]; then 
    echo "Please provide files or folders to restore" 
    exit
fi

create_bin

if [ "$mode" = "delete" ]; then
    delete $files
    exit
fi

if [ "$mode" = "empty" ]; then
    empty
    exit
fi

if [ "$mode" = "restore" ]; then
    restore $files
    exit
fi
