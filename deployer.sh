#!/bin/bash
#) POSIX
#)       _            _
#)    __| | ___ _ __ | | ___  _   _  ___ _ __
#)   / _` |/ _ \ '_ \| |/ _ \| | | |/ _ \ '__|
#)  | (_| |  __/ |_) | | (_) | |_| |  __/ |
#)   \__,_|\___| .__/|_|\___/ \__, |\___|_|
#)             |_|            |___/
#)
#) Helpers
#) ----------------------------------------------------------------------------------------------------
exitstr="Bye!"
#) ----------------------------------------------------------------------------------------------------
if ! [ `type -p urandom` ]; then #) Check with type instead of `command -v` to maximize compatibility
    randomstr=`date | md5sum | awk '{print $1}'`
else
    randomstr=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-16} | head -n 1`
fi
#) ----------------------------------------------------------------------------------------------------
publicdir="public"
#) ----------------------------------------------------------------------------------------------------
currentdir=`pwd`
#) ----------------------------------------------------------------------------------------------------
me=`basename "$0"`
#) ----------------------------------------------------------------------------------------------------
publicindex="index.php"
#) ----------------------------------------------------------------------------------------------------

#) Dependencies
if [[ ! `type -p zip` || ! `type -p unzip` || ! `type -p rsync` ]]; then
    printf "ERROR: script requires packages 'zip','unzip' and 'rsync' to be installed on your system.\n $exitstr \n" >&2
    exit 1
fi

#) Reset all variables that might be set
bootstrap=
servertype=

#) Loop
while :; do
    case $1 in
        -b|--bootstrap) #) Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                bootstrap=$2
                shift
            else
                printf "ERROR: option argument 'bootstrap' requires non-empty value.\n $exitstr \n" >&2
                exit 1
            fi
            ;;
        -s|--servertype)
            if [ -n "$2" ]; then
                servertype=$2
                shift
            else
                printf "ERROR: option argument 'servertype' requires non-empty value.\n $exitstr \n" >&2
                exit 1
            fi
            ;;
        --bootstrap=?*)
            bootstrap=${1#*=} #) Delete everything up to "=" and assign the remainder.
            ;;
        --) #) End of all options.
            shift
            break
            ;;
        -?*)
            printf "WARN: Unknown option (ignored): %s\n" "$1" >&2
            ;;
        *) #) Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

#) Fallbacks
if ! [ -n "$bootstrap" ]; then
    bootstrap="_$randomstr"
fi

#) Init
if ! [ -d "$publicdir" ]; then
    printf "ERROR: Public directory doesn't exist.\n $exitstr \n" >&2
    exit 1
else
    zip -vr "$publicdir.zip" "$publicdir"
fi

#) Process
if [ -f "$publicdir.zip" ]; then
    rm -vfr "$publicdir"

    if [ -d "../$bootstrap" ]; then #) Removes bootstrap directory if it exists
        rm -vfr "../$bootstrap"
    fi
    mkdir "../$bootstrap"

    if [ -d "../$bootstrap" ]; then
        #) Do not use --info=progress2 like options here to maximize compatibility
        #) Use --progress instead
        rsync -avr --exclude="$me" --exclude="$publicdir.zip" --progress "./" "../$bootstrap/"

        #) Cleanup | using pwd to maximize compatibililty
        find $currentdir/* $currentdir/.[!.]* -type f -not \( -name $me -or -name $publicdir.zip \) -exec rm -vf {} +
        find $currentdir/* $currentdir/.[!.]* -type d -exec rm -vfr {} +
    fi
else
    printf "ERROR: Something went wrong.\n $exitstr \n" >&2
    exit 1
fi

unzip "$publicdir.zip" #) Do not use verbose option here
mv $publicdir/* $publicdir/.[!.]* ./ #) Do not use strings for variables here
rm -vfr "$publicdir.zip" "$publicdir"

#) Point to the correct bootstrap.

#) --------------------------------------------------
search="\/..\/vendor\/autoload.php"
#) --------------------------------------------------
replace="\/..\/$bootstrap\/vendor\/autoload.php"
#) -------------------------------------------------<
sed -i "s/${search}/${replace}/g" "$publicindex"
#) ------------------------------------------------->
#)|
#)|
#) --------------------------------------------------
search="\/..\/bootstrap\/app.php"
#) --------------------------------------------------
replace="\/..\/$bootstrap\/bootstrap\/app.php"
#) -------------------------------------------------<
sed -i "s/${search}/${replace}/g" "$publicindex"
#) ------------------------------------------------->

#) Remove me.
rm -vf "$0"
