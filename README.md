# Bump Version

This action automatically fetches the version from the latest tag in a repository, bumps the section of the semantic version, and returns it as output.

## Usage

See [action.yml](action.yml).

## Examples

### Bump type passed as argument

In the following example, the bump-type is explicitly passed as argument, and so that bump type will be used, instead of
the prefix from the last merged PR branch name.

See [How does it work](#how-does-it-work) for more information.

```yaml
---
name: "Generate New Version"

on:
  push:
    branches:
      - master

jobs:
  release:
    name: Release
    runs-on: [ self-hosted, default ]
    timeout-minutes: 15
    permissions:
        contents: read
        pull-requests: read
    steps:
      - name: Generate Version
        id: version
        uses: @phoenixTW/bump-version@master
        with:
          access_token: ${{ github.token }}
          repository: ${{ github.repository }}
          bump-type: "minor"
```

### Bump type not passed as argument

In the following example, the bump-type is not provided as argument to the `bump-version` action, so the `bump-type` will
be determined by the `bump-version` action based on the latest existing version and last merged PR branch name.

See [How does it work](#how-does-it-work) for more information.

```yaml
---
name: "Generate New Version"

on:
  push:
    branches:
      - master

jobs:
  release:
    name: Release
    runs-on: [ self-hosted, default ]
    timeout-minutes: 15
    permissions:
        contents: read
        pull-requests: read
    steps:
      - name: Generate Version
        id: version
        uses: @phoenixTW/bump-version@master
        with:
          access_token: ${{ github.token }}
          repository: ${{ github.repository }}
```

## How does it work

Under the hood, it does multiple things:

### Finding latest tag

The action finds the tag to bump by listing all the tags in the repository by tag creation date, and picks the latest one with SemVer pattern, unless the `bump-type` is explicitly set.

### Determining bump type

The action, first checks if the bump-type is explicitly set, if not, then,

1. The action checks the latest commit and finds a PR from GitHub with that specific commit
2. It retrieves the branch name from the matching PR
3. Based on the branch name, it determines if the patch/minor/major version needs to be bumped

### Version bumping

With the latest version and bump type determined, `semver.sh` simply generates what the next latest tag should be, and outputs it.
