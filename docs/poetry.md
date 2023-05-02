- All the documentation can be found [here](https://python-poetry.org/docs/). Below are some of the commands that is  used frequently.

- Install (recommended)

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

- Add `zsh` auto completion

```bash

# Open `~/.zshrc` and add the following lines
fpath+=~/.zfunc
autoload -Uz compinit && compinit

source ~/.zshrc

mkdir ~/.zfunc
poetry completions zsh > ~/.zfunc/_poetry
exec zsh
```

- Uninstall
```
curl -sSL https://install.python-poetry.org | python3 - --uninstall
```

-   Update poetry

```bash
poetry self update
```

-   `^2.1` equals to `>=2.1.0 <3.0.0`
-   It will automatically find a suitable version constraint and install the package and sub-dependencies.

```bash
poetry add <package>
```

-   Add package with specific version constraint

```bash
poetry add black==23.1.0

poetry add "black[d,jupyter]=23.1.0"
```

-   Add package from git

```bash
poetry add "git+https://github.com/psf/black.git#main"

# With extras
poetry add "git+https://github.com/psf/black.git#main[d,jupyter]"
```

-   If you have never run the command before and there is also no poetry.lock file present, Poetry simply resolves all dependencies listed in your pyproject.toml file and downloads the latest version of their files.

```bash
poetry install
```

-   Install is editable by default
-   If you want to install the dependencies only, run the install command with the --no-root flag:

```bash
poetry install --no-root
```

-   Update dependencies and lock file. Equivalent to deleting the poetry.lock file and running install again

```bash
poetry update
```

-   Optional groups can be installed in addition to the default dependencies by using the --with option of the install command.
-   Optional group dependencies will still be resolved alongside other dependencies, so special care should be taken to ensure they are compatible with each other.

```bash
poetry install --with others
```

-Adding a dependency to a group. If the group does not already exist, it will be created automatically

```bash
poetry add pytest --group test
```

-   By default, dependencies across all non-optional groups will be installed when executing `poetry install`
-   You can exclude one or more groups with the `--without` option
-   When used together, `--without` takes precedence over `--with`

```bash
poetry install --without test,docs
```

-   Install only specific groups of dependencies without installing the default set of dependencies

```bash
poetry install --only docs
```

-   If you only want to install the project’s runtime dependencies, you can do so with the

```bash
poetry install --only main
```

-   If you want to install the project root, and no other dependencies, you can use the

```bash
poetry install --only-root
```

-   Removing dependencies from a group

```bash
poetry remove mkdocs --group docs
```

-   Synchronizing dependencies ensures that the locked dependencies in the poetry.lock file are the only ones present in the environment, removing anything that’s not necessary.

```bash
poetry install --sync
```

-   To build the package

```bash
poetry build
```

-   To publish the package to private pypi

```bash
poetry publish -r private-pypi

# Build and publish
poetry publish --build -r private-pypi
```

-   List of configs

```bash
poetry config --list
```

-   Disable creating virtual environment

```bash
poetry config virtualenvs.create false
```

-   Clear cache

```bash
poetry cache clear . --all
```

-   To pin manually added dependencies from your pyproject.toml. The `poetry lock` command also updates your existing dependencies if newer versions that fit your version constraints are available

```bash
poetry lock
```

-   If you don’t want to update any dependencies that are already in the poetry.lock file

```bash
poetry lock --no-update
```

-   When a new version of a dependency still fulfills your version constraints, you can use:

```bash
poetry update
```

The update command will update all your packages and their dependencies within their version constraints. Afterward, Poetry will update your poetry.lock file

-  To update a specific package

```bash
poetry update <package>
```
Note that this will not update versions for dependencies outside their version constraints specified in the pyproject.toml file.

-   Export to requirements.txt

```bash
poetry export --output requirements.txt
```
