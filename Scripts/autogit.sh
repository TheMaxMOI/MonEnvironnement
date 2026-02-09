#!/bin/sh

#VARIABLES
dir=~/autogit_tags
files=""
msg=""
tag=""
flag_tag=0

#FUNCTIONS
clean(){
    str=$(echo "$*" | tr 'A-Z' 'a-z')
    str=$(echo "$str" | tr '.\-_' ' ')
    n_words=$(echo "$str"| wc -w)
    if [ $n_words -gt 2 ]; then
        str=$(expr "$str" : "\(.* [a-zA-Z0-9_]\{3\}\)")
    fi
    echo $str
}

is_next_flag(){
    case "$*" in
        -*)
            echo 1
            ;;
        *)
            echo 0
            ;;
    esac
}

tag_update(){
    prefix=$(expr "$*" : '\(.*\)-v.*')
    idx=$(expr "$*" : '.*-v\([0-9][0-9]*\)')
    idx=$(($idx+1))
    echo "${prefix}-v${idx}"
}

tag_procedure(){
    if [ "$tag" = "" ]; then
        read -p "No tag has been provided. Would you proceed without one ? (yes/no) : " answer
        if [ "$answer" = "yes" ]; then
            echo "Pushing without tags : $files"
            flag_tag=0
        elif [ "$answer" = "no" ]; then
            file_path="$dir/previous_tag"
            if [ -f "$file_path" ]; then
                read tag < "$file_path"
            fi
            if [ "$tag" = "" ]; then
                read -p "There is no previous tag to relate to. Please input the new one : " tag
            else
                read -p "The previous tag $tag has been found. Would you like to use it ? (yes/no) : " answer
                if [ "$answer" = "yes" ]; then
                    echo "Incrementing the tag"
                    tag=$(tag_update "$tag")
                elif [ "$answer" = "no" ]; then
                    read -p "Please give the new tag : " tag
                else
                    echo "Procedure aborted"
                    flag_tag=0
                fi
            fi
            flag_tag=1
        else
            echo "Procedure aborted"
            flag_tag=0
        fi
    else 
        echo "Tag was already found"
        flag_tag=1
    fi
}

storing_tag() {
    if [ ! -e "$dir" ]; then
        mkdir "$dir"
    fi
    echo "$*">"$dir/previous_tag"
}

#MAIN
while [ $# -gt 0 ]; do
    case "$1" in
        -a|--add)
            shift
            flag=$(is_next_flag "$1")
            while [ $# -gt 0 ] && [ $flag -eq 0 ]; do
                if [ "$files" = "" ]; then
                    files="$1"
                else
                    files="$files $1"
                fi
                shift
                flag=$(is_next_flag "$1")
            done
            ;;
        -m|--message)
            shift
            msg="$1"
            shift
            ;;
        -t|--tag)
            shift
            tag="$1"
            shift
            ;;
        --help)
            shift
            echo "[AUTOGIT]\n\n\t--help :\t\t\tdisplay all parameters\n\n\t-a, --add <files...> :\t\tadd the following files\n"
            echo "\t-m, --message \"my_message\" :\tcommit with \"Auto Commit : my_message\"\n"
            echo "\t-t, --tag my_tag :\t\tset the tag of the commit to my_tag"
            while [ $# -gt 0 ]; do
                shift
            done
            exit 1
            ;;
        *)
            echo "Wrong Arg"
            exit 1
            ;;
    esac
done

#ADD
git add "$files"

#COMMIT
git commit -m "Auto Commit : $msg"

#TAG
tag_procedure "$tag"
if [ $flag_tag -eq 1 ]; then
    storing_tag "$tag"
    git tag -ma "$tag"
else
    echo No chosen tag
fi

#PUSH
if [ $flag_tag -eq 1 ]; then
    git push --follow-tags
else
    git push
fi

