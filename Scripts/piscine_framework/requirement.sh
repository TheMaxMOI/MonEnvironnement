#!/bin/sh

for cmd in "echo" "test" "basename" "dirname" "clang-format" "mkdir" "cat" "rm" # "git"
do
    command -v "$cmd" > /dev/null 2>&1
    if [ ! $? -eq 0 ] ; then
        echo "You're missing \`$cmd' to use this script"
        echo "Please do not use it or provide an alternative and fix the code"
        exit 1
    fi
done

echo "All requirements are met!"
