#!/bin/bash

set -e

# Check if the current branch is main
current_branch=$(git symbolic-ref --short HEAD)
if [ "$current_branch" != "main" ]; then
    echo "Nothing to do."
    exit 1
fi

# Rename local branch
echo "Renaming branch 'main' to 'master'..."
git branch -m main master

# Check if remote uses HTTPS
remote_url=$(git remote get-url origin)
if [[ "$remote_url" =~ ^https:// ]]; then
    echo "Git remote is using HTTPS:"
    echo "$remote_url"
    echo "Set SSH remote:"

    while true; do
        read -p "New remote URL: " ssh_url
        if [[ "$ssh_url" =~ ^git@github\.com:.*\.git$ ]]; then
            echo "Updating origin to: $ssh_url"
            git remote set-url origin "$ssh_url"
            break
        else
            echo "Invalid remote URL."
        fi
    done
fi

# Push master and set upstream
echo "Pushing 'master' branch to origin..."
git push -u origin master

# Prompt user to set default branch
echo
echo "Change branch to 'master' in GitHub Repo settings:"
repo_path=$(git remote get-url origin | sed -E 's#(git@github.com:|https://github.com/)##; s/\.git$//')
echo "https://github.com/$repo_path/settings/branches"
echo
read -p "Press ENTER once you've changed the default branch to 'master'..."

# Delete old main branch on remote
echo "Deleting 'main' branch from origin..."
git push origin --delete main

echo "All Done"
