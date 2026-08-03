pad () { # $1 = str, $2 = maxPad # Do not forget to quote the result !
    diff=$(( $2 - ${#1} ))
    space=" "

    res="$1"
    while [ "$diff" -gt 0 ]; do
        if [ $(( diff % 2 )) -eq 1 ]; then
            res="$res$space"
        fi
        space="$space$space"
        diff=$(( diff / 2 ))
    done

    echo -n "$res"
}

upperPOW2 () {
    pow=1
    while [ "$pow" -le "$1" ]; do
        pow=$((pow << 1))
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
        echo "$1" | cut -c "$2"
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
    growingString=""
    for i in "$@"; do
        growingString="${growingString}$i"
    done
    echo -n "${growingString}"
}

startLike () { # $1 = prefix, $2 = str
    case "$2" in
        "$1"*)
            echo 0
         ;;
         *)
            echo 1
    esac
}

trunc () { # $1 = len, $2 = str
    len=${#2}
    i=$(($1+1))

    while [ "$i" -le "$len" ]; do
        echo -n "$(char_at "$2" "$i")"
        i=$((i+1))
    done
}

trim () { # $1 = str
    len="${#1}"
    i=1
    j="$len"
    while [ "$i" -lt "$j" ] ; do
        moved=1
        begin="$(char_at "$1" "$i")"
        end="$(char_at "$1" "$j")"
        if [ "$begin" = " " ]; then
            i=$((i+1))
            moved=0
        fi
        if [ "$end" = " " ]; then
            j=$((j-1))
            moved=0
        fi
        if [ "$moved" -eq 1 ]; then
            break
        fi
    done

    if [ "$i" -eq "$j" ]; then
        c="$(char_at "$1" "$i")"
        if [ "$c" != " " ]; then
            echo -n "$c"
        fi
    else
        while [ "$i" -le "$j" ]; do
            echo -n "$(char_at "$1" "$i")"
            i=$((i+1))
        done
    fi
}

