# Example component for testing Konflux

This component can be used for testing Konflux—especially on a local setup (for example when
[running on Kind](https://github.com/konflux-ci/konflux-ci?tab=readme-ov-file#konflux-ci)).

You can fork it and adjust the pipelines so they reference your fork.

To simplify initial local deployments, the pipelines are configured so that images are
pushed to a local registry deployed on the cluster.

Consult the [Konflux CI documentation](https://github.com/konflux-ci/konflux-ci?tab=readme-ov-file#konflux-ci) for using external image registries.

## Updater and public sample (`testrepo-updater` ↔ `testrepo`)

Konflux maintains two related repositories:

| Repository | Role |
|------------|------|
| [konflux-ci/testrepo-updater](https://github.com/konflux-ci/testrepo-updater) | **Updater** — onboarded to Red Hat Konflux (Mintmaker, builds, `.tekton/` pipelines). This is where day-to-day changes belong. |
| [konflux-ci/testrepo](https://github.com/konflux-ci/testrepo) | **Public sample** — intended to look like a repo users fork **before** Konflux onboarding (no `.tekton/` in the default tree). Content is produced by mirroring from the updater. |

### Where to make changes

**Make changes in [konflux-ci/testrepo-updater](https://github.com/konflux-ci/testrepo-updater)**, not in `konflux-ci/testrepo` directly.

Pull requests, pipeline tweaks, application source, and documentation updates should target the updater. The mirror overwrites `konflux-ci/testrepo` on each successful run, so edits made only on the public repo would be lost.

### What the mirror does

When changes land on the default branch of the updater, a GitHub Actions workflow:

1. Copies the repository to a staging tree (excluding updater-only automation such as the mirror scripts and workflow).
2. Moves Konflux-generated `.tekton/` definitions into `pipelines/` (the layout expected for the public sample).
3. Removes `metadata.namespace` from Tekton YAML under `pipelines/`, then sets `metadata.namespace: default-tenant` on each `PipelineRun` so copies users paste into a fork match the Kind demo tenant namespace (`default-tenant` in the Konflux CI docs).
4. Rewrites `output-image` parameters from Konflux `quay.io/redhat-user-workloads/...` values to the internal-registry style used in the sample (`registry-service.kind-registry/testrepo:…`).
5. Renames Konflux pipeline files to `pipelines/testrepo-pull-request.yaml` and `pipelines/testrepo-push.yaml`.
6. Replaces the `main` branch of [konflux-ci/testrepo](https://github.com/konflux-ci/testrepo) with that staging tree (using credentials from repository secrets).

If the workflow fails, an issue is opened on the updater repository for investigation.

### Forking for your own Konflux

Fork [konflux-ci/testrepo](https://github.com/konflux-ci/testrepo) when you want a clean sample without Konflux metadata yet. For collaboration on the upstream Konflux sample itself, use the updater repository as described above.
