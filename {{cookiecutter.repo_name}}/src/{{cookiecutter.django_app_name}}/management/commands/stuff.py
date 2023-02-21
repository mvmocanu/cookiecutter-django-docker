from logging import getLogger

from django.core.management.base import BaseCommand

from ...models import Stuff

logger = getLogger(__name__)


class Command(BaseCommand):
    def add_arguments(self, parser):
        parser.add_argument("stuff_id")

    def handle(self, stuff_id, **options):
        stuff: Stuff = Stuff.objects.get(id=stuff_id)
        stuff.save()
