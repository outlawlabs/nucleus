FROM ubuntu:18.04

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
  net.outlab-labs.image.description="Dockerized Ubuntu 18.04 base image"


# make apt non-interactive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90outlaws \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90outlaws

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && apt-get install -y \
  git \
  xvfb \
  locales \
  sudo \
  openssh-client \
  ca-certificates \
  tar \
  gzip \
  parallel \
  net-tools \
  netcat \
  unzip \
  zip \
  bzip2 \
  gnupg \
  curl \
  wget \
  lsb-release \
  apt-transport-https \
  locales

RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

# Install Latest NodeJS 10.X (LTS)
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - \
  && apt-get install nodejs \
  && node --version

# Install jq
ENV JQ_VERSION jq-1.6
RUN JQ_URL="https://github.com/stedolan/jq/releases/download/${JQ_VERSION}/jq-linux64" \
  && curl --silent --show-error --location --fail --retry 3 --output /usr/bin/jq $JQ_URL \
  && chmod +x /usr/bin/jq \
  && jq --version
 
# Install Docker
RUN set -ex \
  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*-ce\.tgz' | sort -r | head -n 1) \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
  && echo Docker URL: $DOCKER_URL \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && ls -lha /tmp/docker.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz \
  && which docker \
  && (docker version || true)

# Install awscli
RUN GET_PIP_URL="https://bootstrap.pypa.io/get-pip.py" \
  && curl -O $GET_PIP_URL \
  && python get-pip.py \
  && pip install awscli

# Install gcloud
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
  && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update -y \
  && apt-get install google-cloud-sdk -y

# Install Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN DOCKERIZE_URL="https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz" \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/dockerize-linux-amd64.tar.gz $DOCKERIZE_URL \
  && tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64.tar.gz \
  && rm -rf /tmp/dockerize-linux-amd64.tar.gz \
  && dockerize --version

# Install kubectl
ENV KUBECTL_VERSION v1.13.0
RUN KUBECTL_URL="https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl" \
  && curl -LO $KUBECTL_URL \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/bin/kubectl

# Install helm
ENV HELM_VERSION v2.12.3
RUN HELM_URL="https://storage.googleapis.com/kubernetes-helm/helm-$HELM_VERSION-linux-amd64.tar.gz" \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/helm.tar.gz $HELM_URL \
  && tar -C /usr/local/bin -xzvf /tmp/helm.tar.gz \
  && mv /usr/local/bin/linux-amd64/helm /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm \
  && rm -rf /tmp/helm.tar.gz \
  && rm -rf /usr/local/bin/linux-amd64

RUN groupadd --gid 3434 outlaws \
  && useradd --uid 3434 --gid outlaws --shell /bin/bash --create-home outlaws \
  && echo 'outlaws ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-outlaws \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

USER outlaws

CMD ["/bin/sh"]
