# Renovate

Renovate checks the Python dependencies, GitHub Actions, and GitLab CI
dependencies used by this repository and its project scaffold. Generated
projects can optionally include their own Renovate configuration and GitHub
Actions or GitLab CI runner. GitHub projects use a `RENOVATE_TOKEN` repository
secret containing a classic personal access token with the `repo` and
`workflow` scopes. GitLab projects use a masked, hidden, and protected
`RENOVATE_TOKEN` CI/CD variable with the `api` scope and require a pipeline
schedule.
