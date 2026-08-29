#!/bin/sh

#clang-format All

mapclg() {
    for file in "$*"/*; do
        if [ -f "$file" ]; then
            case "$file" in
                *.[ch])
                    echo "formatting $file"
                    clang-format $file -i
                    ;;
                *)
                    echo -n ""
            esac
        fi
        if [ -d "$file" ]; then
            echo
            echo exploring "$file"
            mapclg "$file"
        fi
    done
}

mapclg $PWD

echo done
