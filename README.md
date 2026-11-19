# gh-repo-push

Push the local git repository to GitHub as a new private repo.

* Shows a summary of what's about to be pushed (directory, owner, branch, commits)
* Prompts for the repo name, defaulting to the name of the directory
* Creates a **private** repo, adds it as the `upstream` remote, and pushes the current branch
* Prints the new repo's URL when it's done

## Dependencies

* [gh](https://cli.github.com/), authenticated (`gh auth login`)
* [gum](https://github.com/charmbracelet/gum)

```sh
brew install gh gum
```

## Usage

From inside the repo you want to push:

```sh
/path/to/gh-repo-push.sh
```

It exits without changing anything if the repo has no commits, HEAD is detached, or an `upstream` remote already exists.
