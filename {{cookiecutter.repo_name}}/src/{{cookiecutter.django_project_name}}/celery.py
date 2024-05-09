import os

from celery import Celery

assert "DJANGO_SETTINGS_MODULE" in os.environ

app = Celery("{{ cookiecutter.django_project_name }}")
app.config_from_object("django.conf:settings", namespace="CELERY")

# Load task modules from all registered Django app configs.
app.autodiscover_tasks()
