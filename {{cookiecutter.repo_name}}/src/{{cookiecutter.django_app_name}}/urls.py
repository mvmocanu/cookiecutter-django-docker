from django.urls import path

from . import views

app_name = '{{ cookiecutter.django_app_name }}'

urlpatterns = [
    path('', views.index, name='index'),
]
