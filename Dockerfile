# syntax=docker/dockerfile:1
FROM docker.io/vaggeliskls/windows-in-docker-container:latest

# Github action settings
ENV GITHUB_RUNNER_NAME=windows_x64_vagrant
ENV GITHUB_RUNNER_VERSION=2.322.0
ENV GITHUB_RUNNER_FILE=actions-runner-win-x64-${GITHUB_RUNNER_VERSION}.zip
ENV GITHUB_RUNNER_URL=https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/${GITHUB_RUNNER_FILE}
ENV GITHUB_RUNNER_LABELS=windows,win_x64,windows_x64,windows_vagrant_action
ENV PRIVILEGED=true
ENV INTERACTIVE=true
ENV DOLLAR=$

WORKDIR /app
COPY Vagrantfile /app/

ENTRYPOINT []
CMD ["/app/startup.sh"]
