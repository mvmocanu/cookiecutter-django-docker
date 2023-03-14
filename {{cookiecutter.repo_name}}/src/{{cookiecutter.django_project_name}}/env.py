import builtins
import os


def get(key):
    return os.environ.get(key)


def str(key, default=Ellipsis):  # noqa: A001
    if default is Ellipsis:
        if bool("__strict_env__", True):
            return os.environ[key]
        else:
            return os.environ.get(key)
    else:
        return os.environ.get(key, default)


def list(key, default=None, separator=","):  # noqa: A001
    value = str(key, default)
    if value is None:
        return []
    else:
        return value.split(separator)


def int(key, default):  # noqa: A001
    return builtins.int(str(key, default))


def bool(key, default):  # noqa: A001
    if key in os.environ:
        return os.environ.get(key).lower() in ("yes", "true", "y", "1")
    else:
        return default
