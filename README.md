# Python Level Up: Dockerize Python

#### Learn more at [cultivation.dev](https://cultivation.dev)

---

## py-alpine-poetry-script-template

### Docker Instructions

#### Docker Build & Run App

```
docker build --target application -f Dockerfile -t py-alpine-poetry-script .
docker run --user=appuser --env APP_ENV=DEV py-alpine-poetry-script
```

#### Docker Build & Run Tests

```
docker build --target testing -f Dockerfile -t py-alpine-poetry-script .
docker run --user=appuser --env APP_ENV=DEV py-alpine-poetry-script
```

---

### Local Environment

#### Pre-requisites

- Install pyenv for python version management - https://github.com/pyenv/pyenv
- Install poetry for python dependency management - https://python-poetry.org/docs/#installation
- Add pyenv path to profile e.g. add `export PYENV_ROOT="$HOME/.pyenv` + `export PATH="$PYENV_ROOT/bin:$PATH"`
- Add poetry path to profile e.g. add `export PATH="$HOME/.poetry/bin/:PATH`
- Install python version: `pyenv install 3.8.7`

#### Environment Setup

- Set python version for the debian-poetry-flask dir in the repo: `pyenv local 3.8.7`
- Set the poetry env version of python: `poetry env use /Users/<username>/.pyenv/versions/3.8.7/bin/python`
- Install python application dependencies: `poetry install`