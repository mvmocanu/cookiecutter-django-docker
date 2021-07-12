FROM postgres:{{ cookiecutter.postgresql_version }}

RUN groupmod --gid=1000 postgres \
 && usermod --uid=1000 postgres
