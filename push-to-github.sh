#!/bin/bash
# Quick Push Script for DevOps Project
# This script helps you push to GitHub with authentication

echo "============================================"
echo "  DevOps Project - GitHub Push Helper"
echo "============================================"
echo ""
echo "Your repository is ready to push to:"
echo "https://github.com/Shumail-AbdulRehman/Devops-Project"
echo ""
echo "You need a GitHub Personal Access Token to push."
echo ""
echo "Quick steps:"
echo "1. Go to: https://github.com/settings/tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Select scope: 'repo'"
echo "4. Generate and copy the token"
echo ""
echo "============================================"
echo ""

# Check if token is provided as argument
if [ -z "$1" ]; then
    echo "Usage: ./push-to-github.sh YOUR_GITHUB_TOKEN"
    echo ""
    echo "Or run manually:"
    echo "git push https://YOUR_TOKEN@github.com/Shumail-AbdulRehman/Devops-Project.git main"
    exit 1
fi

TOKEN=$1
REPO_URL="https://${TOKEN}@github.com/Shumail-AbdulRehman/Devops-Project.git"

echo "Pushing to GitHub..."
git push "$REPO_URL" main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo "View your repository at:"
    echo "https://github.com/Shumail-AbdulRehman/Devops-Project"
else
    echo ""
    echo "❌ Push failed. Please check your token and try again."
fi
