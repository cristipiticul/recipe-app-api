FROM python:3.9-alpine3.13
# LABEL maintainer="cristian.militaru.94@gmail.com" deprecated? - https://docs.docker.com/reference/dockerfile/#maintainer-deprecated
LABEL org.opencontainers.image.authors="cristian.militaru.94@gmail.com"

# Avoid Python buffering the output - good for docker images
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user
# Notes on the above:
# - Single RUN command with && \ creates a single layer instead of multiple
#   and makes building images more efficient
# - Create a virtual enviroment - some people disagree with this, in docker
#   we don't have other python dependencies, but sometimes it can help
#   to safeguard against conflicting dependencies from base image
# - django-user is created so if the app becomes comrpomised, the hacker
#   doesn't have root access to the container


ENV PATH="/py/bin:$PATH"

USER django-user