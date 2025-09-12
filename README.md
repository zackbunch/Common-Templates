# GitLab CI/CD Pipeline Templates

This repository contains a set of reusable GitLab CI/CD pipeline templates for containerized applications.

## Features

*   Builds Docker images from a `Dockerfile`.
*   Scans container images for vulnerabilities using Trivy.
*   Promotes images to different environments.
*   Deploys applications to OpenShift.
*   Creates GitLab releases for tagged commits.

## How it Works

The main `.gitlab-ci.yml` file acts as an entry point and includes the individual template files from the `.gitlab/` directory. The pipeline is broken down into the following stages:

*   **build:** Builds a Docker image.
*   **scan:** Scans the Docker image for vulnerabilities.
*   **promote:** Tags and pushes an image to a new environment-specific tag.
*   **release:** Creates a GitLab release.

### Templates

*   `.gitlab/containerize.gitlab-ci.yml`: Defines the `build:docker` job, which builds and pushes a Docker image to the GitLab container registry.
*   `.gitlab/container-scan.gitlab-ci.yml`: Defines the `container_scanning` job, which scans the Docker image for vulnerabilities.
*   `.gitlab/promote.gitlab-ci.yml`: Defines the `.promote` job for promoting images.
*   `.gitlab/deploy.gitlab-ci.yml`: Defines a `.openshift-deploy` template for deploying to OpenShift. This is not a complete job and needs to be extended in your project.
*   `.gitlab/release.gitlab-ci.yml`: Defines the `release:dev` job, which creates a GitLab release when a tag is pushed.
*   `.gitlab/job-rules.gitlab-ci.yml`: Contains common rules for when jobs should run.
*   `.gitlab/secrets.gitlab-ci.yml`: (Not shown, but likely for managing secrets)

## Containerize

The `.gitlab/containerize.gitlab-ci.yml` template is responsible for building and pushing Docker images. The `build:docker` job uses the following image tagging strategy:

*   **Merge Requests:** `mr-<iid>-<sha>`
*   **Branches:** `<sha>`
*   **Tags:** `<tag>`
*   The `latest` tag is also applied for the default branch and for tags.

The `build:docker` job produces a `docker.env` artifact with the following variables:

| Variable                | Description                                         |
| ----------------------- | --------------------------------------------------- |
| `DOCKER_IMAGE_PUSHED`   | `true` or `false` depending on whether the image was pushed. |
| `DOCKER_IMAGE_NAME`     | The full name of the Docker image with tag.         |
| `DOCKER_IMAGE_TAG`      | The tag of the Docker image.                        |
| `DOCKER_BASE_IMAGE_PATH`| The base path of the Docker image in the registry.  |
| `DOCKER_IMAGE_DIGEST`   | The digest of the pushed Docker image.              |
| `IMAGE_REF`             | The full image reference with digest.               |
| `CS_IMAGE`              | The image reference to be used by the scanner.      |

## Promotions

The `.gitlab/promote.gitlab-ci.yml` template is used to "promote" images by re-tagging them for different environments. This is useful for creating a clear distinction between images that are in development, staging, or production.

The `promote:dev` job is provided as an example. It extends the `.promote` job and sets the `TARGET_ENV` to `dev`. This job will only run on tag pipelines.

When the `promote:dev` job runs, it will pull the image built in the `build:docker` job, tag it with a `dev-<tag>` tag, and push it to the registry. For example, if the tag is `1.2.3`, the promoted image will be tagged `dev-1.2.3`.

The `promote` jobs produce a `promote.env` artifact with the following variables:

| Variable                  | Description                                                     |
| ------------------------- | --------------------------------------------------------------- |
| `<TARGET_ENV>_IMAGE_REF`  | The full image reference with digest for the promoted image.    |
| `<TARGET_ENV>_IMAGE_TAG_VER` | The full image name with the new environment-specific tag. |

## How to Use

To use these templates in your own project, you can include them in your `.gitlab-ci.yml` file.

```yaml
include:
  - project: 'path/to/this/project'
    ref: 'main'
    file: '/.gitlab-ci.yml'
```

### Variables

You can customize the behavior of the pipelines by overriding the following variables in your project's `.gitlab-ci.yml` file:

| Variable              | Description                                                                 | Default Value  |
| --------------------- | --------------------------------------------------------------------------- | -------------- |
| `APP_NAME`            | The name of your application. Used for naming Docker images and deployments. | `syactemplate` |
| `PUSH_FEATURE_BRANCH` | Set to `"true"` to push Docker images for feature branches.                 | `"false"`      |
| `DOCKER_TLS_CERTDIR`  | Set to `""` to disable TLS for Docker-in-Docker.                            | `""`           |
| `TARGET_ENV`          | The target environment for promotion (e.g., `dev`, `staging`, `prod`).      |                |

**Note:** For deployment, you will need to create a job that extends the `.openshift-deploy` template and provide the necessary OpenShift credentials and configuration.
