#/bin/sh

### === EDITABLE CONFIG ===

DIR="$HOME"
BIN="$DIR/.trash"

### === PROGRAM ===

# === Global Vars ===

TABLE="$BIN/IAmTheTable"
NONE="/dev/null"

help () {
    echo "This script allows one to have a recycle bin rather than definitive deletation aka rm."
    echo ""
    echo "Usage: \`$0' [delete|info|restore|empty] <files?>"
    echo " - delete,  moves the specified files to the bin."
    echo "            Fail if no files are provided or mv issues"
    echo " - info,    list bin's location and the files contained in the bin."
    echo " - restore, moves back the files from where they were deleted."
    echo "            Fail if no files are provided or mv issues"
    echo " - empty,   removes all files contained in the bin."
}

isBinAlive () {
    if [ -e "$BIN" ] && [ -d "$BIN" ] && [ -f "$TABLE" ]; then
        echo 0
    else
        echo 1
    fi
}

createBin () {
    if [ $(isBinAlive) -eq 0 ]; then
        echo "Bin already exist at $BIN"
    else
        mkdir -- "$BIN"
        touch -- "$TABLE"
    fi
}

empty () {
    if [ $(isBinAlive) -eq 0 ]; then
        rm -rf "$BIN"/* "$BIN"/.*
        touch -- "$TABLE"
    else
        echo "Bin does not exist!"
    fi
}

delete () {
    for file in $@; do
        if [ -e $file ]; then
            $(mv $file $BIN > $NONE 2>&1) && if [ -d $file ]
            then
                # rename as foldX
                # write data as fold to table
            else
                # rename as fileX
                # write data as file to table
            fi
        else
            echo "User tried to delete a none existing file at $file"
        fi
    done
}

# if $DIR doesnt exist
