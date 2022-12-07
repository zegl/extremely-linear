#!/usr/bin/env bats

DIR=$(pwd)
function run_git_linearize() {
	# shellcheck disable=SC2086
	"$DIR/git-linearize" $1
}

function make_dummy_repo() {
	cd "$(mktemp -d)" || exit 1
	git config --global init.defaultBranch main
	git init
	git config --local user.email "testing@example.com"
	git config --local user.name "BATS"
}

function make_dummy_commit() {
	head -c 24 /dev/random | base64 >foo.txt
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
	make_dummy_repo
	make_dummy_commit
	run_git_linearize --short
	assert_head_commit_has_prefix 000000
}

@test "test repo one commit" {
	make_dummy_repo
	make_dummy_commit
	run_git_linearize
	assert_head_commit_has_prefix 00000000
}

@test "test repo three commits" {
	make_dummy_repo

	make_dummy_commit
	make_dummy_commit
	make_dummy_commit

	run_git_linearize
	assert_head_commit_has_prefix 00000020
}

# bats test_tags=short
@test "test repo three commits (--short)" {
	make_dummy_repo

	make_dummy_commit
	make_dummy_commit
	make_dummy_commit

	run_git_linearize --short
	assert_head_commit_has_prefix 000002
}

# bats test_tags=short
@test "test repo three commits incrementally" {
	make_dummy_repo

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
	make_dummy_repo
	make_dummy_commit
	run_git_linearize "--short --if-branch something-random"
	assert_head_commit_not_has_prefix 000000
}

# bats test_tags=short
@test "test repo --if-branch matches" {
	make_dummy_repo
	make_dummy_commit
	run_git_linearize "--short --if-branch main"
	assert_head_commit_has_prefix 000000
}

# bats test_tags=short
@test "custom format" {
	make_dummy_repo
	make_dummy_commit
	run_git_linearize "--format c0de"
	assert_head_commit_has_prefix c0de
}

# bats test_tags=short
@test "install hook" {
	make_dummy_repo
	make_dummy_commit
	make_dummy_commit
	run_git_linearize "--install-hook --format 123"
	make_dummy_commit
	assert_head_commit_has_prefix 123
}

# bats test_tags=short
@test "custom epoch (--short)" {
	make_dummy_repo
	make_dummy_commit
	make_dummy_commit
	make_dummy_commit # 0
	run_git_linearize "--make-epoch --short -v"
	make_dummy_commit # 1
	make_dummy_commit # 2
	run_git_linearize "--short -v"
	assert_head_commit_has_prefix 000002
}

@test "custom epoch" {
	make_dummy_repo
	make_dummy_commit
	make_dummy_commit
	make_dummy_commit # 0
	run_git_linearize "--make-epoch"
	make_dummy_commit # 1
	make_dummy_commit # 2
	run_git_linearize
	assert_head_commit_has_prefix 00000020
}

# bats test_tags=short
@test "reset custom epoch (--short)" {
	make_dummy_repo
	make_dummy_commit
	make_dummy_commit
	make_dummy_commit # 0
	run_git_linearize "--make-epoch --short -v"
	make_dummy_commit # 1
	make_dummy_commit # 2
	run_git_linearize "--short -v"

	run_git_linearize "--make-epoch --short -v" # make a new epoch!
	make_dummy_commit                           # 1
	make_dummy_commit                           # 2
	make_dummy_commit                           # 3
	make_dummy_commit                           # 4
	run_git_linearize "--short -v"

	assert_head_commit_has_prefix 000004
}

# bats test_tags=short
@test "stash unsaved new file" {
	make_dummy_repo
	make_dummy_commit
	make_dummy_commit
	run_git_linearize "--short -v"
	make_dummy_commit
	echo "unsaved" >unsaved.txt
	run_git_linearize "--short -v"
	grep "unsaved" <unsaved.txt
}

# bats test_tags=short
@test "stash unsaved existing file" {
	make_dummy_repo
	make_dummy_commit
	make_dummy_commit
	run_git_linearize "--short -v"
	make_dummy_commit
	echo "unsaved" >foo.txt
	run_git_linearize "--short -v"
	grep "unsaved" <foo.txt
}
