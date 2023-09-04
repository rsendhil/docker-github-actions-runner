# hadolint ignore=DL3007
FROM --platform=linux/amd64 myoung34/github-runner-base:ubuntu-jammy
# LABEL maintainer="myoung34@my.apsu.edu"

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache
RUN apt-get update
RUN apt-get install gcc wget build-essential libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y
RUN apt-get install python3.11 -y
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN apt-get install build-essential procps curl file git -y
RUN apt-get install ruby-full -y
RUN apt-get update && apt-get install -y wget git-core
RUN cd /tmp
RUN wget --no-check-certificate https://storage.googleapis.com/golang/go1.10.linux-amd64.tar.gz
RUN tar -xzf go1.10.linux-amd64.tar.gz
RUN mv go /usr/local/go
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/var/www/go
ENV PATH=$PATH:$GOPATH/bin
RUN mkdir -p $GOPATH/src
RUN mkdir -p $GOPATH/bin
RUN mkdir -p $GOPATH/pkg
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /root/.profile
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
ENV PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
RUN brew install norwoodj/tap/helm-docs
RUN apt-get update

ARG GH_RUNNER_VERSION="2.308.0"

ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /actions-runner
COPY install_actions.sh /actions-runner

# RUN chmod +x /actions-runner/install_actions.sh \
#   && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
#   && rm /actions-runner/install_actions.sh \
#   && chown runner /_work /actions-runner /opt/hostedtoolcache

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh

COPY token.sh entrypoint.sh app_token.sh /
RUN chmod +x /token.sh /entrypoint.sh /app_token.sh

USER root

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
