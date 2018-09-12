#!/bin/bash

GIT=`which git`

function msg_ex() {
    echo -e "$@" >&2
}

function msg() {
    msg_ex "#### $@"
}

set -e
. "$(${GIT} --exec-path)/git-sh-setup"

function require_user_name_and_email() {
    if ${GIT} config user.name >/dev/null && ${GIT} config user.email >/dev/null; then
        true
    else
        msg "You need to configure your git user name and email"
        msg_ex "\tgit config user.name \"<Your Name>\""
        msg_ex "\tgit config user.email your@email.com"
        die "Configure Git user name and email"
    fi
}

function require_clean_work_tree_and_no_untracked() {
    local action=$1
    local hint="$2"

    require_clean_work_tree ${action} "${hint}"
    if [[ ! -z "$(${GIT} status --porcelain)" ]]; then
        msg "Cannot ${action}: You have untracked files."
        die "${hint}"
    fi
}

function local_branch_exists() {
    msg "Checking if local branch \"$1\" already exists"
    ${GIT} rev-parse --verify $1 >/dev/null 2>&1
}

function remote_is_defined() {
    msg "Checking if remote \"$1\" is already defined"
    ${GIT} config "remote.$1.url" >/dev/null
}

function git_lfs_disable_smudge() {
    msg "Temporarily disabling smudge filter in local repository"
    ${GIT} lfs install --skip-smudge --local
}

function git_lfs_normal() {
    msg "Restoring default lfs installation in local repository"
    ${GIT} lfs install --local
}

function git_remote_add() {
    msg "Adding remote \"$1\" (tracking $2)"
    ${GIT} remote add $1 $2
}


: ${GITURL_BASE_SSH:="git@course-gitlab.tut.fi:tie-50307-rt-systems-2018"}
: ${GITURL_BASE_HTTPS:="https://course-gitlab.tut.fi/tie-50307-rt-systems-2018"}

function ssh_or_https_remote() {
    if [[ -z $(${GIT} remote -v | grep -m1 '^origin' | sed -Ene's#.*(https://[^[:space:]]*).*#\1#p') ]]; then
        msg "Selecting SSH based remotes"
        echo ${GITURL_BASE_SSH}
    else
        msg "Selecting HTTPS based remotes"
        echo ${GITURL_BASE_HTTPS}
    fi
}

cd_to_toplevel
require_user_name_and_email
require_clean_work_tree_and_no_untracked pull "Please commit or stash them."
GITURL_BASE="$(ssh_or_https_remote)"
GITURL_COURSE_UPSTREAM="${GITURL_BASE}/course_upstream.git"

START_BRANCH=$(${GIT} rev-parse --abbrev-ref HEAD)

git_lfs_disable_smudge
function at_exit {
    msg "Exiting..."
    git_lfs_normal
    msg "Checking out to branch \"${START_BRANCH}\" again"
    ${GIT} checkout ${START_BRANCH}
}
trap at_exit EXIT

REMOTE_NAME="course_upstream"
RBRANCH_NAME="master"
LBRANCH_NAME="${REMOTE_NAME}_updates"
remote_is_defined ${REMOTE_NAME} || git_remote_add ${REMOTE_NAME} ${GITURL_COURSE_UPSTREAM}
${GIT} fetch ${REMOTE_NAME}
if local_branch_exists ${LBRANCH_NAME}; then
    msg "Checking out and updating branch ${LBRANCH_NAME}"
    ${GIT} checkout ${LBRANCH_NAME}
    ${GIT} pull
else
    msg "Checking out branch ${LBRANCH_NAME} to track ${REMOTE_NAME}/${RBRANCH_NAME}"
    ${GIT} checkout -b ${LBRANCH_NAME} ${REMOTE_NAME}/${RBRANCH_NAME}
fi
${GIT} fetch --all --tags
msg "LFS fetch and checkout from ${REMOTE_NAME}"
${GIT} lfs fetch ${REMOTE_NAME}
${GIT} lfs checkout

msg "Checking out ${START_BRANCH} again"
${GIT} checkout ${START_BRANCH}
msg "Merging updates from ${REMOTE_NAME}/${RBRANCH_NAME} into ${START_BRANCH}..."; sleep 3
${GIT} merge --edit -m "Merge updates from ${REMOTE_NAME}/${RBRANCH_NAME}" ${LBRANCH_NAME}
