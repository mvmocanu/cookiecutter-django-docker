from .settings import *  # noqa: F401,F403

# do your test customizations here, eg:
# INSTALLED_APPS += "tests.TestAppConfig",
LANGUAGE_CODE = "en-us"
{%- if cookiecutter.worker == "rq" %}
RQ_QUEUES["default"]["ASYNC"] = False  # noqa: F405
{%- endif %}
