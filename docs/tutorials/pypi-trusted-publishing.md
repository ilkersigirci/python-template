# PyPI trusted publishing

Projects generated with `package_publish=y` publish through GitHub's short-lived
OIDC credentials. The workflow builds both an sdist and a wheel; no PyPI token
is required.

## One-time setup

1. Push `.github/workflows/package.yml` to the repository's default branch.
2. In GitHub, create an environment named `pypi` under **Settings →
   Environments**. Restrict deployment tags to `v*` and, when practical, add a
   required reviewer.
3. Add a GitHub Trusted Publisher on PyPI with these values:

   | Field | Value |
   | --- | --- |
   | Owner | GitHub user or organization |
   | Repository | GitHub repository name |
   | Workflow | `package.yml` |
   | Environment | `pypi` |

   For an existing project, use **Project → Manage → Publishing**. For a new
   project, use the account-level **Publishing** page to add a pending publisher
   and set its project name to the exact `[project].name` from `pyproject.toml`.
4. Publish a GitHub release with a tag such as `v1.2.3`. Approve the `pypi`
   deployment if the environment requires review.
5. Confirm both files on PyPI report **Uploaded using Trusted Publishing? Yes**.

When migrating, delete the obsolete GitHub publish secret and revoke its PyPI
API token after the first successful trusted release.

See the official guides for
[new PyPI projects](https://docs.pypi.org/trusted-publishers/creating-a-project-through-oidc/),
[existing projects](https://docs.pypi.org/trusted-publishers/adding-a-publisher/),
and [publishing with uv](https://docs.astral.sh/uv/guides/integration/github/#publishing-to-pypi).
