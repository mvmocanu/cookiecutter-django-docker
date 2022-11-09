from django.shortcuts import render


def index(request):
    return render(request, '{{cookiecutter.django_app_name}}/index.html', {'title': '{{ cookiecutter.name }}'})
