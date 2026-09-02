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

fname="$(parser $1)"
tmp="$fname.make_header_tmp"
FNAME=$(echo "$(basename "$fname")" | tr 'a-z' 'A-Z')

echo "#ifndef ${FNAME}_H" > "$tmp"
echo "#define ${FNAME}_H" >> "$tmp"
echo "" >> "$tmp"

nameShape="[a-zA-Z][a-zA-Z0-9_]*"
ptrShape="\**"
arrShape="(\[\])?"
typeShape="$nameShape( $nameShape)?"
paramShape="(const )?$typeShape $ptrShape$nameShape$arrShape"
functionShape="^$typeShape $ptrShape$nameShape\(($paramShape(, $paramShape)*)?\)\$"

grep -E "$functionShape" "$1" | sed 's/$/;/' >> "$tmp"

echo "" >> "$tmp"
echo "#endif /* ! ${FNAME}_H */" >> "$tmp"

sed -r '/^(static|int main).*/d' "$tmp" > "$fname.h"
rm "$tmp"
