FROM node:10.15-alpine

ARG GIT_BRANCH=unknown
ARG GIT_COMMIT=unknown
ARG GIT_URL=unknown
ARG BUILD_NUMBER=unknown
ARG BUILD_DATE=unknown
ARG MAINTAINERS="outlaws@outlab-labs.net"
LABEL \
  net.outlab-labs.build.date=${BUILD_DATE} \
  net.outlab-labs.build.number=${BUILD_NUMBER} \
  net.outlab-labs.git.branch=${GIT_BRANCH} \
  net.outlab-labs.git.commit=${GIT_COMMIT} \
  net.outlab-labs.git.url=${GIT_URL} \
  net.outlab-labs.maintainers=${MAINTAINERS} \
  net.outlab-labs.image.description="Minimal NodeJS 10.15 alpine base image"

RUN \
  addgroup -S outlaws && \
  adduser -S -g '' -G outlaws -s /sbin/nologin -h /srv outlaws
