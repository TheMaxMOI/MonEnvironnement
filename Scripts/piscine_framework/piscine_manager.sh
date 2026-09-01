#!/bin/sh

### === IMPORTS ===
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/config.sh"


### === ERROR CODES ===
OK=0
ERROR=1
CONFIG_ERROR=2
CONFLICT=3


### === SMALL HELPER FUNCTIONS ===
format_cpable () { # $1 = string
    echo "'$1\`"
}

### === CONFIG CHECKS ===
if [ ! -d "$DIR_CACHE" ]; then
    echo "The folder that holds the cache was not found at $(format_cpable "$DIR_CACHE")!"
    exit $CONFIG_ERROR
fi

if [ ! -d "$CACHE" ]; then
    echo "Created cache at $(format_cpable "$CACHE")!"
    mkdir "$CACHE"
fi

if [ ! -f "$MAKE_HEADER" ]; then
    echo "The make_header.sh file was not found at $(format_cpable "$MAKE_HEADER")!"
    exit $CONFIG_ERROR
fi

echo "work directory: $(format_cpable "$WORK_DIR")"


### === GLOBAL VARS ===
CACHE_NAME="exercise_name_holder"
CACHE_FILE="$CACHE/$CACHE_NAME"
FORMAT="clang-format"
FMT_FLAG="-i"


### === FUNCTIONS ===
start_exo () { # $1 = string, be nice and give [a-zA-Z0-9_]+ # Piscine has distinct exercise
    if [ -f "$CACHE_FILE" ]; then
        echo "An exercise is already started!"
        echo "You must remove the cache at $(format_cpable "$CACHE_FILE") to proceed."
        exit $CONFLICT
    fi

    FOLD="$WORK_DIR/$1"
    CFILE="$FOLD/$1.c"

    if [ ! -f "$CFILE" ]; then
        mkdir "$FOLD"
        echo "#include \"$1.h\"" > "$CFILE"
    else
        echo "Resuming the exercise \"$1\""
    fi


    echo "$1" > "$CACHE_FILE"

    echo "Ready to start the exercise \"$1\"."
    echo "You can edit $(format_cpable "$CFILE")"
}

get_exo () {
    if [ ! -f "$CACHE_FILE" ]; then
        echo "Missing cache at $(format_cpable "$CACHE"). It should have been holding the current exercise name."
        exit $ERROR
    fi
    
    cat "$CACHE_FILE"
}

end_exo () { # no args -> reads from cache
    name="$(get_exo)" 
    echo "Identified current exercise to be \"$name\"."
    
    CFILE="$WORK_DIR/$name/$name.c"
    HFILE="$WORK_DIR/$name/$name.h"

    "$FORMAT" "$FMT_FLAG" "$CFILE"
    echo "Formatted the file at $(format_cpable "$CFILE")."

    "$MAKE_HEADER" "$CFILE"
    echo "Generated a header file for $CFILE at $(format_cpable "$HFILE")."
    
    rm "$CACHE_FILE"
    echo "The cache has been removed. You can now start a new exercise."
}


### === Main ===
case "$1" in
    --help)
        echo "TODO: help(){}"
        exit $OK
    ;;
    start)
        shift
        if [ $# -ne 1 ]; then
            echo "Not the right amount of args for \"start\"."
            echo
            echo "More information with $(format_cpable "$0 --help")"
            exit $ERROR
        fi

        start_exo "$1"
        exit $OK
    ;;
    stop)
        shift
        if [ $# -ne 0 ]; then
            echo "Too much args for \"stop\"."
            echo
            echo "More information with $(format_cpable "$0 --help")"
            exit $ERROR
        fi

        end_exo
        exit $OK
    ;;
    *)
        echo "Option \"$1\" was not recognized!"
        exit $ERROR
    ;;
esac

