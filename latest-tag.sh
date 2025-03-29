#!/bin/env bash

set -e

function get_latest_tag() {
    git fetch --tags
    # This suppress an error occurred when the repository is a complete one.
    git fetch --prune --unshallow || true

    latest_tag=''

    # Get the latest tag (with natural sort done by `sort -V`) that is in the shape of semver.
    # Sort can handle prefixes, so "refs/tags" is not a problem, but in some projects tag version are mixed - some
    # have "v" prefix and some don't, and this sort can not handle, so we'll help it to avoid situation when
    # "v1.12.3" is considered later version as "1.13.1".
    for tag in $(git for-each-ref --format '%(refname)' refs/tags | sed -e 's/^refs\/tags\///' | sed -e 's/^v//' | sort -rV); do
        if echo "${tag}" | grep -P '^v?([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$' >/dev/null; then
            latest_tag="${tag}"
            break
        fi
    done

    if [ "${latest_tag}" = '' ]; then
        latest_tag="${INPUT_INITIAL_VERSION}"
    fi

    echo "${latest_tag}"
}
