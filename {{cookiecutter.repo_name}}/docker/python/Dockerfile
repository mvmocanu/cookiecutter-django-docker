# syntax=docker/dockerfile:{{ cookiecutter.dockerfile_version }}
FROM buildpack-deps:{{ cookiecutter.ubuntu_version }}-scm as deps

ARG TZ=UTC

# DEBIAN_FRONTEND=noninteractive exists to prevent tzdata going nuts.
# Maybe dpkg incorrectly detects interactive on buildkit containers?
RUN echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && curl -fsSL11 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' | apt-key add - \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3-dev python3-distutils-extra \
        libpq-dev={{ cookiecutter.postgresql_version.split('.')|first }}.* libpq5={{ cookiecutter.postgresql_version.split('.')|first }}.* \
        libgdal-dev \
        libtiff-dev libjpeg-dev libzip-dev libfreetype-dev \
        libwebp-dev tcl-dev tk-dev libffi-dev \
        libmemcached-dev zlib1g-dev \
        build-essential git sudo ca-certificates
# Avoid having to use python3 all over the place.
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

RUN bash -o pipefail -c "curl -fsSL 'https://bootstrap.pypa.io/get-pip.py' | \
    python - --no-cache --disable-pip-version-check --upgrade pip=={{ cookiecutter.pip_version }} setuptools=={{ cookiecutter.setuptools_version }}"

# This intents to be the sole Dockerfile for the project so allow building variants with different or no dependencies.
COPY requirements /requirements
ARG REQUIREMENTS
RUN --mount=type=cache,target=/root/.cache set -x \
 && mkdir /deps \
 && if [ -n "$REQUIREMENTS" ] \
  ; then python -mpip wheel --wheel-dir=/deps/wheels -r requirements/$REQUIREMENTS.txt \
 && ls -al /deps/wheels \
  ; else echo 'No REQUIREMENTS defined!' \
  ; fi


##################################
##################################
FROM buildpack-deps:{{ cookiecutter.ubuntu_version }} as certs
##################################
ARG SERVER_NAME="localhost"
RUN mkdir /certs \
 && openssl req -x509 -nodes -newkey rsa:4096 -sha256 \
                -out /certs/fullchain.pem -keyout /certs/privkey.pem \
                -subj "/CN=$SERVER_NAME"

#################
#################
FROM ubuntu:{{ cookiecutter.ubuntu_version }}
#################
RUN test -e /etc/apt/apt.conf.d/docker-clean # sanity check

ARG TZ={{ cookiecutter.timezone }}
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
        libpq5={{ cookiecutter.postgresql_version.split('.')|first }}.* postgresql-client-{{ cookiecutter.postgresql_version.split('.')|first }} \
        python3-dbg python3-distutils-extra \
        libmemcached11 \
        sudo ca-certificates \
        nginx \
        gdal-bin python3-gdal
# Avoid having to use python3 all over the place.
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

# Adds a new user named python and add it to the list of sudoers. Will be able to call sudo without the password.
# This is more geared to development (eg: match user's UID) than production (where you shouln't need any sudo/home).
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd --gid $GROUP_ID app \
 && useradd --uid $USER_ID --gid $GROUP_ID --shell /bin/bash --create-home app \
 && echo "app ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

RUN bash -o pipefail -c "curl -fsSL 'https://bootstrap.pypa.io/get-pip.py' | \
    python - --no-cache --disable-pip-version-check --upgrade pip=={{ cookiecutter.pip_version }} setuptools=={{ cookiecutter.setuptools_version }}"

RUN --mount=type=bind,from=deps,src=/deps,target=/deps set -x \
 && if [ -e /deps/wheels ] \
  ; then pip install --force-reinstall --ignore-installed --upgrade --no-index --no-deps /deps/wheels/* \
  ; else echo 'No wheels built!' \
  ; fi

RUN mkdir -p /app /var/app/logs /var/app/static /etc/app \
 && chown -R app:app /app

RUN echo /app/src > $(python -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')/app.pth

RUN ln -sf /proc/self/fd/2 /var/app/logs/httpd_error.log \
 && ln -sf /proc/self/fd/1 /var/app/logs/httpd_access.log

COPY src /app/src

ENV PYTHONUNBUFFERED=x
ENV PYTHONFAULTHANDLER=x

ARG DJANGO_SETTINGS_MODULE
ENV DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
ARG DJANGO_SECRET_KEY="n/a"
ARG SERVER_NAME="localhost"

WORKDIR /app

ARG DJANGO_COLLECTSTATIC
RUN set -x \
 && if [ -n "$DJANGO_COLLECTSTATIC" ] \
  ; then django-admin collectstatic --noinput --clear -v0 \
  ; fi

COPY docker/python/entrypoint.sh /
COPY docker/python/uwsgi.ini /etc/app/
COPY docker/python/nginx.conf /etc/app/
COPY docker/python/nginx.site /tmp/
COPY docker/python/yacron.yml /etc/app/
COPY --from=certs /certs/* /etc/app
ADD https://ssl-config.mozilla.org/ffdhe2048.txt /etc/app/dhparam

ARG SERVER_NAME="localhost"
RUN envsubst < /tmp/nginx.site > /etc/app/nginx.site
RUN cp /etc/app/fullchain.pem /etc/app/chain.pem \
 && ln -sf /etc/app/nginx.conf /etc/nginx/nginx.conf \
 && cp /etc/nginx/mime.types /etc/app \
 && cp -r /etc/app /etc/app-defaults
