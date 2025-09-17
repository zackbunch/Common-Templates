# Containerize Template (Docker + BuildKit + GitLab Registry)

Opinionated, minimal Docker build/push job for privileged runners (DinD). Designed for reproducible builds, safe secret usage, and digest-first deployments.

## What You Get

- **Deterministic tagging**:
  - `TAG` build → `:tag`
  - `MR` build → `mr-<iid>-<shortsha>`
  - `Branch` build → `<shortsha>`
- **Push policy**:
  - Push on tags, default branch, MRs, or set `PUSH_FEATURE_BRANCH="true"`.
- **OCI labels** baked in:
  - `org.opencontainers.image.{created,source,revision,version,ref.name,vendor}`
- **Digest capture**:
  - Emits `IMAGE_REF=registry/path@sha256:...` for immutable deploys.
- **Dotenv artifact**:
  - `docker.env` exported as CI artifact for downstream jobs.

## Requirements

- **Runner**: privileged Docker-in-Docker (DinD).
- **Services**: `docker:24-dind`.
- **Image**: `docker:24-cli` (or newer).
- **BuildKit**: `DOCKER_BUILDKIT=1` (already set).
- **Registry**: GitLab project/container registry enabled.

## Inputs (Variables)

| Name                  | Required | Default     | Purpose                                                |
|-----------------------|----------|-------------|--------------------------------------------------------|
| `APP_NAME`            | no       | _empty_     | Optional subpath under `$CI_REGISTRY_IMAGE`.           |
| `PUSH_FEATURE_BRANCH` | no       | `false`     | Push from feature branches if `true`.                  |
| `CI_API_V4_URL`       | yes      | GitLab CI   | API base; auto-set in GitLab CI.                       |
| `CI_PROJECT_ID`       | yes      | GitLab CI   | Project ID; auto-set in GitLab CI.                     |

> If your **Dockerfile** downloads from the GitLab Package Registry using the CI token:
> - Use BuildKit secret in the build: `--secret id=gitlab_token,env=CI_JOB_TOKEN`.
> - In the Dockerfile: `RUN --mount=type=secret,id=gitlab_token ...`

## Outputs (docker.env)

- `DOCKER_IMAGE_PUSHED` – `true|false`
- `DOCKER_IMAGE_REPO` – `registry/group/project[/app_name]`
- `DOCKER_IMAGE_TAG` – `tag | mr-<iid>-<sha> | <sha>`
- `DOCKER_IMAGE_WITH_TAG` – `registry/path:tag`
- `DOCKER_IMAGE_DIGEST` – `sha256:...`
- `IMAGE_REF` / `CS_IMAGE` – `registry/path@sha256:...`

Use `IMAGE_REF` for deployments (immutable, content-addressed).

## How to Include

### A) Inline in the same repo
Place the job in your repo’s `.gitlab-ci.yml`. Done.

### B) Reuse from a central project
In your service repo:

```yaml
include:
  - project: infra/ci-templates
    ref: main
    file: /containerize.gitlab-ci.yml

variables:
  APP_NAME: my-service
  PUSH_FEATURE_BRANCH: "false"