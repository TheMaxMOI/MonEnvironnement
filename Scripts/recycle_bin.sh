#/bin/sh

### === EDITABLE CONFIG ===

DIR="$HOME"
BIN="$DIR/.trash"

### === PROGRAM ===

# === Global Vars ===

TABLE="$BIN/IAmTheTable"
NONE="/dev/null"
DIR_IDX=""
FILE_IDX=""

getAbsolutePath() {
    path=$1
    case "$path" in
        /*)
            ;;

        *)
            path=$(pwd -P)/$path
            ;;
    esac

    saved_IFS=$IFS
    IFS=/
    set -- $path
    IFS=$saved_IFS
    out=""
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

    echo "${out:-/}"
}

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
        echo "Created bin at $BIN"
    fi
}

empty () {
    if [ $(isBinAlive) -eq 0 ]; then
        rm -rf "$BIN"/* "$BIN"/.*
        touch -- "$TABLE"
        echo "Bin has been emptied"
    else
        echo "Bin does not exist!"
    fi
}

getName () {
    echo $(basename $1)
}

upperPOW2 () {
    pow=1
    while [ "$pow" -le "$len" ]; do
        pow=$((pow*2))
    done

    echo "$pow"
}

pad () { # Do not forget to quote the result !
    len=${#1}
    upperLen=$(upperPOW2 "$len")

    echo -n "$1"

    i=$len
    while [ "$i" -lt "$upperLen" ]; do
        echo -n " "
        i=$((i+1))
    done
}

char_at () { # $1 = str, $2 = idx
    if [ "$2" -le 0 ]; then
        echo ""
    else
        echo "$(echo "$1" | cut -c "$2")"
    fi
}

split () { # $1 = str, $2 = char, $3 = ith occurence
    n="$3"
    len=${#1}

    growingString=""
    i=1
    while [ "$n" -gt 0 ] && [ "$i" -le "$len" ]; do
        c=$(char_at "$1" "$i")
        if [ "$c" = "$2" ]; then
            n=$((n-1))
            if [ "$n" -gt 0 ]; then
                growingString=""
            fi
        else
            growingString="${growingString}$c"
        fi
        i=$((i+1))
    done

    echo "$growingString"
}

concat () {
    for i in "$@"; do
        echo -n "$i"
    done
}

startLike () { # $1 = prefix, $2 = str
    len1=${#1}
    len2=${#2}
    if [ "$len1" -gt "$len2" ]; then
        echo 1
    else
        i=1
        answered=1
        while [ "$i" -le "$len1" ]; do
            if [ "$(char_at "$1" "$i")" != "$(char_at "$2" "$i")" ]; then
                echo 1
                answered=0
                break
            fi
            i=$((i+1))
        done

        if [ "$answered" -eq 1 ]; then
            echo 0
        fi
    fi
}

trunc () { # $1 = len, $2 = str
    len=${#2}
    i=$(($1+1))

    while [ "$i" -le "$len" ]; do
        echo -n "$(char_at "$2" "$i")"
        i=$((i+1))
    done
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
    done < $TABLE

    echo "$((i+1))"
}

getIdxCached () {
    i=0
    if [ "$1" = "file" ] && [ -n "$FILE_IDX" ]; then
        i="$((FILE_IDX+1))"
    else if [ "$1" = "dir" ] && [ -n "$DIR_IDX" ]; then
        i="$((DIR_IDX+1))"
    else
        i=$(getIdx "$1")
    fi fi

    if [ "$1" = "file" ]; then
        FILE_IDX="$i"
    else if [ "$1" = "dir" ]; then
        DIR_IDX="$i"
    fi fi

    echo "$i"
}

saveFileToBin () { # $1 = pathname, $2 = newName
    filename=$(getName "$1")

    line=$(concat "$(pad "$2")" ";" "$(pad "$filename")" ";" "$1") # no need to pad the last one
    echo "$line" >> "$TABLE"
}


getNewName () { # $1 = fileOrDir
    i="$(getIdxCached "$1")"
    echo "$1$i"
}

renameAndMoveToBin () { # $1 = path, $2 = newName
    tmpDir="$BIN/.tmp"
    mkdir "$tmpDir"
    [ "$(mv "$1" "$tmpDir" > "$NONE" 2>&1; echo $?)" -eq 0 ] &&
    [ "$(mv "$tmpDir/$(getName "$1")" "$tmpDir/$2" > "$NONE" 2>&1; echo $?)" -eq 0 ] &&
    [ "$(mv "$tmpDir/$2" "$BIN" > "$NONE" 2>&1; echo $?)" -eq 1 ] &&
    echo 0 || echo 1
    rmdir "$tmpDir"
}

delete () {
    if [ $(isBinAlive) -eq 1 ]; then
        createBin
    fi

    noFile=0
    for file in "$@"; do
        noFile=1
        path="$(getAbsolutePath "$file")"

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

    if [ "$noFile" -eq 0 ]; then
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
        # restore "$@"
        exit 0
    ;;
    empty)
        empty
        exit 0
    ;;
    info)
        ls -a $BIN # replace me
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

