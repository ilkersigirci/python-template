"""Tests for cookiecutter template generation with different configurations."""

from itertools import product
from pathlib import Path

import pytest
from cookiecutter.main import cookiecutter


@pytest.fixture(scope="session")
def template_dir():
    """Return the path to the cookiecutter template directory."""
    return Path(__file__).parent.parent


@pytest.fixture
def output_dir(tmp_path):
    """Provide a temporary directory for test outputs."""
    return tmp_path


# Generate all combinations of yes/no options for 4 parameters
# This creates all 2^4 = 16 combinations
_COMBINATIONS = list(product(["y", "n"], repeat=4))


@pytest.mark.parametrize(
    "devcontainer,package_publish,docs,mypy",
    _COMBINATIONS,
)
def test_cookiecutter_template_combinations(
    template_dir, output_dir, devcontainer, package_publish, docs, mypy
):
    """Test that the cookiecutter template works with all combinations of yes/no options."""
    project_dir = cookiecutter(
        str(template_dir),
        output_dir=str(output_dir),
        no_input=True,
        overwrite_if_exists=True,
        extra_context={
            "author": "İlker SIĞIRCI",
            "email": "sigirci.ilker@gmail.com",
            "author_github_handle": "ilkersigirci",
            "project_name": "python-template-example",
            "project_slug": "python_template_example",
            "python_version": "3.12",
            "git_remote_location": "github",
            "devcontainer": devcontainer,
            "package_publish": package_publish,
            "docs": docs,
            "mypy": mypy,
            "open_source_license": "MIT license",
        },
    )

    project_path = Path(project_dir)

    # Verify basic project structure
    assert project_path.exists(), "Project directory was not created"
    assert (project_path / "pyproject.toml").exists(), "pyproject.toml was not created"
    assert (project_path / "README.md").exists(), "README.md was not created"
    assert (project_path / "src").exists(), "src directory was not created"

    # Verify git_remote_location hook (always github in this test)
    github_dir = project_path / ".github"
    gitlab_ci = project_path / ".gitlab-ci.yml"
    # Since git_remote_location is hardcoded to "github", .github should exist
    assert github_dir.exists(), ".github directory should exist for github remote"
    # .gitlab-ci.yml should be removed for github
    assert not gitlab_ci.exists(), ".gitlab-ci.yml should not exist for github remote"

    # Verify devcontainer hook
    devcontainer_dir = project_path / ".devcontainer"
    if devcontainer == "y":
        assert devcontainer_dir.exists(), (
            ".devcontainer directory should exist but doesn't"
        )
        assert (devcontainer_dir / "devcontainer.json").exists(), (
            "devcontainer.json should exist"
        )
    else:
        assert not devcontainer_dir.exists(), (
            ".devcontainer directory should not exist but does"
        )

    # Verify package_publish hook
    package_workflow = project_path / ".github" / "workflows" / "package.yml"
    if package_publish == "y":
        assert package_workflow.exists(), (
            "package.yml workflow should exist but doesn't"
        )
    else:
        assert not package_workflow.exists(), (
            "package.yml workflow should not exist but does"
        )

    # Verify docs hook
    mkdocs_yml = project_path / "mkdocs.yml"
    docs_dir = project_path / "docs"
    doc_deploy_workflow = project_path / ".github" / "workflows" / "doc_deploy.yml"
    doc_test_workflow = project_path / ".github" / "workflows" / "doc_test.yml"

    if docs == "y":
        assert mkdocs_yml.exists(), "mkdocs.yml should exist but doesn't"
        assert docs_dir.exists(), "docs directory should exist but doesn't"
        # For github, doc workflows should exist
        assert doc_deploy_workflow.exists(), "doc_deploy.yml should exist but doesn't"
        assert doc_test_workflow.exists(), "doc_test.yml should exist but doesn't"
    else:
        assert not mkdocs_yml.exists(), "mkdocs.yml should not exist but does"
        assert not docs_dir.exists(), "docs directory should not exist but does"
        # For github with docs=n, doc workflows should be removed
        assert not doc_deploy_workflow.exists(), (
            "doc_deploy.yml should not exist but does"
        )
        assert not doc_test_workflow.exists(), "doc_test.yml should not exist but does"

    # Verify mypy in pyproject.toml
    pyproject_content = (project_path / "pyproject.toml").read_text()
    if mypy == "y":
        assert "mypy" in pyproject_content, "mypy should be in dependencies"
        assert "[tool.mypy]" in pyproject_content, "mypy configuration should exist"
    else:
        assert "[tool.mypy]" not in pyproject_content, (
            "mypy configuration should not exist"
        )


@pytest.mark.parametrize("git_remote", ["github", "gitlab"])
def test_git_remote_location_hook(template_dir, output_dir, git_remote):
    """Test that the git_remote_location hook correctly removes files."""
    project_dir = cookiecutter(
        str(template_dir),
        output_dir=str(output_dir),
        no_input=True,
        overwrite_if_exists=True,
        extra_context={
            "author": "İlker SIĞIRCI",
            "email": "sigirci.ilker@gmail.com",
            "author_github_handle": "ilkersigirci",
            "project_name": f"test-git-{git_remote}",
            "project_slug": f"test_git_{git_remote}",
            "python_version": "3.12",
            "git_remote_location": git_remote,
            "devcontainer": "y",
            "package_publish": "y",
            "docs": "y",
            "mypy": "y",
            "open_source_license": "MIT license",
        },
    )

    project_path = Path(project_dir)

    github_dir = project_path / ".github"
    gitlab_ci = project_path / ".gitlab-ci.yml"

    if git_remote == "github":
        assert github_dir.exists(), ".github directory should exist for github"
        assert not gitlab_ci.exists(), ".gitlab-ci.yml should be removed for github"
    elif git_remote == "gitlab":
        assert not github_dir.exists(), ".github directory should be removed for gitlab"
        assert gitlab_ci.exists(), ".gitlab-ci.yml should exist for gitlab"
