flake8:
    flake8 --exclude .tox .

mypy:
    mypy --strict .

isort:
    isort --line-length 79 --skip .mypy_cache --skip .hypothesis \
        --skip .tox .

black: isort
    black --line-length 79 --extend-exclude="\.env/|\.tox/" .

coverage:
    COVERAGE_FILE=.coverage/.coverage python -m pytest --cov=aiorunner \
      --cov-report term --cov-report html:.coverage tests

build:
    if [ -d dist ]; then rm -rf dist; fi
    python -m build
    rm -rf *.egg-info

upload:
    twine upload dist/*
    rm -rf dist
