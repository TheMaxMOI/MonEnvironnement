#!/bin/sh

for cmd in "echo" "test" "basename" "cut" "sed" "dirname" "find" "pwd" "mkdir" "mv" "rm" "rmdir" "touch"
do
    command -v "$cmd" > /dev/null 2>&1
    if [ ! $? -eq 0 ] ; then
        echo "You're missing \`$cmd' to use this script"
        echo "Please do not use it or provide an alternative and fix the code"
        exit 1
    fi
done

echo "All requirements are met!"
