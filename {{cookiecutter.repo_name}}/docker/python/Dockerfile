# syntax=docker/dockerfile:1.2.1
FROM buildpack-deps:{{ cookiecutter.ubuntu_version }}-scm as deps

ARG POSTGRESQL_VERSION=13
ARG TZ=UTC

# DEBIAN_FRONTEND=noninteractive exists to prevent tzdata going nuts (maybe dpkg incorrectly detects interactive on buildkit containers?)
RUN echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && curl -fsSL11 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' | apt-key add - \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3-dev python3-distutils-extra \
        libpq-dev=$POSTGRESQL_VERSION.* libpq5=$POSTGRESQL_VERSION.* \
        libgdal-dev \
        libtiff-dev libjpeg-dev libzip-dev libfreetype-dev \
        libwebp-dev tcl-dev tk-dev libffi-dev \
        libmemcached-dev zlib1g-dev \
        build-essential git sudo ca-certificates
# avoid having to use python3 all over the place
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

ARG PYTHON_PIP_VERSION={{ cookiecutter.pip_version }}
ARG PYTHON_SETUPTOOLS_VERSION={{ cookiecutter.setuptools_version }}
RUN bash -o pipefail -c "curl -fsSL 'https://bootstrap.pypa.io/get-pip.py' | \
    python - --no-cache --disable-pip-version-check --upgrade pip==$PYTHON_PIP_VERSION setuptools==$PYTHON_SETUPTOOLS_VERSION"

COPY requirements /requirements
#ENV PATH=$PATH:/usr/pgsql-13/bin
ARG REQUIREMENTS
RUN --mount=type=cache,target=/root/.cache set -x \
 && python -mpip wheel --wheel-dir=/wheels -r requirements/$REQUIREMENTS.txt \
 && ls -al /wheels

##################################
##################################
FROM buildpack-deps:{{ cookiecutter.ubuntu_version }} as certs
##################################
RUN mkdir /etc/app \
 && openssl req -x509 -nodes -newkey rsa:4096 -sha256 \
                -out /etc/app/certificate.crt -keyout /etc/app/certificate.key \
                -subj '/CN=localhost'
ADD https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem /etc/app/dhparams.pem

#################
#################
FROM ubuntu:{{ cookiecutter.ubuntu_version }}
#################
RUN test -e /etc/apt/apt.conf.d/docker-clean # sanity check

ARG POSTGRESQL_VERSION=13
ARG TZ=Europe/Bucharest
ENV TZ=$TZ
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl software-properties-common gpg-agent \
 && echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && curl -fsSL11 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' | apt-key add - \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        strace gdb lsof locate net-tools htop iputils-ping dnsutils \
        nano vim tree less telnet \
        socat \
        graphviz \
        dumb-init \
        libpq5=$POSTGRESQL_VERSION.* postgresql-client-$POSTGRESQL_VERSION \
        python3-dbg python3-distutils-extra \
        libmemcached11 \
        sudo ca-certificates \
        apache2 libapache2-mod-wsgi-py3 \
        gdal-bin python3-gdal
# avoid having to use python3 all over the place
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

# adds a new user named python and add it to the list of sudoers. Will be able to call sudo without the password
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd --gid $GROUP_ID app \
 && useradd --uid $USER_ID --gid $GROUP_ID --shell /bin/bash --create-home app \
 && echo "app ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

ARG PYTHON_PIP_VERSION=21.1.1
ARG PYTHON_SETUPTOOLS_VERSION=56.2.0
RUN bash -o pipefail -c "curl -fsSL 'https://bootstrap.pypa.io/get-pip.py' | \
    python - --no-cache --disable-pip-version-check --upgrade pip==$PYTHON_PIP_VERSION setuptools==$PYTHON_SETUPTOOLS_VERSION"

RUN --mount=type=bind,from=deps,src=/wheels,target=/deps \
    pip install --force-reinstall --ignore-installed --upgrade --no-index --no-deps /deps/*

RUN mkdir /app /var/app /var/app/logs /var/app/static \
 && chown -R app:app /app /var/app

COPY --from=certs /etc/app /etc/app

RUN echo /app/src > $(python -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')/app.pth

RUN ln -sf /proc/self/fd/2 /var/app/logs/httpd_error.log \
 && ln -sf /proc/self/fd/1 /var/app/logs/httpd_access.log

COPY src /app/src

ENV PYTHONUNBUFFERED=x
ENV PYTHONFAULTHANDLER=x

ARG DJANGO_SETTINGS_MODULE
ENV DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE

# Fillins for settings that aren't optional but are needed for collectstatic
# ARG is used to avoid persisting these variables
ARG DJANGO_SECRET_KEY="n/a"
ARG SERVER_NAME="docker"

WORKDIR /app
RUN pysu app django-admin collectstatic --noinput -v0 --clear --link

COPY docker/python/entrypoint.sh /
COPY docker/python/httpd.conf /etc/app
COPY docker/python/yacron.yml /etc/app
RUN cp -r /etc/app /etc/app-defaults
