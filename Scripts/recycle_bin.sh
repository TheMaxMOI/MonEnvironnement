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
    echo "$*" | sed 's,/$,,' | sed "s,^.*/,,"
}

extract_index(){
    var=$(echo "$1" | grep -o "[0-9]*$")
    if [ -z "$var"];then
        var=0
    fi
    echo $var
}

delete_with_conflict(){
    name="$1"
    full_path="$2"
    main_log="$bin_pathname/.log_$name"

    log_content=""
    if [ -e "$main_log" ]; then 
        IFS= read -r log_content < "$main_log"
    fi

    if [ "conflict" = "$log_content" ];then
        echo There has been a conflict
        max=0
        for filename in "$bin_pathname/$name/"*;do
            if [ -e "$filename" ]; then
                base=$(strip_path "$filename")
                idx=$(extract_index "$base")
                if [ "$idx" -gt "$max" ]; then
                    max=$idx
                fi
            fi
        done
        next=$(($number+1))
        echo The next index is $next
        mv "$full_path/$name" "$bin_pathname/$name/${name}__$next"
        echo  "$full_path/$name" > "$bin_pathname/.log_${name}__$next"

    else #Resolving a conflict for the first time
        echo Resolving a conflict for the first time

        mv "$bin_pathname/$name" "$bin_pathname/${name}__0"
        mkdir "$bin_pathname/$name"
        mv "$bin_pathname/${name}__0" "$bin_pathname/$name"

        if [ -e "$main_log" ]; then
            mv "$main_log" "$bin_pathname/$name/.log_${name}__0"
        fi

        mv "$full_path/$name" "$bin_pathname/$name/${name}__1"
        echo "$full_path/$name" > "$bin_pathname/$name/.log_${name}__1"

        echo "conflict" > "$bin_pathname/.log_$name"
    fi
        echo "moved $name to the bin"
}

delete(){
    while [ $# -ne 0 ]; do
        full_path=$(abspath "$1")
        if [ ! -e $full_path ]; then
            echo "$1 was not been found"
            shift
            continue
        fi

        name=$(strip_path "$1")

        if [ -e "$bin_pathname/$name" ];then
            delete_with_conflict "$name" "$full_path"
            shift
            continue
        fi

        mv "$full_path/$name" "$bin_pathname"
        echo  "$full_path/$name" > "$bin_pathname/.log_$name"
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
            -i++|--info++)
                tree $bin_pathname -a
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

bin_pathname=$(echo $bin_pathname | sed 's,/$,,')

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

