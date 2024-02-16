# syntax=docker/dockerfile:{{ cookiecutter.__dockerfile_version }}
FROM buildpack-deps:{{ cookiecutter.__ubuntu_version }}-scm as deps

ARG TZ=UTC

# DEBIAN_FRONTEND=noninteractive exists to prevent tzdata going nuts.
# Maybe dpkg incorrectly detects interactive on buildkit containers?
RUN <<EOF bash
    set -euxo pipefail
    export DEBIAN_FRONTEND=noninteractive

    echo "deb http://apt.postgresql.org/pub/repos/apt {{ cookiecutter.__ubuntu_release }}-pgdg main {{ cookiecutter.postgresql_version.split('.')|first }}" > /etc/apt/sources.list.d/pgdg.list
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg
    apt-get update
    apt-get install -y --no-install-recommends \
        python3-dev python3-distutils-extra \
        python-is-python3 \
        libpq-dev={{ cookiecutter.postgresql_version.split('.')|first }}.* libpq5={{ cookiecutter.postgresql_version.split('.')|first }}.* \
        libgdal-dev \
        libtiff-dev libjpeg-dev libzip-dev libfreetype-dev \
        libwebp-dev tcl-dev tk-dev libffi-dev \
        libmemcached-dev zlib1g-dev libpcre3-dev \
        build-essential git sudo ca-certificates
EOF

RUN <<EOF bash
    set -euxo pipefail
    curl -fsSL 'https://bootstrap.pypa.io/get-pip.py' | python - --no-cache --disable-pip-version-check --upgrade \
    pip=={{ cookiecutter.__pip_version }} setuptools=={{ cookiecutter.__setuptools_version }} pip-tools=={{ cookiecutter.__pip_tools_version }}
EOF

ENV CPUCOUNT=1
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd --gid $GROUP_ID app \
 && useradd --uid $USER_ID --gid $GROUP_ID --shell /bin/bash --create-home /app

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
