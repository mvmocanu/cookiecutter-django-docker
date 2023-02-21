{% if cookiecutter.worker == "rq" -%}
from admin_utils import register_view
{% endif -%}
from django.contrib import admin
from django.contrib.admin import register
{%- if cookiecutter.worker == "rq" %}
from django_rq import views
{%- endif %}

from .models import Stuff
{%- if cookiecutter.worker == "rq" %}

register_view(app_label="django_rq", model_name="RQ")(views.stats)
{%- endif %}


@register(Stuff)
class StuffAdmin(admin.ModelAdmin):
    pass
