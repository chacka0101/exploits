#!/bin/bash

# check if we got two arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <archive> <wordlist>"
    exit 1
fi

# check if needed commands exsists in PATH
for command in 7z wc; do
    which $command &>/dev/null
    STATUS=$?
    if [[ "$STATUS" -ne "0" ]]; then
        echo "Command not found: $command"
        exit 1
    fi
done

# check if archive file exists and can be openned
7z l $1
STATUS=$?
if [[ "$STATUS" -ne "0" ]]; then
    echo "Error openning archive $1"
    exit 1
fi

# try to count wordlist line numbers
wcOutput=$(wc -l $2)
STATUS=$?
if [[ "$STATUS" -ne "0" ]]; then
    echo "Error openning file $2"
    exit 1
fi

# good practice to save the regex into a variable
regex="([0-9]+).$2"

# apply the regex to extract only the line numbers from wc output
[[ $wcOutput =~ $regex ]]

# get the result from group 1
fileSize="${BASH_REMATCH[1]}"

# check if the wordlist has at least one entry
if [[ "$fileSize" -le "0" ]]; then
    echo "Invalid file $2: not enough entries"
    exit 1
fi

echo -e "\nStarting brute forcing"

# read wordlist line by line storing each one in passwd variable
while read passwd; do
    # progress feedback
    line=$((line + 1))
    progress=$((line * 100 / fileSize))
    echo -ne "\r$line/$fileSize ($progress%) Trying: \"$passwd\""

    # test the passwd and exit if it is the correct one
    7z t -p$passwd $1 &>/dev/null
    STATUS=$?
    if [[ "$STATUS" -eq "0" ]]; then
        echo -e "\nFOUND! Archive password is: \"$passwd\""
        echo -e "\nTried $line passwords"
        exit 0
    fi
done < $2

echo -e "\nPassword not found :("
exit 1

