#!/usr/bin/bash

: '
  args: $1 -> text to be splitted
  	$2 -> delimeter char
	$3 -> array or variable to be used (be filled)
'
function SplitLineByDelimeter() {

    local -n text=$1
    local -n delim=$2
    local -n array=$3
    
    IFS="$delim" read -ra array <<< "$text" # var name it's important

}

function validateJSON() {
    # todo: validate if the first argument it's a valid file
    
    local -n filename=$1
    result=$(python validate_json.py ${filename})
}


if [ $? -eq 0 ]; then

    delimeter='$'
    SplitLineByDelimeter result delimeter split_result
    echo ${result}
    echo ${split_result[0]}
    echo ${split_result[1]}
    echo ${split_result[2]}
else
   exit 1
fi

#Notes: the value of ? indicates the last output of the last executed command
# 0 means none errors, and 1 indicates the existance of an error.
#echo "result: ${?}" 

