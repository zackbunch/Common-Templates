# Docker Image Build Pipeline Flow

This document describes the flow of the Docker image build pipeline defined in `.gitlab/docker.gitlab-ci.yml`.

The pipeline uses a template called `.build_image_template` to build and push Docker images to the GitLab container registry. This template is highly configurable through CI/CD variables.

## Pipeline Stages

The pipeline consists of a single stage that performs the following steps:

1.  **Initialization**:
    *   The job runs in a Docker-in-Docker environment, allowing it to build Docker images.
    *   Default variables are set for configuration, which can be overridden in your `.gitlab-ci.yml` file.

2.  **Pre-build Configuration**:
    *   The pipeline normalizes inputs, setting default values for `DOCKERFILE` (defaults to `Dockerfile`) and `DOCKER_CONTEXT` (defaults to `.`) if not provided.
    *   It determines the source branch, correctly identifying it for both regular commits and merge requests.

3.  **Image Naming and Tagging**:
    *   **Image Repository**: The image repository path is constructed based on the project's registry path (`CI_REGISTRY_IMAGE`).
        *   If an `APP_NAME` is provided, it is sanitized and appended to the repository path.
        *   For builds on Git tags, the image is placed in a `releases` sub-repository.
    *   **Image Tag**: The image tag is constructed as follows:
        *   **Base Tag**:
            *   For Git tags, the base tag is the Git tag itself (e.g., `v1.2.3`).
            *   For all other branches, the base tag is the short commit SHA.
        *   **Tag Suffix**: A suffix is automatically added to the tag based on the context:
            *   `dev`, `test`, `int`, `prod` for the respective branches.
            *   `mr` for merge requests.
            *   `feat` for feature branches (branches prefixed with `gmarm-`).
            *   This can be overridden by setting the `TAG_SUFFIX` variable.
        *   **Final Tag**: The final tag is a combination of the suffix and the base tag (e.g., `dev-a1b2c3d4`).

4.  **Pushing to the Registry**:
    *   The pipeline determines whether to push the image based on the `PUSH_IMAGE` and `AUTO_PUSH` variables.
    *   If `AUTO_PUSH` is `true` (the default), images are automatically pushed for:
        *   `dev`, `test`, `int`, and `prod` branches.
        *   All Git tags.
    *   You can enable pushes for feature branches by setting `PUSH_ON_FEATURE` to `true`.

5.  **Docker Build**:
    *   The `docker build` command is executed.
    *   It uses the specified `DOCKERFILE` and `DOCKER_CONTEXT`.
    *   Build arguments such as `GITLAB_TOKEN` are passed to the build process, which can be used within your `Dockerfile`.
    *   The image is tagged with the final constructed tag.

6.  **`latest` Tag**:
    *   The image is also tagged with `latest` if:
        *   The build is for the `prod` branch.
        *   The build is triggered by a Git tag.
        *   The `TAG_LATEST` variable is explicitly set to `true`.

7.  **Docker Push**:
    *   If the image is configured to be pushed, the pipeline logs into the GitLab registry and pushes the image.
    *   If the `latest` tag was applied, it is also pushed.
    *   The image digest is captured.

8.  **Artifacts**:
    *   A `image-digest.env` file is created as a `dotenv` artifact. This file contains the following variables for use in downstream jobs:
        *   `IMAGE_ENV_PATH`: The full path to the image in the registry.
        *   `IMAGE_TAG`: The tag of the pushed image.
        *   `IMAGE_REF`: The full image reference including the digest.
        *   `IMAGE_DIGEST`: The sha256 digest of the image.

## How to Use

To use this pipeline, you need to include the `.gitlab/docker.gitlab-ci.yml` file in your main `.gitlab-ci.yml` and create a job that extends `.build_image_template`.

### Example Usage

```yaml
include:
  - local: .gitlab/docker.gitlab-ci.yml

build-my-app:
  stage: build
  extends: .build_image_template
  variables:
    APP_NAME: "my-awesome-app"
    DOCKER_CONTEXT: "./my-app"
    DOCKERFILE: "./my-app/Dockerfile.prod"
```

This example would build the Docker image for `my-awesome-app` using the specified context and Dockerfile, and the push behavior would be determined by the branch or tag that triggered the pipeline.
