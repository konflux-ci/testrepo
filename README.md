# Example component for testing Konflux

This component can be used for testing Konflux -- specifically on a local setup (e.g.
when [running on Kind](https://github.com/konflux-ci/konflux-ci?tab=readme-ov-file#konflux-ci)).

You can fork it and adjust the pipelines so they reference your fork.

To simplify initial local deployments, the pipelines are configured so that images are
pushed to a local registry deployed on the cluster.

Consult the [documentation](https://github.com/konflux-ci/konflux-ci?tab=readme-ov-file#konflux-ci) for using external image registries.
