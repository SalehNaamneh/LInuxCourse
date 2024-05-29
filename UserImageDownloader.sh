#!/bin/bash

LogFile="ErrorFiles.log"
touch "${LogFile}"

if [ -z "$1" ]; then
    echo "Error: You must provide a folder name." >> "$LogFile"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: You must provide at least one ID." >> "$LogFile"
    exit 2
fi

ArgumentsArray=("$@")
FolderName="$1"
apiAddress="https://reqres.in/api/users"
mkdir -p "$FolderName"
FilePath=$(pwd)

for ((i=1; i<${#ArgumentsArray[@]}; i++)); do
    check=0
    user_id="${ArgumentsArray[$i]}"
    user_data=$(wget -qO- "$apiAddress/$user_id" | jq '.')

    if [ "$(echo "$user_data" | jq '.data')" == "null" ]; then
        echo "Error: There is no user with ID $user_id in the API." >> "$LogFile"
        continue
    fi

    name=$(echo "$user_data" | jq -r '.data.first_name')
    lastname=$(echo "$user_data" | jq -r '.data.last_name')
    avatar_url=$(echo "$user_data" | jq -r '.data.avatar')

    jpgName="${user_id}_${name}_${lastname}.jpg"
    wget -qP "$FolderName" "$avatar_url" -O "$FolderName/$jpgName"

    check=1
done

username=$(whoami)
time_prog=$(date +%Y-%m-%d-%H:%M:%S:%N)
branch_name=$(git branch --show-current)

echo "User name: $username" >> "$LogFile"
echo "Current git branch: $branch_name" >> "$LogFile"
echo "Date: $time_prog" >> "$LogFile"
echo "------------------------------------------------------------------------------------" >> "$LogFile"

