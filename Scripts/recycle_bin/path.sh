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

getName () {
    basename "$1"
}

