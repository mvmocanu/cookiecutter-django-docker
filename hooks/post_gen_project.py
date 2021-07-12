import datetime
import os
import random
import shutil
import subprocess
import sys
from os.path import join

try:
    from click.termui import secho
except ImportError:
    warn = note = print
else:
    def warn(text):
        for line in text.splitlines():
            secho(line, fg="white", bg="red", bold=True)


    def note(text):
        for line in text.splitlines():
            secho(line, fg="yellow", bold=True)


def unlink_if_exists(path):
    if os.path.exists(path):
        os.unlink(path)


def replace_content(filename, what, replacement):
    with open(filename) as fh:
        content = fh.read()
    with open(filename, 'w') as fh:
        fh.write(content.replace(what, replacement))


if __name__ == "__main__":
    print("""
################################################################################
################################################################################

    You have succesfully created `{{ cookiecutter.repo_name }}`.

################################################################################

    You've used these cookiecutter parameters:
{% for key, value in cookiecutter.items()|sort %}
        {{ "{0:26}".format(key + ":") }} {{ "{0!r}".format(value).strip("u") }}
{%- endfor %}

    See .cookiecutterrc for instructions on regenerating the project.

################################################################################

    To get started make a copy of the appropriate platform .env file:

        cd {{ cookiecutter.repo_name }}
        cp .env-linux-osx .env
          or
        cp .env-windows .env

    Then run these:

        docker-compose build --pull base
        docker-compose build
        docker-compose up
""")
    secret_key = ''.join(
        random.SystemRandom().choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)')
        for i in range(50)
    )
    replace_content('.env-linux-osx', '<SECRET_KEY>', secret_key)
    replace_content('.env-windows', '<SECRET_KEY>', secret_key)
    note('+ pip-compile --upgrade requirements/base.in')
    subprocess.check_call(['pip-compile', '--upgrade', 'requirements/base.in'])
    note('+ pip-compile --upgrade requirements/test.in')
    subprocess.check_call(['pip-compile', '--upgrade', 'requirements/test.in'])
    if not os.path.exists('.git'):
        warn('+ git init')
        subprocess.check_call(['git', 'init'])
    note('+ pre-commit autoupdate')
    subprocess.check_call(['pre-commit', 'autoupdate'])
    note('+ pre-commit install --install-hooks')
    subprocess.check_call(['pre-commit', 'install', '--install-hooks'])
