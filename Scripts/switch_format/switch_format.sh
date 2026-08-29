#!/bin/sh

SCRIPT_DIR=$(dirname "$0")
### === IMPORTS ===
. "$SCRIPT_DIR/config.sh"

### === GLOBAL VARIABLES ===
CLNG_FILE="$HOME/.clang-format"
C_PATH="$STYLE_FOLDER/$C_NAME"
CPP_PATH="$STYLE_FOLDER/$CPP_NAME"

### === Config Check ===
if [ ! -d "$STYLE_FOLDER" ]; then
    echo "The style folder at $STYLE_FOLDER has not been found!"
    exit 1
fi

if [ ! -f "$C_PATH" ] ||
   [ ! -f "$CPP_PATH" ]; then
    echo "A clang-format file was not found or named the indicated way!"
fi

### === Main Script ===
if [ "$#" -ne 1 ]; then
    echo "Wrong command. One argument must be provided!"
    exit 1
fi


case "$1" in
    c)
        cp "$C_PATH" "$CLNG_FILE"
        echo "Changed for C style"
        exit 0
    ;;
    cpp|c++)
        cp "$CPP_PATH" "$CLNG_FILE"
        echo "Changed for C++ style"
        exit 0
    ;;
    *)
        echo "the language $1 is not supported"
        exit 2
    ;;
esac

