#!/bin/sh

#le fichier a été clang format au préalable

parser () {
	echo $(expr "$1" : "\(.*\)\..*")
}
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
