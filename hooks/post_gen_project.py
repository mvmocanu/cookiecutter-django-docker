import glob
import os
import random
import shutil
import subprocess
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

""")
    secret_key = ''.join(
        random.SystemRandom().choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)')
        for i in range(50)
    )
    replace_content('.env-linux-osx', '<SECRET_KEY>', secret_key)
    replace_content('.env-windows', '<SECRET_KEY>', secret_key)
    if os.name == 'nt':
        replace_content('.env-windows', '<CHECKOUT_PATH>', os.getcwd())
    else:
        replace_content('.env-windows', '<CHECKOUT_PATH>', r'd:\projects\{{ cookiecutter.repo_name }}')
    if not glob.glob('requirements/*.txt'):
        warn('+ ./test.sh requirements')
        subprocess.check_call(['./test.sh', 'requirements'])
    if not os.path.exists('.git'):
        warn('+ git init')
        subprocess.check_call(['git', 'init'])

{%- if cookiecutter.worker != "rq" %}
    os.unlink(join('docker', 'python', 'worker.ini'))
{%- endif %}
{%- if cookiecutter.worker != "celery" %}
    os.unlink(join('src', '{{ cookiecutter.django_project_name }}', 'celery.py'))
{%- endif %}

    if not os.path.exists('.env'):
        warn('+ cp .env-linux-osx .env')
        shutil.copy('.env-linux-osx', '.env')

    note('+ docker lock generate')
    subprocess.check_call(['docker', 'lock', 'generate'])
    note('+ docker lock rewrite --tempdir .')
    subprocess.check_call(['docker', 'lock', 'rewrite', '--tempdir', '.'])

    note('+ pre-commit autoupdate')
    subprocess.check_call(['pre-commit', 'autoupdate'])
    note('+ pre-commit install --install-hooks')
    subprocess.check_call(['pre-commit', 'install', '--install-hooks'])
    if os.path.exists('.env'):
        note('+ docker-compose build')
        subprocess.check_call(['docker-compose', 'build'])
    else:
        warn("You don't have an .env file yet. Skipping docker-compose build")
    print("""
################################################################################

    To get started make a copy of the appropriate platform .env file:

        cd {{ cookiecutter.repo_name }}
        cp .env-linux-osx .env
          or
        cp .env-windows .env

    To build the project:

        docker-compose build --pull

    You can bring up the project with:

        docker-compose up
    """)
