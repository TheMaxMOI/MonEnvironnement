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
    echo "\`$1'"
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
NAME=""


### === FUNCTIONS ===
tip () {
    echo "More information with $(format_cpable "$0 --help")"
}

start_exo () { # $1 = string, be nice and give [a-zA-Z0-9_]+ # Piscine has distinct exercise
    if [ -f "$CACHE_FILE" ]; then
        echo "An exercise is already started!"
        echo "You must remove the cache at $(format_cpable "$CACHE_FILE") to proceed."
        exit $CONFLICT
    fi

    FOLD="$WORK_DIR/$1"
    CFILE="$FOLD/$1.c"

    displayed=1
    if [ ! -f "$CFILE" ]; then
        mkdir "$FOLD"
        echo "#include \"$1.h\"" > "$CFILE"
    else
        displayed=0
        echo "Resuming the exercise \"$1\""
    fi


    echo "$1" > "$CACHE_FILE"

    if [ $displayed -eq 1 ]; then
        echo "Ready to start the exercise \"$1\"."
    fi
    echo "You can edit $(format_cpable "$CFILE")"
}

get_exo () {
    if [ ! -f "$CACHE_FILE" ]; then
        return $ERROR
    fi

    NAME="$(cat "$CACHE_FILE")"
    return $OK
}

end_exo () { # no args -> reads from cache
    NAME=""
    get_exo
    retcode=$?
    if [ $retcode -eq $ERROR ]; then
        echo "No exercise yet!"
        tip
        exit $ERROR
    fi

    echo "Identified current exercise to be \"$NAME\"."

    CFILE="$WORK_DIR/$NAME/$NAME.c"
    HFILE="$WORK_DIR/$NAME/$NAME.h"

    "$FORMAT" "$FMT_FLAG" "$CFILE"
    echo "Formatted the file at $(format_cpable "$CFILE")."

    "$MAKE_HEADER" "$CFILE"
    echo "Generated a header file for $CFILE at $(format_cpable "$HFILE")."

    rm "$CACHE_FILE"
    echo
    echo "The cache has been removed. You can now start a new exercise."
}

cat_exo () {
    NAME=""
    get_exo
    retcode=$?
    if [ $retcode -eq $ERROR ]; then
        echo "No exercise yet!"
        tip
        exit $ERROR
    fi

    echo "Identified current exercise to be \"$NAME\"."
    echo

    CFILE="$WORK_DIR/$NAME/$NAME.c"

    cat "$CFILE"
}

abort_exo () {
    rm "$CACHE_FILE" 2> /dev/null
    echo "The current exercise has been stopped."
}

help () {
    echo "This script is solely purposed for Piscine."
    echo "It allows one to automate exercises framework (Create folder, Create C file, Create Header, Format C/H files)"
    echo ""
    echo "Usage: \`$0' [begin|end|cat] <name?>"
    echo " - begin,   starts or resume the framework. Creates folder and C file on start."
    echo "            Fail if an exercise is already being edited"
    echo " - end,     ends the opened framework. Create the header and format the C file"
    echo "            Fail if no exercise opened"
    echo "            Note: the header must be reviewed!"
    echo " - cat,     shows the content of the current exercise"
    echo "            Fail if no exercise opened"
    echo " - abort,   stops the current exercise being worked on."
    echo "            Note: deletes the cache file holding the current exercise name"
}


### === Main ===
case "$1" in
    --help)
        help
        exit $OK
    ;;
    begin)
        shift
        if [ $# -ne 1 ]; then
            echo "Not the right amount of args for \"start\"."
            echo
            tip
            exit $ERROR
        fi

        start_exo "$1"
        exit $OK
    ;;
    end)
        shift
        if [ $# -ne 0 ]; then
            echo "Too much args for \"stop\"."
            echo
            tip
            exit $ERROR
        fi

        end_exo
        exit $OK
    ;;
    cat)
        shift
        if [ $# -ne 0 ]; then
            echo "Too much args for \"cat\"."
            echo
            tip
            exit $ERROR
        fi

        cat_exo
        exit $OK
    ;;
    abort)
        shift
        if [ $# -ne 0 ]; then
            echo "Too much args for \"abort\"."
            echo
            tip
            exit $ERROR
        fi

        abort_exo
        exit $OK
    ;;
    *)
        echo "Option \"$1\" was not recognized!"
        exit $ERROR
    ;;
esac
