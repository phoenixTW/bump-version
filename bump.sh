#!/bin/env bash

function get_bump_type() {
    # Get the last commit
    LAST_COMMIT=$(git log -n 1 --format='%H')

    GITHUB_OWNER=$(echo "${INPUT_REPOSITORY}" | cut -d"/" -f1)
    GITHUB_REPO=$(echo "${INPUT_REPOSITORY}" | cut -d"/" -f2)

    NUM_MERGED_PRS_TO_CHECK=${NUM_MERGED_PRS_TO_CHECK:-10}

    BRANCH_NAME=$(curl --fail -H "Authorization: bearer ${INPUT_ACCESS_TOKEN}" -X POST -d " \
    { \
    \"query\": \"query { \
    repository(owner:\\\"${GITHUB_OWNER}\\\", name:\\\"${GITHUB_REPO}\\\") { \
        pullRequests(states:MERGED, last: ${NUM_MERGED_PRS_TO_CHECK}, orderBy: {field: UPDATED_AT, direction: ASC}){ \
        nodes{ \
            headRefName, \
            mergeCommit { \
            oid \
            } \
        } \
        } \
    } \
    }\" \
    } \
    " https://api.github.com/graphql | jq -r ".data.repository.pullRequests.nodes[] | select(.mergeCommit.oid == \"${LAST_COMMIT}\").headRefName")

    # echo "Found the following Branch for commit ${LAST_COMMIT}:"
    # echo ${BRANCH_NAME}

    # Find the largest version bump based on the merged PR's
    BUMP=""
    # Get the version bump based on the branch name
    if echo "${BRANCH_NAME}" | grep -q -i -E '(^|[-/])(patch|issue|hotfix|dependabot|whitesource)[-/]?'; then
        BUMP='patch'
    elif echo "${BRANCH_NAME}" | grep -q -i -E '(^|[-/])(minor|feature)[-/]?'; then
        BUMP='minor'
    elif echo "${BRANCH_NAME}" | grep -q -i -E '(^|[-/])(major|release)[-/]?'; then
        BUMP='major'
    else
        echo "Invalid branch name retrieved from PR: ${BRANCH_NAME}" 1>&2
        exit 1
    fi
    echo $BUMP
}
