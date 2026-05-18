# Agent Guidelines for testrepo-updater

## Project Overview

A minimal container image (see `Dockerfile` and `entrypoint.sh`) used as a
**sample component** for testing
[Konflux](https://github.com/konflux-ci/konflux-ci). The image prints
`hello world` and is verified by a Tekton integration test in
`integration-tests/`. See `README.md` for user-facing docs.

## Updater / Mirror Relationship

This repository is the **updater** — the single source of truth. A GitHub
Actions workflow (see `.github/workflows/`) mirrors content to the public
[konflux-ci/testrepo](https://github.com/konflux-ci/testrepo), which is what
end-users fork before Konflux onboarding. The generated repository is also
used by [konflux-ci/konflux-ci](https://github.com/konflux-ci/konflux-ci) for
integration and end-to-end testing.

**All changes must be made in this repository.** The public sample is
overwritten on each mirror run.

## Development

- No `Makefile` — the project is Bash + Dockerfile only.
- Run locally: `bash entrypoint.sh`
- Container build: `docker build -t testrepo-updater .`
- Container run: `docker run --rm testrepo-updater`

## Verifying Changes

```bash
docker build -t testrepo-updater .          # image must build
docker run --rm testrepo-updater            # must print "hello world"
bash -n entrypoint.sh                       # syntax check
shellcheck entrypoint.sh                    # lint if shellcheck is available
```

## Things to Avoid

- **Do not edit the public sample** (`konflux-ci/testrepo`) directly — the
mirror will overwrite your changes.
- **Do not add `metadata.namespace` to Tekton PipelineRuns** — see the
comments at the top of the `.tekton/` YAML files.
- **Do not change `entrypoint.sh` output without updating the integration
test** — `integration-tests/testrepo-integration.yaml` asserts the exact
output string.
- **Do not edit `pipelines/` directly** — it is the post-transform output of
the mirror. Change `.tekton/` and adjust the mirror scripts in
`.github/scripts/mirror/` if needed.

