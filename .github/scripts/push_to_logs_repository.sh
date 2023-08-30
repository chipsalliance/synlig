#/usr/bin/env bash

set -e -u -o pipefail
shopt -s nullglob

declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR=$SELF_DIR/../..
cd $REPO_DIR

REPOSITORY_OWNER="$1"
PUSH_BRANCH="$2"
GITHUB_RUN_ID="$3"
SOURCE_DIRECTORY="$4"
# replace only target directory in target repository,
# leave other files in target repository untouched.
TARGET_DIRECTORY="$5"

# Inspired by: https://github.com/cpina/github-action-push-to-another-repository/blob/main/entrypoint.sh
mkdir --parents "$HOME/.ssh"
DEPLOY_KEY_FILE="$HOME/.ssh/deploy_key"
echo "${SSH_DEPLOY_KEY}" > "$DEPLOY_KEY_FILE"
chmod 600 "$DEPLOY_KEY_FILE"
SSH_KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
ssh-keyscan -H "github.com" > "$SSH_KNOWN_HOSTS_FILE"
export GIT_SSH_COMMAND="ssh -i "$DEPLOY_KEY_FILE" -o UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE"
GIT_CMD_REPOSITORY="git@github.com:$REPOSITORY_OWNER/systemverilog-plugin-logs.git"
CLONE_DIR=$(mktemp -d)
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --global user.name "github-actions[bot]"
{
    git clone --single-branch --depth 1 --branch "$PUSH_BRANCH" "$GIT_CMD_REPOSITORY" "$CLONE_DIR"
} || {
    # Default branch of the repository is cloned. Later on the required branch
    # will be created
    git clone --single-branch --depth 1 "$GIT_CMD_REPOSITORY" "$CLONE_DIR"
} || {
    url_enc_line_break='%0A'
    printf '::error title=%s::%s%s\n'
        'Could not clone the destination repository.' \
        "Command: git clone --single-branch --branch ${PUSH_BRANCH@Q} ${GIT_CMD_REPOSITORY@Q} ${CLONE_DIR@Q}${url_enc_line_break}" \
        'Please verify that the target repository exist AND contains the destination branch name, and is accesible with the configured SSH_DEPLOY_KEY'
    exit 1
}
echo "Current remote files"
ls -la "$CLONE_DIR"
TEMP_DIR=$(mktemp -d)
mv "$CLONE_DIR/.git" "$TEMP_DIR/.git"
ABSOLUTE_TARGET_DIRECTORY="$CLONE_DIR/$TARGET_DIRECTORY/"
rm -rf "$ABSOLUTE_TARGET_DIRECTORY"
mkdir -p "$ABSOLUTE_TARGET_DIRECTORY"
mv "$TEMP_DIR/.git" "$CLONE_DIR/.git"
echo "New files"
ls -la "$SOURCE_DIRECTORY"
cp -ra "$SOURCE_DIRECTORY"/. "$CLONE_DIR/$TARGET_DIRECTORY"
cd "$CLONE_DIR"
echo "Files that will be pushed"
ls -la
printf -v COMMIT_MESSAGE 'Update logs from https://github.com/%s/actions/runs/%s\n' \
    "$GITHUB_REPOSITORY" "$GITHUB_RUN_ID"
git switch -c "$PUSH_BRANCH" || true
git add .
git status
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"
git push "$GIT_CMD_REPOSITORY" --set-upstream "$PUSH_BRANCH"
