#!/bin/bash
export CAULDRON_DIR_NAME="cauldron-harness"
export CAULDRON_GITHUB_ORG=${1:-aroq}
export CAULDRON_GITHUB_PROJECT=${2:-cauldron}
export CAULDRON_GITHUB_BRANCH=${3:-master}
export GITHUB_REPO="https://github.com/${CAULDRON_GITHUB_ORG}/${CAULDRON_GITHUB_PROJECT}.git"

if [ "$CAULDRON_GITHUB_PROJECT" ] && [ -d "$CAULDRON_GITHUB_PROJECT" ]; then
  echo "Removing existing $CAULDRON_GITHUB_PROJECT"
  rm -rf "$CAULDRON_GITHUB_PROJECT"
fi

echo "Cloning ${GITHUB_REPO}#${CAULDRON_GITHUB_BRANCH}..."
git clone -b "$CAULDRON_GITHUB_BRANCH" "$GITHUB_REPO" "$CAULDRON_DIR_NAME"
