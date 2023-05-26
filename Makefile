# Oneshell means one can run multiple lines in a recipe in the same shell, so one doesn't have to
# chain commands together with semicolon
.ONESHELL:
SHELL=/bin/bash
ROOT_DIR=python-template
PACKAGE=python_template
PYTHON = python
PYTHON_VERSION=3.10
DOC_DIR=./docs
TEST_DIR=./tests
TEST_MARKER=placeholder
TEST_OUTPUT_DIR=tests_outputs
PRECOMMIT_FILE_PATHS=./python_template/__init__.py
PROFILE_FILE_PATH=./python_template/__init__.py

# TODO: add source for rye
PYPI_URLS=

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

python-info: ## List information about the python environment
	@which ${PYTHON}
	@${PYTHON} --version

update-pip:
	${PYTHON} -m pip install -U pip

install-rye:
	! command -v rye &> /dev/null && curl -sSf https://rye-up.com/get | bash

install-base: ## Installs only package dependencies
	rye sync --no-dev

install: ## Installs the development and test version of the package
	rye sync
	$(MAKE) install-precommit

# # FIXME: Currently not supported by rye
# install-no-cache: ## Installs the development and test version of the package

# FIXME: Currently not supported by rye
install-test: ## Install only test version of the package
	rye sync

install-precommit: ## Install pre-commit hooks
	pre-commit install

install-lint:
	pip install black[d]==23.1.0 ruff==0.0.270

# TODO: Change this with hatchling
# install-build:
# 	pip install build

install-publish:
	pip install twine

install-doc:
	pip install mkdocs mkdocs-material mkdocstrings[python]

test-one: ## Run specific tests with TEST_MARKER=<test_name>, default marker is `placeholder`
	${PYTHON} -m pytest -m ${TEST_MARKER}

test-one-parallel: ## Run specific tests with TEST_MARKER=<test_name> in parallel, default marker is `placeholder`
	${PYTHON} -m pytest -n auto -m ${TEST_MARKER}

test-all: ## Run all tests
	# mkdir -p ${TEST_OUTPUT_DIR}
	# cp .coveragerc ${TEST_OUTPUT_DIR}
	# cp setup.cfg ${TEST_OUTPUT_DIR}
	${PYTHON} -m pytest

test-all-parallel: ## Run all tests with parallelization
	${PYTHON} -m pytest -n auto

test-coverage: ## Run all tests with coverage
	${PYTHON} -m pytest --cov=${PACKAGE} --cov-report=html:coverage

test-coverage-parallel:
	${PYTHON} -m pytest -n auto --cov=${PACKAGE} --cov-report=html:coverage

test-docs: ## Test documentation examples with doctest
	${PYTHON} -m pytest --doctest-modules ${PACKAGE}

test: clean-test test-all ## Cleans and runs all tests
test-parallel: clean-test test-all-parallel ## Cleans and runs all tests with parallelization

clean-build: ## Clean build dist and egg directories left after install
	rm -rf ./dist
	rm -rf ./build
	rm -rf ./pytest_cache
	rm -rf ./junit
	rm -rf ./$(PACKAGE).egg-info
	find . -type f -iname "*.so" -delete
	find . -type f -iname '*.pyc' -delete
	# find . -type d -name '$(PACKAGE).egg-info' -empty -delete
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

# TODO: Do this with hatchling
build: ## Make Python source distribution
	# ${PYTHON} -m build --sdist --outdir dist

# TODO: Do this with hatchling
build-wheel: ## Make Python wheel distribution
	# ${PYTHON} -m build --wheel --outdir dist

# TODO: Implement this
publish: ## Builds the project and publish the package to Pypi
	$(MAKE) build
	# twine upload dist/* --verbose --config-file .pypirc

doc: ## Build documentation with mkdocs
	mkdocs build

doc-github: ## Build documentation with mkdocs and deploy to github pages
	mkdocs gh-deploy --force

doc-dev: ## Show documentation preview with mkdocs
	mkdocs serve -w ${PACKAGE}

pre-commit-one: ## Run pre-commit with specific files
	pre-commit run --files ${PRECOMMIT_FILE_PATHS}

pre-commit: ## Run pre-commit for all package files
	pre-commit run --all-files

pre-commit-clean: ## Clean pre-commit cache
	pre-commit clean

lint: ## Lint code with black, ruff
	${PYTHON} -m black ${PACKAGE} --check --diff
	${PYTHON} -m ruff ${PACKAGE}

lint-report: ## Lint report for gitlab
	${PYTHON} -m black ${PACKAGE} --check --diff
	${PYTHON} -m ruff ${PACKAGE} --format gitlab > gl-code-quality-report.json

format: ## Run black, ruff for all package files. CHANGES CODE
	${PYTHON} -m black ${PACKAGE}
	${PYTHON} -m ruff ${PACKAGE} --fix --show-fixes

typecheck:  ## Checks code with mypy
	${PYTHON} -m mypy --package ${PACKAGE}

typecheck-no-cache:  ## Checks code with mypy no cache
	${PYTHON} -m mypy --package ${PACKAGE} --no-incremental

typecheck-report: ## Checks code with mypy and generates html report
	${PYTHON} -m mypy --package ${PACKAGE} --html-report mypy_report

profile: ## Profile the file with scalene and shows the report in the terminal
	${PYTHON} -m scalene --cli --reduced-profile ${PROFILE_FILE_PATH}

profile-gui: ## Profile the file with scalene and shows the report in the browser
	${PYTHON} -m scalene ${PROFILE_FILE_PATH}

profile-builtin: ## Profile the file with cProfile and shows the report in the terminal
	${PYTHON} -m cProfile -s tottime ${PROFILE_FILE_PATH}
