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

function run_shit_short() {
	# shellcheck disable=SC2086
	EL_FORMAT="%06d" "$DIR/shit" $1
}
