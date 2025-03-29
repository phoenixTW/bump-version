#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$0")
# shellcheck disable=SC1090,SC1091
source "${SCRIPT_DIR}/semver.sh"
# shellcheck disable=SC1090,SC1091
source "${SCRIPT_DIR}/latest-tag.sh"
# shellcheck disable=SC1090,SC1091
source "${SCRIPT_DIR}/bump.sh"

CURRENT_VERSION=${INPUT_CURRENT_VERSION}
if [[ -z "${CURRENT_VERSION}" ]]; then
    echo "Current version is not explicitly set, trying to get the latest tag"
    CURRENT_VERSION="$(get_latest_tag)"
fi
echo "Current version: ${CURRENT_VERSION}"

BUMP_TYPE=${INPUT_BUMP_TYPE}
if [[ -z "${BUMP_TYPE}" ]]; then
    echo "Bump type is not explicitly set, trying to guess based on the last merged branch name"

    if [[ -z "${INPUT_ACCESS_TOKEN}" ]]; then
        echo "Access token is not set, but is required"
        exit 1
    fi

    if [[ -z "${INPUT_REPOSITORY}" ]]; then
        echo "Repository name is not set, but is required"
        exit 1
    fi

    BUMP_TYPE="$(get_bump_type)"
fi
echo "Bump type: ${BUMP_TYPE}"

BUMP_TYPE_PARAMS=()
for bump_type_param in ${BUMP_TYPE}; do
    BUMP_TYPE_PARAMS+=("${bump_type_param}")
done

NEW_TAG="$(semver bump "${BUMP_TYPE_PARAMS[@]}" "${CURRENT_VERSION}")"

echo "version=$NEW_TAG" >>"$GITHUB_OUTPUT"
