# Vulcan Local Action

> [GitHub Action](https://github.com/features/actions) for [vulcan-local](https://github.com/adevinta/vulcan-local)

## Usage

### Scan CI Pipeline

```yaml
name: Build
on:
  push:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Scan with vulcan-local
        uses: adevinta/vulcan-local-action@master
```

Scans local repository with default checks:

- Perform static analysis over the current repository. See  `scan-repo` option.
- Applies configs in `vulcan.yaml` if it exists in the root of the repo. See `local-config` and `use-local-config` options.

### Scan repository AND container images

```yaml
name: Build
on:
  push:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build an image from Dockerfile
        id: build
        run: |
          docker build . -t my-image:dev
          echo "image=my-image:dev" >> $GITHUB_OUTPUT
      - name: Scan with vulcan-local
        uses: adevinta/vulcan-local-action@master
        with:
          target-images: ${{ steps.build.outputs.image }}
          report-severity: MEDIUM
```

Scans local repository with default checks:

- Builds the image
- Performs the same scanning as the previous example.
- Scans the image for vulnerabilities.

### Scan private images

```yaml
name: build
on:
  push:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Scan with vulcan-local
        uses: adevinta/vulcan-local-action@master
        with:
          target-images: docker.io/mysuer/image:tag
          report-severity: MEDIUM
          vars: REGISTRY_DOMAIN=docker.io REGISTRY_USERNAME=mysuer REGISTRY_PASSWORD=${{ secrets.DOCKER_PWD }}
```

Provides credentials to authenticate on a registry.

### Use vulcan.yaml

Most of the options can be set in `vulcan.yaml`.
The file is used by default.

Also it can be used to add exclusions for false positives or for other reasons.

```yaml
reporting:
  exclusions:
    - affectedResource: e2fsprogs
```
