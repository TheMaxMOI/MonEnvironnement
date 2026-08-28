#!/bin/sh

help () {
    echo "This script allows one to map recursively a command to an architecture."
    echo ""
    echo "Usage \`$0 <cmd>'"
    echo ""
    echo "Examples:"
    echo "  - $0 cat"
    echo "  - $0 wc -l"
    echo "  - $0 head -n 10"
}

if [ "$1" = "--help" ]; then
    help
    exit 1
fi

unkwn_cmd () {
    if [ -z "$1" ]; then
        echo 1
    else
        type -f -p "$1" > /dev/null 2>&1; echo $?
    fi
}

if [ "$(unkwn_cmd "$1")" -eq 1 ]; then
    echo "The given command was not found in the env!"
    exit 2
fi

cmd="$*"

map () {
    for file in "$1"/*; do
        if [ -f "$file" ]; then
            echo "Applied to $file"
            if ! $cmd "$file"; then
                echo "'$cmd' failed on $file" >&2
                exit 3
            fi
        fi
        if [ -d "$file" ]; then
            echo "Exploring $file"
            map "$file"
            echo ""
        fi
    done
}

map "$PWD"
