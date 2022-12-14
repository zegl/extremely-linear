#!/usr/bin/env bats

load funcs.bash

# bats test_tags=short
@test "shit show finds reachable (on other branch)" {
	make_dummy_repo
	make_dummy_commit
	make_dummy_commit
	make_dummy_commit
	make_dummy_commit
	run_git_linearize --short

	git checkout HEAD~2
	git checkout -b branch2
	make_dummy_commit
	make_dummy_commit
	run_git_linearize --short
	OTHER_TWO=$(git rev-parse HEAD^1)

	[[ "$(run_shit_short "rev-parse 2")" == "$OTHER_TWO" ]]
}

# bats test_tags=short
@test "shit show finds reachable (on main branch)" {
	make_dummy_repo
	make_dummy_commit
	make_dummy_commit
	make_dummy_commit
	make_dummy_commit
	run_git_linearize --short
	MAIN_TWO=$(git rev-parse HEAD^1)

	git checkout HEAD~2
	git checkout -b branch2
	make_dummy_commit
	make_dummy_commit
	run_git_linearize --short

	git checkout main

	[[ "$(run_shit_short "rev-parse 2")" == "$MAIN_TWO" ]]
}
