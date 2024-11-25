# Oneshell means one can run multiple lines in a recipe in the same shell, so one doesn't have to
# chain commands together with semicolon
.ONESHELL:
SHELL=/bin/bash

install-doc: ## Install mkdocs and mkdocs-material
	uv pip install mkdocs mkdocs-material

doc-github: ## Build documentation with mkdocs and deploy to github pages
	uv run mkdocs gh-deploy --force
