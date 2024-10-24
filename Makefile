# Oneshell means one can run multiple lines in a recipe in the same shell, so one doesn't have to
# chain commands together with semicolon
.ONESHELL:
SHELL=/bin/bash
ROOT_DIR=python-template
PACKAGE=src/python_template
DOC_DIR=./docs
TEST_DIR=./tests
TEST_MARKER=placeholder
TEST_OUTPUT_DIR=tests_outputs
PRECOMMIT_FILE_PATHS=./python_template/__init__.py
PROFILE_FILE_PATH=./python_template/__init__.py
DOCKER_IMAGE=python-template
DOCKER_TARGET=development


.PHONY: help install test clean build publish doc pre-commit format lint profile
.DEFAULT_GOAL=help

help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		 awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m\
		 %s\n", $$1, $$2}'

# If .env file exists, include it and export its variables
ifeq ($(shell test -f .env && echo 1),1)
    include .env
    export
endif

install-uv: ## Install uv
	! command -v uv &> /dev/null && curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="~/.cargo/bin" sh

update-uv: ## Update uv to the latest version
	uv self update

install-base: ## Installs only package dependencies
	uv sync --frozen --no-dev --no-install-project

install: ## Installs the development version of the package
	$(MAKE) install-uv
	$(MAKE) update-uv
	uv sync --frozen
	$(MAKE) install-precommit

install-no-cache: ## Installs the development version of the package without cache
	$(MAKE) install-uv
	$(MAKE) update-uv
	uv sync --frozen --no-cache
	$(MAKE) install-precommit

# FIXME: Currently not supported by uv
# install-test: ## Install only test version of the package

install-precommit: ## Install pre-commit hooks
	uv run pre-commit install

install-lint:
	uv pip install ruff==0.6.9

install-doc:
	uv pip install mkdocs mkdocs-material mkdocstrings[python]

update-dependencies: ## Updates the lockfiles and installs dependencies. Dependencies are updated if necessary
	uv sync

upgrade-dependencies: ## Updates the lockfiles and installs the latest version of the dependencies
	uv sync -U

test-one: ## Run specific tests with TEST_MARKER=<test_name>, default marker is `placeholder`
	uv run --module pytest -m ${TEST_MARKER}

test-one-parallel: ## Run specific tests with TEST_MARKER=<test_name> in parallel, default marker is `placeholder`
	uv run --module pytest -n auto -m ${TEST_MARKER}

test-all: ## Run all tests
	# mkdir -p ${TEST_OUTPUT_DIR}
	# cp .coveragerc ${TEST_OUTPUT_DIR}
	# cp setup.cfg ${TEST_OUTPUT_DIR}
	uv run --module pytest

test-all-parallel: ## Run all tests with parallelization
	uv run --module pytest -n auto

test-coverage: ## Run all tests with coverage
	uv run --module pytest --cov=${PACKAGE} --cov-report=html:coverage

test-coverage-parallel:
	uv run --module pytest -n auto --cov=${PACKAGE} --cov-report=html:coverage

test-docs: ## Test documentation examples with doctest
	uv run --module pytest --doctest-modules ${PACKAGE}

test: clean-test test-all ## Cleans and runs all tests
test-parallel: clean-test test-all-parallel ## Cleans and runs all tests with parallelization

clean-build: ## Clean build dist and egg directories left after install
	rm -rf ./build ./dist */*.egg-info *.egg-info
	rm -rf ./pytest_cache
	rm -rf ./junit
	find . -type f -iname "*.so" -delete
	find . -type f -iname '*.pyc' -delete
	find . -type d -name '*.egg-info' -prune -exec rm -rf {} \;
	find . -type d -name '__pycache__' -prune -exec rm -rf {} \;
	find . -type d -name '.ruff_cache' -prune -exec rm -rf {} \;
	find . -type d -name '.mypy_cache' -prune -exec rm -rf {} \;

clean-test: ## Clean test related files left after test
	# rm -rf ./htmlcov
	# rm -rf ./coverage.xml
	find . -type f -regex '\.\/\.*coverage[^rc].*' -delete
	rm -rf ${TEST_OUTPUT_DIR}
	find ${TEST_DIR} -type f -regex '\.\/\.*coverage[^rc].*' -delete
	find ${TEST_DIR} -type d -name 'htmlcov' -exec rm -r {} +
	find . -type d -name '.pytest_cache' -prune -exec rm -rf {} \;

clean: clean-build clean-test ## Cleans build and test related files

build: ## Make Python source distribution
	$(MAKE) clean-build
	uv build --sdist --out-dir dist

build-wheel: ## Make Python wheel distribution
	$(MAKE) clean-build
	uv build --wheel --out-dir dist

publish: ## Builds the project and publish the package to Pypi
	# $(MAKE) build
	uv publish dist/*
	# uv publish --publish-url https://test.pypi.org/legacy/ --username DUMMY --password DUMMY dist/*

doc: ## Build documentation with mkdocs
	uv run mkdocs build

doc-github: ## Build documentation with mkdocs and deploy to github pages
	uv run mkdocs gh-deploy --force

doc-dev: ## Show documentation preview with mkdocs
	uv run mkdocs serve -w ${PACKAGE}

pre-commit-one: ## Run pre-commit with specific files
	uv run pre-commit run --files ${PRECOMMIT_FILE_PATHS}

pre-commit: ## Run pre-commit for all package files
	uv run pre-commit run --all-files

pre-commit-clean: ## Clean pre-commit cache
	uv run pre-commit clean

lint: ## Lint code with ruff
	uv run --module ruff format ${PACKAGE} --check --diff
	uv run --module ruff check ${PACKAGE}

lint-report: ## Lint report for gitlab
	uv run --module ruff format ${PACKAGE} --check --diff
	uv run --module ruff check ${PACKAGE} --format gitlab > gl-code-quality-report.json

format: ## Run ruff for all package files. CHANGES CODE
	uv run --module ruff format ${PACKAGE}
	uv run --module ruff check ${PACKAGE} --fix --show-fixes

typecheck:  ## Checks code with mypy
	uv run --module mypy --package ${PACKAGE}
	# MYPYPATH=src uv run --module mypy --package ${PACKAGE}

typecheck-no-cache:  ## Checks code with mypy no cache
	uv run --module mypy --package ${PACKAGE} --no-incremental

typecheck-report: ## Checks code with mypy and generates html report
	uv run --module mypy --package ${PACKAGE} --html-report mypy_report

profile: ## Profile the file with scalene and shows the report in the terminal
	uv run --module scalene --cli --reduced-profile ${PROFILE_FILE_PATH}

profile-gui: ## Profile the file with scalene and shows the report in the browser
	uv run --module scalene ${PROFILE_FILE_PATH}

profile-builtin: ## Profile the file with cProfile and shows the report in the terminal
	uv run --module cProfile -s tottime ${PROFILE_FILE_PATH}

docker-build: ## Build docker image
	docker build --tag ${DOCKER_IMAGE} --file docker/Dockerfile --target ${DOCKER_TARGET} .
