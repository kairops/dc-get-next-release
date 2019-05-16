#!/bin/bash

# Changelog "items" sorted in relevance order
#
#   Breaking - for a backwards-incompatible enhancement.
#   New - implemented a new feature.
#   Upgrade - for a dependency upgrade.
#   Update - for a backwards-compatible enhancement.
#   Fix - for a bug fix.
#   Build - changes to build process only.
#   Docs - changes to documentation only.
#   Security - for security skills.
#   Deprecated - for deprecated features.

set -euo pipefail

function echo_debug () {
    if [ "$KD_DEBUG" == "1" ]; then
        echo >&2 ">>>> DEBUG >>>>> $(date "+%Y-%m-%d %H:%M:%S") $KD_NAME: $@"
    fi
}

KD_NAME="get-next-release-number"
echo_debug "begin"

# Calculate next release number
function calculateNextReleaseNumber () {
    tagFrom=$(git tag|tail -n1)
    product_version=$tagFrom
    if [ "$product_version" == "" ]; then
        major="0"
        minor="1"
        patch="0"
    else
        semver=( ${product_version//./ } )
        major="${semver[0]}"
        minor="${semver[1]}"
        patch="${semver[2]}"
        OLDIFS="$IFS"
        IFS=$'\n' # bash specific
        if [ "${major:0:1}" == "v" ]; then
            major=${major:1}
        fi
        commitList=$(git log ${tagFrom}..HEAD --no-merges --pretty=format:"%h %s")
        itemToIncrease="patch"
        for commit in $commitList; do
            type=$(echo_debug $commit|awk '{print $2}')
            if [ "$type" == "New:" ] || [ "$type" == "Upgrade:" ] || [ "$type" == "Update:" ]; then
                if [ "$itemToIncrease" == "patch" ]; then
                    itemToIncrease="minor"
                fi
            elif [ "$type" == "Breaking:" ]; then
                if [ "$itemToIncrease" != "major" ]; then
                    itemToIncrease="major"
                fi
            fi
        done
        case $itemToIncrease in
            "patch") 
                patch=$((patch + 1))
                ;;
            "minor")
                minor=$((minor + 1))
                patch="0"
                ;;
            "major")
                major=$((major + 1))
                minor="0"
                patch="0"
                ;;
        esac
        IFS=$OLDIFS
    fi
    echo "v${major}.${minor}.${patch}"

}

calculateNextReleaseNumber

echo_debug "end"
