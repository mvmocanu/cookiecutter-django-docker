from django.conf import settings
from django.contrib.admin import AdminSite


class CustomAdminSite(AdminSite):
    site_header = f'{{ cookiecutter.django_project_name.title() }} v{settings.PROJECT_VERSION}'
