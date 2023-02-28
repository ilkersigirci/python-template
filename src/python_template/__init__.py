"""Python template package."""
import pkg_resources  # type: ignore

# Fetches the version of the package as defined in pyproject.toml
__version__ = pkg_resources.get_distribution("python_template").version
