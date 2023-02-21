from django.contrib.admin.apps import AdminConfig


class CustomAdminConfig(AdminConfig):
    default_site = "{{cookiecutter.django_project_name}}.admin.CustomAdminSite"
