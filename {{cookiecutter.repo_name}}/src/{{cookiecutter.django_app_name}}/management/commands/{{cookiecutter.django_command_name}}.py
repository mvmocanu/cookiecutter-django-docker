from logging import getLogger

from django.core.management.base import BaseCommand

from ...models import {{ cookiecutter.django_model_name }}

logger = getLogger(__name__)


class Command(BaseCommand):
    def add_arguments(self, parser):
        parser.add_argument("{{ cookiecutter.django_model_name.lower() }}_id")

    def handle(self, {{ cookiecutter.django_model_name.lower() }}_id, **options):
        stuff: {{ cookiecutter.django_model_name }} = {{ cookiecutter.django_model_name }}.objects.get(id=stuff_id)
        stuff.save()
