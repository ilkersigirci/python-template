# Oneshell means one can run multiple lines in a recipe in the same shell, so one doesn't have to
# chain commands together with semicolon
.ONESHELL:
SHELL=/bin/bash
ROOT_DIR=python-template
PACKAGE=python_template
PYTHON = python
PYTHON_VERSION=3.8
DOC_DIR=./docs
TEST_DIR=./tests
TEST_MARKER=placeholder
TEST_OUTPUT_DIR=tests_outputs
PRECOMMIT_FILE_PATHS=./python_template/placeholder.py

.PHONY: help install install-test test test-parallel clean build publish doc pre-commit format lint
.DEFAULT_GOAL=help

.SILENT: help update_pip create_conda instal-base install install-no-cache install-test install-lint install-build test-one \
test-one-parallel test-all test-all-parallel test-coverage test-coverage-parallel clean-build clean-test test-docs \
build build-wheel publish doc doc-dev pre-commit-one pre-commit lint format typecheck typecheck-no-cache typecheck-report


help:
	grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		 awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m\
		 %s\n", $$1, $$2}'

update_pip:
	${PYTHON} -m pip install -U pip

create_conda:
	conda create -n ${ROOT_DIR} python=${PYTHON_VERSION} -y

install-base: update_pip ## Installs only package dependencies
	pip install --editable .

install: update_pip ## Installs the development and test version of the package
	pip install --editable .[test,dev]
	pre-commit install

install-no-cache: ## Installs the development and test version of the package
	pip install --no-cache-dir --editable .[test,dev]
	pre-commit install

install-test: ## Install only test version of the package
	pip install .[test]

install-lint:
	pip install ruff==0.0.193

install-build:
	pip install -U build

install-doc:
	pip install mkdocs mkdocs-material mkdocstrings[python]

test-one: ## Run specific tests with TEST_MARKER=<test_name>, default marker is `placeholder`
	${PYTHON} -m pytest -m ${TEST_MARKER}

test-one-parallel: ## Run specific tests with TEST_MARKER=<test_name> in parallel, default marker is `placeholder`
	${PYTHON} -m pytest -n auto -m ${TEST_MARKER}

test-all: ## Run all tests
	#mkdir -p ${TEST_OUTPUT_DIR}
	#cp .coveragerc ${TEST_OUTPUT_DIR}
	#cp setup.cfg ${TEST_OUTPUT_DIR}
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
	rm -rf ./junit
	rm -rf ./$(PACKAGE).egg-info
	rm -f MANIFEST
	rm -rf ./dist/*
	find . -type f -iname "*.so" -delete
	find . -type f -iname '*.pyc' -delete
	find . -type d -name '__pycache__' -empty -delete

clean-test: ## Clean test related files left after test
	#rm -rf ./htmlcov
	#rm -rf ./coverage.xml
	find . -type f -regex '\.\/\.*coverage[^rc].*' -delete
	rm -rf ${TEST_OUTPUT_DIR}
	find ${TEST_DIR} -type f -regex '\.\/\.*coverage[^rc].*' -delete
	find ${TEST_DIR} -type d -name 'htmlcov' -exec rm -r {} +
	rm -rf ./.pytest_cache
	rm -rf ./.mypy_cache
	rm -rf ./.ruff_cache

clean: clean-build clean-test ## Cleans build and test related files

build: update_pip ## Build the package, creates source distribution
	pip install build
	${PYTHON} -m build --sdist --outdir dist

build-wheel:
	${PYTHON} -m build --wheel --outdir dist

publish: update_pip ## Publish the package to pypi
	pip install twine
	twine upload dist/* --verbose --config-file .pypirc

doc: ## Build documentation with mkdocs
	mkdocs build

doc-github:
	mkdocs gh-deploy

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

format: ## Run black, ruff for all package files. CHANGES CODE
	${PYTHON} -m black ${PACKAGE}
	${PYTHON} -m ruff ${PACKAGE} --fix

typecheck:  ## Checks code with mypy
	${PYTHON} -m mypy --package ${PACKAGE}

typecheck-no-cache:  ## Checks code with mypy no cache
	${PYTHON} -m mypy --package ${PACKAGE} --no-incremental

typecheck-report: ## Checks code with mypy and generates html report
	${PYTHON} -m mypy --package ${PACKAGE} --html-report mypy_report
