# extremely-linear

Extremely Linear Git History

## Installation

```bash
brew install zegl/tap/git-linearize
```

or copy the [the script](https://github.com/zegl/extremely-linear/blob/main/git-linearize) to somewhere on your PATH.

## Usage

Run as `git linearize`.

```
git linearize - Create an extremely linear git history

git linearize [options]

options:
-h, --help                show brief help
--short                   use shorter 6 digit prefix (quick mode)
--format [format]         specify your own prefix format (pritnf style)
```

## Shit – "short git"

This repository also contains `shit`. A git wrapper that converts non-padded prefixes to their padded counterpart.

* `shit show 14` translates to `git show 00000140`
* `shit log 10..14` --> `git log 00000100..00000140`

Install with `brew install zegl/tap/git-shit`, or copy the [the script](https://github.com/zegl/extremely-linear/blob/main/shit) to somewhere on your PATH.

