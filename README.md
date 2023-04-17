# Vulcan Local Action

> [GitHub Action](https://github.com/features/actions) for [vulcan-local](https://github.com/adevinta/vulcan-local)

## Usage

### Scan CI Pipeline

This action applies configs in `vulcan.yaml` if it exists in the root of the repo. See `local-config` and `use-local-config` options.

Scans local repository with targets defined in `vulcan.yaml`.

```yaml
name: Build
on:
  push:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Scan with vulcan-local using vulcan.yaml config
        uses: adevinta/vulcan-local-action@master
```

Scans local repository path.

```yaml
name: Build
on:
  push:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Scan path . only, using vulcan.yaml configs if exists.
        uses: adevinta/vulcan-local-action@master
        with:
          scan-paths: .
```

### Scan repository AND container images

Scans local repository with default checks:

- Builds the image
- Performs scanning of repo and image

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
          target-paths: .
          target-images: ${{ steps.build.outputs.image }}
          report-severity: MEDIUM
```

### Scan private images

Provides credentials to authenticate on a registry.

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
