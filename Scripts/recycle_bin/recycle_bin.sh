#!/bin/sh

SCRIPT_DIR=$(dirname "$0")
### === IMPORTS ===
. "$SCRIPT_DIR/config.sh"
. "$SCRIPT_DIR/path.sh"
. "$SCRIPT_DIR/string.sh"

# === Global Vars ===

TABLE="$BIN/IAmTheTable"
NONE="/dev/null"
DIR_IDX=""
FILE_IDX=""



help () {
    echo "This script allows one to have a recycle bin rather than definitive deletation aka rm."
    echo ""
    echo "Usage: \`$0' [delete|info|restore|empty] <files?>"
    echo " - delete,  moves the specified files to the bin."
    echo "            Fail if no files are provided or mv issues"
    echo " - info,    list bin's location and the files contained in the bin."
    echo " - path,    show the bin location."
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
        echo "Created bin at $BIN"
    fi
}

empty () {
    if [ $(isBinAlive) -eq 0 ]; then
        find "$BIN" -mindepth 1 -exec rm -rf {} +
        touch -- "$TABLE"
        echo "Bin has been emptied"
    else
        echo "Bin does not exist!"
    fi
}

hasSemiColon () { # $1 = file
   hasChar "$1" ";"
}

getIdx () {
    i=-1
    while IFS= read -r line || [ -n "$line" ]; do
        if [ $(startLike "$1" "$line") -eq 0 ]; then
            idx="$(trunc "${#1}" $(split "$line" ";" 1))"
            if [ "$idx" -gt "$i" ]; then
                i="$idx"
            fi
        fi
    done < "$TABLE"

    echo "$i"
}

getIdxCached () {
    i=0
    if [ "$1" = "file" ] && [ -n "$FILE_IDX" ]; then
        i="${FILE_IDX}"
    else if [ "$1" = "dir" ] && [ -n "$DIR_IDX" ]; then
        i="${DIR_IDX}"
    else
        i=$(getIdx "$1")
    fi fi

    i=$((i+1))

    if [ "$1" = "file" ]; then
        FILE_IDX="$i"
    else if [ "$1" = "dir" ]; then
        DIR_IDX="$i"
    fi fi

    echo "$i"
}

saveFileToBin () { # $1 = pathname, $2 = newName
    filename=$(getName "$1")

    line=$(concat "$(padPOW2 "$2")" ";" "$(padPOW2 "$filename")" ";" "$1") # no need to pad the last one
    echo "$line" >> "$TABLE"
}


getNewName () { # $1 = fileOrDir
    i="$(getIdxCached "$1")"
    echo "$1$i"
}

renameAndMoveToBin () { # $1 = path, $2 = newName
    if [ -e "$BIN/$2" ]; then
        echo "Internal error - the bin could not delete $1" >&2
        echo 1
    else
        tmpDir="$BIN/.tmp"
        mkdir "$tmpDir" > "$NONE" 2>&1
        if [ ! -d "$tmpDir" ]; then
            echo "Internal error" >&2
            echo 1
        else
            name="$(getName "$1")"
            if mv "$1" "$tmpDir" > "$NONE" 2>&1  &&
               mv "$tmpDir/$name" "$tmpDir/$2" > "$NONE" 2>&1 &&
               mv "$tmpDir/$2" "$BIN" > "$NONE" 2>&1
            then
                rmdir "$tmpDir" > "$NONE" 2>&1
                echo 0
            else
                echo "Internal error - restoring file ${name} to the source" >&2

                if [ -e "$tmpDir/$2" ]; then
                    mv "$tmpDir/$2" "$1" > "$NONE" 2>&1
                else if [ -e "$tmpDir/$name" ]; then
                    mv "$tmpDir/$name" "$1" > "$NONE" 2>&1
                fi fi

                rmdir "$tmpDir" > "$NONE" 2>&1
                echo 1
            fi

        fi

    fi
}

delete () {
    if [ $(isBinAlive) -eq 1 ]; then
        createBin
    fi

    for file in "$@"; do
        if [ "$(hasSemiColon "$file")" -eq 0 ]; then
            echo "The bin reject all files containing \`;'"
            echo "triggered by $file"
            continue
        fi

        path="$(getAbsolutePath "$file")"

        if [ "$(hasSemiColon "$path")" -eq 0 ]; then
            echo "The bin reject all paths containing \`;'"
            echo "triggered by $path"
            continue
        fi

        if [ "$path" = "$TABLE" ] || [ "$path" = "$BIN" ]; then
            echo "Deleting $file is forbidden!"
            continue
        fi

        if [ -e "$path" ]; then
            isDir=$([ -d "$path" ]; echo $?)

            if [ "$isDir" -eq 0 ]; then
                newName=$(getNewName "dir")
            else
                newName=$(getNewName "file")
            fi

            moved="$(renameAndMoveToBin "$path" "$newName")"
            if [ ! "$moved" -eq 0 ]; then
                continue
            fi

            echo "Moved $file to the bin"

            saveFileToBin "$path" "$newName"
        else
            echo "User tried to delete a none existing file at $file"
        fi
    done

    if [ "$#" -eq 0 ]; then
        echo "User did not provided any file!"
    fi
}

path () {
    msg="Bin will be created at"
    if [ $(isBinAlive) -eq 0 ]; then
        msg="Bin is located to"
    fi
    echo "$msg $BIN"
}

tip () {
    echo "Try \`$0 --help'"
}

fmt () { # $1 = type, $2 = name, $3 = path
    echo "$(pad "$(concat "$1: " "$2" " ")" "${#BIN}") from $3"
}

getType () { # $1 = line
    char="$(first "$1")"
    if [ "$char" = "f" ]; then
        echo "F"
    else if [ "$char" = "d" ]; then
        echo "D"
    else
        echo "U"
    fi fi
}

info () {
    if [ $(isBinAlive) -eq 1 ]; then
        echo "The bin will be create at $BIN"
    else
    echo "$BIN:"
    echo ""
    isEmpty=0
    while IFS= read -r line || [ -n "$line" ]; do
        isEmpty=1
        fmt "$(getType "$line")" "$(split "$line" ";" 2)" "$(split "$line" ";" 3)"
    done < "$TABLE"

    if [ "$isEmpty" -eq 0 ]; then
        echo "The bin is empty"
    fi
    fi
}

isIn () { # $1 = elm, $2 = list
    answered=1
    for elm in $2;do
        if [ "$elm" = "$1" ]; then
            echo 0
            answered=0
            break
        fi
    done

    if [ "$answered" -eq 1 ]; then
        echo 1
    fi
}

renameAndMoveToDest () { # $1 = currentName, $2 = name, $3 = dest # return 0 on success, 1 on error, 2 if skip
    fold="$(getFold "$3")"
    if [ ! -e "$fold" ]; then
        echo "Destination folder $fold doesn't exist anymore." >&2
        echo 2
    else if [ -e "$3" ]; then
        echo "$3 already exists preventing of restoring $2." >&2
        echo 2
    else
        tmpDir="$BIN/.tmp"
        mkdir "$tmpDir" > "$NONE" 2>&1
        if [ ! -d "$tmpDir" ]; then
            echo 1
        else if mv "$BIN/$1" "$tmpDir" > "$NONE" 2>&1 &&
                mv "$tmpDir/$1" "$tmpDir/$2" > "$NONE" 2>&1 &&
                mv "$tmpDir/$2" "$3" > "$NONE" 2>&1
        then
            rmdir "$tmpDir" > "$NONE" 2>&1
            echo 0
        else
            echo "Internal error - restoring file $2 to its bin location"

            if [ -e "$tmpDir/$2" ]; then
                mv "$tmpDir/$2" "$BIN/$1" > "$NONE" 2>&1
            elif [ -e "$tmpDir/$1" ]; then
                mv "$tmpDir/$1" "$BIN/$1" > "$NONE" 2>&1
            fi

            rmdir "$tmpDir" > "$NONE" 2>&1
            echo 1
        fi fi
    fi fi
}

restore () {
    if [ $(isBinAlive) -eq 1 ]; then
        echo "The bin was not found!"
        exit 1
    fi

    if [ ! "$#" -eq 0 ]; then
        processed=""
        lines=""
        i=1

        while IFS= read -r line || [ -n "$line" ]; do
            name="$(trim "$(split "$line" ";" 2)")"

            if [ "$(isIn "$name" "$processed")" = 0 ]; then
                i=$((i+1))
                continue
            fi

            for file in "$@"; do
                if [ "$name" = "$file" ]; then
                    currentName="$(trim "$(split "$line" ";" 1)")"
                    dest="$(split "$line" ";" 3)"

                    echo "Restoring $name to $dest"

                    code=$(renameAndMoveToDest "$currentName" "$name" "$dest")
                    if [ "$code" -eq 1 ]; then
                        echo "Fatal Error: Failed to restore $name to $dest!"
                        echo "One must restore it manually"
                        exit 1
                    else if [ "$code" -eq 2 ]; then
                        # skip registering processed file and line
                        continue
                    else
                        processed="${processed} ${file}"
                        lines="$i ${lines}"
                    fi fi


                fi
            done

            i=$((i+1))
        done < "$TABLE"

        for idx in $lines; do
            sed -i "${idx}d" "$TABLE"
        done

    else
        echo "User did not provided any file!"
    fi
}

if [ ! -d "$DIR" ]; then
    echo "The specified directory was not found!"
    exit 1
fi

if [ "$#" -lt 1 ]; then
    echo "Not enough arguments were given!"
    tip
    exit 1
fi

case "$1" in
    --help)
        help
        exit 1
    ;;
    delete)
        shift
        delete "$@"
        exit 0
    ;;
    restore)
        shift
        restore "$@"
        exit 0
    ;;
    empty)
        empty
        exit 0
    ;;
    info)
        info
        exit 0
    ;;
    path)
        path
        exit 0
    ;;
    *)
        echo "Option \"$1\" was not recognized!"
        tip
        exit 1
    ;;
esac

