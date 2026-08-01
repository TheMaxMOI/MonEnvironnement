#!/bin/sh

#le fichier a été clang format au préalable - EPITA's style

help () {
    echo "This is a simple shell tool to make a header from a C file."
    echo "It exports non static and non main functions."
    echo "You must format your file to EPITA's style."
    echo ""
    echo "Usage: \`$0 my_c_file.c' "
}

parser () {
	echo $(expr "$1" : "\(.*\)\..*")
}

if [ "$1" = "--help" ]; then
    help
    exit 1
fi

fname=$(parser $1)
tmp="$fname.make_header_tmp"
FNAME=$(echo $fname | tr 'a-z' 'A-Z')

echo "#ifndef ${FNAME}_H" > "$tmp"
echo "#define ${FNAME}_H" >> "$tmp"
echo "" >> "$tmp"
grep -E "^[a-zA-Z][a-zA-Z_0-9 ]* \*?[a-zA-Z][a-zA-Z_0-9]*\([a-zA-Z][a-zA-Z_0-9 \*,]*\)" "$1" | sed 's/$/;/' >> "$tmp"
echo "" >> "$tmp"
echo "#endif /* ! ${FNAME}_H */" >> "$tmp"

sed -r '/^(static|int main).*/d' "$tmp" > "$fname.h"
rm "$tmp"
