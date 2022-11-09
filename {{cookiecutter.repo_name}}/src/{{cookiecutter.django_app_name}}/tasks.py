{% if cookiecutter.worker == 'rq' -%}
from django_rq import job


@job
{% else -%}
from {{ cookiecutter.django_project_name }}.celery import app


@app.task
{% endif -%}
def stuff():
    raise NotImplementedError
