### === EDITABLE CONFIG ===

DIR_CACHE="$HOME/Desktop/MonEnvironnement/Scripts/piscine_framework" #global path
CACHE="$DIR_CACHE/.cache" 

MAKE_HEADER="$HOME/Desktop/MonEnvironnement/Scripts/make_header.sh" # global path

WORK_DIR="$HOME/Desktop/piscine" # global path no end /


### === APPLY DEFAULTS ===
if [ -z "$WORK_DIR" ]; then
    WORK_DIR="$PWD"
fi
