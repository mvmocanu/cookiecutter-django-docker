from django.conf import settings
from django.contrib.admin import AdminSite
from django.utils.translation import gettext_lazy as _


class CustomAdminSite(AdminSite):
    site_header = _('{{ cookiecutter.django_project_name.title() }} v{version}').format(version=settings.PROJECT_VERSION)
