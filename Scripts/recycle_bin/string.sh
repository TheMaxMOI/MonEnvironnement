pad () { # $1 = str, $2 = maxPad # Do not forget to quote the result !
    len=${#1}

    echo -n "$1"

    i=$len
    while [ "$i" -lt "$2" ]; do
        echo -n " "
        i=$((i+1))
    done
}

upperPOW2 () {
    pow=1
    while [ "$pow" -le "$1" ]; do
        pow=$((pow*2))
    done

    echo "$pow"
}

padPOW2 () {
    pad "$1" "$(upperPOW2 "${#1}")"
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

