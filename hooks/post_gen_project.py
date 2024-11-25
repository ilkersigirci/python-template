import shutil
from pathlib import Path

PROJECT_DIRECTORY = Path.cwd()


def remove_file(filepath: str) -> None:
    (PROJECT_DIRECTORY / filepath).unlink()


def remove_dir(filepath: str) -> None:
    shutil.rmtree(PROJECT_DIRECTORY / filepath)


if __name__ == "__main__":
    if "{{cookiecutter.include_github_actions}}" != "y":
        remove_dir(".github")
    else:
        if (
            "{{cookiecutter.mkdocs}}" != "y"
            and "{{cookiecutter.publish_to_pypi}}" == "n"
        ):
            remove_file(".github/workflows/on-release-main.yml")

    if "{{cookiecutter.mkdocs}}" != "y":
        remove_dir("docs")
        remove_file("mkdocs.yml")

    if "{{cookiecutter.dockerfile}}" != "y":
        remove_file("Dockerfile")

    if "{{cookiecutter.codecov}}" != "y":
        remove_file("codecov.yaml")
        if "{{cookiecutter.include_github_actions}}" == "y":
            remove_file(".github/workflows/validate-codecov-config.yml")

    if "{{cookiecutter.devcontainer}}" != "y":
        remove_dir(".devcontainer")
