# 🚀 Pipeline Build Template (`.gitlab/build.gitlab-ci.yml`)

This repository includes a **reusable GitLab CI template** for building
and publishing container images with consistent rules across
environments (feature branches, releases, and OpenShift deploys).

It provides: - **Docker-in-Docker (DinD)** support for container
builds.\
- **Automatic tagging** of images based on branch/commit/tag.\
- **Optional image push** logic (safe by default).\
- **OCI metadata labels** for traceability.\
- **Digest artifact export** for downstream jobs (scan, deploy,
release).

------------------------------------------------------------------------

## 📂 File Layout

-   **`.gitlab/build.gitlab-ci.yml`**\
    Defines `build-common` which you extend in project jobs.\

-   **`image-digest.env` (artifact)**\
    Provides digest/tag variables for downstream jobs:

    ``` bash
    IMAGE_ENV_PATH=registry.example.com/group/project/app
    IMAGE_TAG=dev-a1b2c3d
    IMAGE_REF=registry.example.com/...@sha256:xxxx
    IMAGE_DIGEST=xxxx
    ```

------------------------------------------------------------------------

## ⚙️ How It Works

1.  **Base image**: Uses `docker:24.0.5` + `docker:24.0.5-dind`.\
2.  **Image repo path**:
    -   Defaults to the project's GitLab registry
        (`$CI_REGISTRY_IMAGE`).\
    -   Appends `/APP_NAME` if `APP_NAME` is set.\
    -   Example:
        -   Without `APP_NAME`: `registry.com/group/project`\
        -   With `APP_NAME=service1`:
            `registry.com/group/project/service1`\
3.  **Tagging**:
    -   **Release (`RELEASE_IMAGE=true`)** → uses the Git tag
        (e.g. `0.0.1`).\
    -   **Default** → uses short SHA (`a1b2c3d`).\
    -   **Optional suffixes** (`TAG_SUFFIX`): dev, test, int, prod, mr,
        feat...
        -   Example: `dev-a1b2c3d`.\
    -   **`TAG_LATEST=true`** → also tags/pushes `latest`.\
4.  **Push behavior**:
    -   By default, **images are not pushed** (`PUSH_IMAGE=false`).\
    -   Can be enabled per job with `PUSH_IMAGE=true`.\
    -   Release builds **force push** if `RELEASE_IMAGE=true`.\
5.  **Metadata**:
    -   Labels include Git commit, branch, timestamp, and repo URL.\
6.  **Artifacts**:
    -   `image-digest.env` always exported for downstream jobs.\
    -   Useful for deploy, scan, or release templates.

------------------------------------------------------------------------

## 📋 Example Usage

### Feature Branch Build (safe by default)

``` yaml
build_feature:
  stage: build
  extends: .build-common
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^feature-/'
  variables:
    TAG_SUFFIX: "feat"
    PUSH_IMAGE: "true"     # only if you want to test pushing
```

### Dev Branch Build

``` yaml
build_dev:
  stage: build
  extends: .build-common
  rules:
    - if: '$CI_COMMIT_BRANCH == "dev"'
  variables:
    TAG_SUFFIX: "dev"
    PUSH_IMAGE: "true"
    TAG_LATEST: "true"
```

### Release (tag pipeline)

``` yaml
build_release:
  stage: build
  extends: .build-common
  rules:
    - if: '$CI_COMMIT_TAG'
  variables:
    RELEASE_IMAGE: "true"
    TAG_LATEST: "true"
```

------------------------------------------------------------------------

## 🔐 Secrets & Authentication

-   The template logs in automatically to `$CI_REGISTRY` using:

    ``` bash
    docker login -u "$CI_REGISTRY_USER" -p "$CI_JOB_TOKEN" "$CI_REGISTRY"
    ```

-   Ensure the project/group has GitLab Container Registry enabled.

------------------------------------------------------------------------

## 📦 Downstream Jobs

This template is usually paired with: - **Secrets scan**
(`.gitlab/secrets.gitlab-ci.yml`)\
- **Deploy** (`.gitlab/deploy.gitlab-ci.yml`)\
- **Release** (`.gitlab/release.gitlab-ci.yml`)

Each downstream job should `needs: [build]` to pull in the digest
artifact.

------------------------------------------------------------------------

## 🛠 Tips

-   Use `APP_NAME` if your repo holds multiple images.\
-   Avoid `TAG_SUFFIX=latest`; use `TAG_LATEST=true` instead.\
-   Feature branches **won't push by default** unless
    `PUSH_ON_FEATURE=true`.\
-   On OpenShift deploys, prefer digest (`IMAGE_REF`) instead of tags
    for immutability.

------------------------------------------------------------------------

## ✅ Quick Reference

  -------------------------------------------------------------------------
  Variable          Purpose                             Example
  ----------------- ----------------------------------- -------------------
  `APP_NAME`        Subpath for multi-image repos       `templates`

  `PUSH_IMAGE`      Whether to push image               `true` / `false`

  `RELEASE_IMAGE`   Use tag instead of SHA              `true`

  `TAG_SUFFIX`      Environment/branch suffix           `dev`, `feat`, etc.

  `TAG_LATEST`      Also tag as `latest`                `true`

  `IMAGE_REF`       Immutable digest reference          `…@sha256:abcd`
                    (exported)                          
  -------------------------------------------------------------------------
