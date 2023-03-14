from django.conf import settings
from django.contrib.admin import AdminSite


class CustomAdminSite(AdminSite):
    site_header = f"{{ cookiecutter.name.title() }} v{settings.PROJECT_VERSION}"
