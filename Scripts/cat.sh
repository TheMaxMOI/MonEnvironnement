#/bin/sh

# Simple cat in order to learn file and string manipulation

file=$1

print_string () {
    len=${#line}
    i=1

    while [ "$i" -le "$len" ]; do
        char=$(echo "$line" | cut -c "$i")
        echo -n "$char"
        i=$((i+1))
    done
    echo ""
}

while IFS= read -r line || [ -n "$line" ]; do
    print_string $line
done < $file
