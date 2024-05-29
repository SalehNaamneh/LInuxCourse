#!/bin/bash

username=$(whoami)
time_prog=$(date +%Y-%m-%d-%H:%M:%S:%N)
branch_name=$(git branch --show-current)
LogFile="ErrorFiles.log"

touch ${LogFile}
if [ -z "$1" ]; then
    echo "Error: You must provide a folder name." >> "$LogFile"
    
    echo "User name: $username" >> ${LogFile}
    echo "Current git branch: $branch_name" >> ${LogFile}
    echo "date: $time_prog" >> ${LogFile}
    echo "------------------------------------------------------------------------------------" >> ${LogFile}
    exit 1
fi
if [ -z "$2" ]; then
    echo "Error: You must provide at leaset one id." >> "$LogFile"
     
    echo "User name: $username" >> ${LogFile}
    echo "Current git branch: $branch_name" >> ${LogFile}
    echo "date: $time_prog" >> ${LogFile}
    echo "------------------------------------------------------------------------------------" >> ${LogFile}
    exit 2
fi        
    
ArgumentsArray=("$@")
FolderName="$1"
apiAddress="https://reqres.in/api/users"
mkdir -p "$FolderName"
FilePath="${pwd}/${FileName}"
data=$(wget -qO- "$apiAddress" | jq '.')
length=$(echo "$data" | jq 'length')


    

for ((i=1; i<${#ArgumentsArray[@]}; i++)); do
	check=0
    for ((j=0; j<length; j++)); do
        element=$(echo "$data" | jq -r ".data[$j].id")
        name=$(echo "$data" | jq -r ".data[$j].first_name")
        lastname=$(echo "$data" | jq -r ".data[$j].last_name")
        if [ "$element" -eq "${ArgumentsArray[$i]}" ]; then
            avatar_url=$(echo "$data" | jq -r ".data[$j].avatar")
            jpgName="${element}_${name}_${lastname}.jpg"
            wget -qP "$FilePath" "$avatar_url" -O "$FolderName/$jpgName"
            check=1
            break
        fi
    done
    if [ "$check" -eq 0 ]; then 
    	echo "Error there no ${ArgumentsArray[i]} in the api" >> "$LogFile"
    fi	
    
done
   
    echo "User name: $username" >> ${LogFile}
    echo "Current git branch: $branch_name" >> ${LogFile}
    echo "date: $time_prog" >> ${LogFile}
    echo "------------------------------------------------------------------------------------" >> ${LogFile}
