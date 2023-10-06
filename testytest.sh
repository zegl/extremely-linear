#!/bin/bash

source ./test/funcs.bash

make_dummy_repo
make_dummy_commit
make_dummy_commit
git checkout -b new-branch
make_dummy_commit
make_dummy_commit
git switch main
make_dummy_commit
git checkout -b branch-2
make_dummy_commit
git switch main
make_dummy_commit
# a-b-e-f main
#   \
#    c-d new-branch
run_git_linearize "--short"
# 0-1-2 main
# a-c-d new-branch
# git switch new-branch
# run_git_linearize "-v --short"
# now we have to git rebase --onto 0 a
if [[ $(git merge-base main new-branch) == 000001* ]]; then
  echo "yay!"
else
  echo "nay! $(git merge-base main new-branch)"
fi

if [[ $(git merge-base main branch-2) == 000002* ]]; then
  echo "yay!"
else
  echo "nay! $(git merge-base main new-branch)"
fi

git log --graph --all