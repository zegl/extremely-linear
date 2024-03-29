# Extremely Linear Git History

> Dreaming of a git commit history that looks like this?

<img width="1197" alt="Screenshot 2022-11-22 at 16 16 40" src="https://user-images.githubusercontent.com/47952/203351228-383cd585-c135-4f63-ac3d-8f10707cc9c7.png">

* Create meaningful checksums: The first commit is `0000000`, then `0000001`, then `0000002`
* Easy overview of your history
* No need for semver or other external versioning, your commits are your version numbers
* With the `shit` ("short git") wrapper, you can use commands like `shit show 14`, and `shit log 100..150`
* 100% production ready, 0% recommended

## Installation

```bash
brew install zegl/tap/git-linearize zegl/tap/git-shit
```

or copy the scripts (from the root of this repo) to somewhere on your PATH.

## Usage

Run as `git linearize`.

```
git linearize - Create an extremely linear git history - github.com/zegl/extremely-linear

git linearize [command] [options]

command: (default command is to run the linearization process)
  -h, --help           show brief help
  --install-hook       installs git-linearize as a post-commit hook (current repo only)
  --make-epoch         makes the current commit the linearized epoch (00000000), use to adopt git-linearize in
                       existing repositories without having to rewrite the full history

general options (for all command):
  -v, --verbose                   more verbose logging
  --short                         use shorter 6 digit prefix (quick mode)
  --format [format]               specify your own prefix format (pritnf style)
  --if-branch [name]              only run if the current branch is [name]

  All command generally support all general options. For example, specifying --format to --install-hook means
  that git-linearize will be called with the same format in the future when triggered by the hook.
```

git-linearize requires the history to already be linear (no merge commits).

**Beware:** git-linearize will rebase your entire project history. Do not run unless you know what you're doing. Create a backup first!

## `shit` – "short git"

This repository also contains `shit`. A git wrapper that converts non-padded prefixes to their padded counterpart.

* `shit show 14` translates to `git show 00000140`
* `shit log 10..14` --> `git log 00000100..00000140`

Install with `brew install zegl/tap/git-shit`, or copy the [the script](https://github.com/zegl/extremely-linear/blob/main/shit) to somewhere on your PATH.


# What's happening here

> Read more in the ["Extremely Linear Git History"](https://westling.dev/b/extremely-linear-git) blog post.

The hash of a git commit is created by combining the tree, commit parent(s), author, and the commit message.

git-linearize uses [lucky_commit](https://github.com/not-an-aardvark/lucky-commit) which inserts invisible whitespace characters at the end of the commit message until we get a SHA1 hash with the desired prefix.

`git-linearize` will convert/rebase your repository so that the first commit in the history has a prefix that starts with `00000000`, the second commit will have the prefix `00000010`, the third one will have `00000020` and so on.

## Prefix format

Many git clients and forges, abbreviate commit hashes to the first 7 characters. git-linearize uses the first 7 characters for the counter (0 to 9 999 999), followed by a fixed 0, making the total prefix length 8 characters long.

```
| NNNNNNN | 0 | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
| counter |    \                 can be anything |
           \ always zero
```

## Performance? Is this fast? 🏎

Thanks to the GPU powered crashing in lucky_commit, generating a 8 character prefix takes roughly 2 seconds on my computer (2021 Macbook Pro with M1 Pro).

Using CPU-only crashing (if your computer does not have a GPU) attached, the same operation takes ~43 seconds on the same computer.

# Future ideas and epic hacks

* A pre-merge GitHub action that runs git-linearize
* ✅ A post-commit commit hook
* Make it easier to organize git-linearize on multiple branches (see: --if-branch)

# Credits

Thanks to [lucky_commit](https://github.com/not-an-aardvark/lucky-commit) and [githashcrash](https://github.com/Mattias-/githashcrash) for the hard work of actually crunching the checksums, and for the inspiration to this project.