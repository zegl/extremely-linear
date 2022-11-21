#!/bin/bash
#
# This script makes sure that all commit hashes have nice and incremental prefixes.
# Built with https://github.com/Mattias-/githashcrash

set -euo pipefail

# All commits in our repository (on the current branch)
commits=$(git log --format=format:%H --reverse)

# Remember which branch we are on
pre_branch=$(git branch --show-current)

# Create a new temporary branch to use while crunching the numbers
git branch -D extremely-linear || true
git checkout -b extremely-linear

# Find start commit
prev_commit=""
did_reset=0
i=0

for sha1 in $commits; do
    # Desired prefix of commit
    prefix=$(printf '%04d' $i)

    ((i=i+1))

    # Looping through the full history since the root commit
    # Making sure that each commit has the expected prefix
    if [[ "$sha1" == $prefix* ]] && ((!did_reset)); then
        echo "$sha1 starts with $prefix, doing nothing"
        prev_commit="$sha1"
        continue
    else
        # Found the first commit that does not have the correct prefix
        # Reset to this commits parent (the last commit with a good prefix)
        if ((!did_reset)); then
            echo "Found first misaligned commit=$sha1 parent=$prev_commit"
            git reset --hard "$prev_commit"
            did_reset=1
        fi

        # Cherry pick the bad commit
        git cherry-pick "$sha1"

        # Add "magic: REPLACEME" to the commit message
        # githashcrash with replace REPLACEME with it's magic string
        git show -s --format=%B "$sha1" > .msg
        echo >> .msg
        echo "magic: REPLACEME" >> .msg
        git commit --amend -F < .msg
        rm .msg

        # Run githashcrash
        docker run --volume "${PWD}:/work" zegl/extremely-linear:latest "$prefix" | bash
    fi
done

# Move the branch that we used to be on to our new and __improved__ branch!
git branch -D "$pre_branch"
git checkout -b "$pre_branch"
