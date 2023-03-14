from django.db import models


class {{ cookiecutter.django_model_name }}(models.Model):
    def __str__(self):
        return f"{{ cookiecutter.django_model_name }}(pk={self.pk})"
