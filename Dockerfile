# https://github.com/jerpena/bazelisk
FROM jerpena/bazelisk:latest as build-stage

# Multi stage build for compiling asciiflow [1] in Docker
# and serving with nginx
# [1]: https://github.com/lewish/asciiflow
# based on the official asciiflow deploy script
# https://github.com/lewish/asciiflow/blob/master/.github/workflows/deploy.yaml

# select default shell
SHELL ["/bin/bash", "-c"]

COPY ./asciiflow /asciiflow

WORKDIR /asciiflow

RUN rm .bazelrc \
    && bazel build site/... \
    && cp -r --dereference bazel-bin/site ./pages-deploy

FROM nginx:1.25.2-alpine

COPY ./scripts/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /asciiflow/pages-deploy /usr/share/nginx/html

EXPOSE 80
