#!/bin/bash
Argument="$1"

BookName=$(ls *.csv | head -n 1)
if [ -z $BookName ]; then
	echo "there no csv file in this dir"
	exit 1;
fi 

# check if there any repo exisest
if [ -d .git ]; then
  echo "This directory is a Git repository."
else
  git init
fi


# check if there any branches if no create two branches
if [ $(git branch | wc -l) -eq 0 ]; then
	git checkout -b BR_1
	git checkout -b BR_2
	git checkout  BR_2
fi	

# Initialize arrays
bug_ids=()
Decription_arr=()
DeveloverName_arr=()
BugPriority_arr=()
GitHubURL_arr=()
branch_arr=()
branch_name=$(git branch --show-current)


# Read the CSV file, skipping the header row
{
  read # Skip the header row
  # read file columns 
  while IFS=',' read -r BugId Decription branch DeveloverName BugPriority GitHubURL; do
    bug_ids+=("$BugId")
    Decription_arr+=("$Decription")
    branch_arr+=("$branch")
    DeveloverName_arr+=("$DeveloverName")
    BugPriority_arr+=("$BugPriority")
    GitHubURL_arr+=("$GitHubURL")
  done
} < Book2.csv
for (( i=0; i<${#bug_ids[@]}; i++ )); do
	if [ ${branch_name} == ${branch_arr[i]} ]; then 
  	Commit="
  	BugId: ${bug_ids[i]}
	CurrentDate: $(date +'%Y-%m-%d %H:%M:%S')
	BranchName: ${branch_arr[i]}
	DevName: ${DeveloverName_arr[i]}
	Priority: ${BugPriority_arr[i]}
	ExcelDescription: ${Decription_arr[i]}
	DevDescription: ${Argument}"
	if ! git remote | grep -q "^origin$"; then
    		git remote add origin "${GitHubURL_arr[i]}" 	
	fi

	git add . 
	git commit -m "$Commit"
	git branch -M "${branch_arr[i]}"
	# Push changes to remote repository
	git push -u origin "${branch_arr[i]}" 	
	fi

done



