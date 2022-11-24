#!/usr/bin/env bats

DIR=$(pwd)
function run_git_linearize() {
    "$DIR/git-linearize" $1
}

function make_dummy_commit() {
    head -c 24 /dev/random | base64 > foo.txt
    git add foo.txt
    git commit -m "A commit :-)"
} 

function assert_head_commit_has_prefix() {
    sha1=$(git rev-parse HEAD)
    [[ $sha1 == $1* ]]
}

function assert_head_commit_not_has_prefix() {
    sha1=$(git rev-parse HEAD)
    [[ $sha1 != $1* ]]
}

# bats test_tags=short
@test "test repo one commit (--short)" {
    cd $(mktemp -d)
    git init
    make_dummy_commit
    run_git_linearize --short
    assert_head_commit_has_prefix 000000
}


@test "test repo one commit" {
    cd $(mktemp -d)
    git init
    make_dummy_commit
    run_git_linearize
    assert_head_commit_has_prefix 00000000
}

@test "test repo three commits" {
    cd $(mktemp -d)
    git init

    make_dummy_commit
    make_dummy_commit
    make_dummy_commit
    
    run_git_linearize
    assert_head_commit_has_prefix 00000020
}

# bats test_tags=short
@test "test repo three commits (--short)" {
    cd $(mktemp -d)
    git init

    make_dummy_commit
    make_dummy_commit
    make_dummy_commit
    
    run_git_linearize --short
    assert_head_commit_has_prefix 000002
}

# bats test_tags=short
@test "test repo three commits incrementally" {
    cd $(mktemp -d)
    git init

    make_dummy_commit
    run_git_linearize --short

    make_dummy_commit
    run_git_linearize --short

    make_dummy_commit
    run_git_linearize --short

    assert_head_commit_has_prefix 000002
}

# bats test_tags=short
@test "test repo --if-branch no match" {
    cd $(mktemp -d)
    git init
    make_dummy_commit
    run_git_linearize "--short --if-branch something-random"
    assert_head_commit_not_has_prefix 000000
}

# bats test_tags=short
@test "test repo --if-branch matches" {
    cd $(mktemp -d)
    git init
    git branch -m main
    make_dummy_commit
    run_git_linearize "--short --if-branch main"
    assert_head_commit_has_prefix 000000
}
