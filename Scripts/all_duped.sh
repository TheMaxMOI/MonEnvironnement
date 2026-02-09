#!/bin/sh

files=""

print_help(){
    echo "Here is some help"
}

add_file_if_exists(){
    if [ -e "$1" ];then
        files="$files $1"
    fi
}

if [ $# -eq 0 ];then
    echo "You must indicate files. see -h"
    exit 0
fi

while [ $# -gt 0 ];do
    case "$1" in
        -f|--file) #TODO
            shift
            echo reading from a file
            ;;
        -h|--help)
            shift
            print_help
            exit 0
            ;;
        *)
            add_file_if_exists "$1"
            shift
            ;;
    esac
done
