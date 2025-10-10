# syntax=docker/dockerfile:1.5
FROM ghcr.io/vaggeliskls/windows-in-docker-container:latest

# Runner settings
ENV RUNNER_NAME=windows_x64_vagrant
# GitHub Runner settings
ENV GITHUB_RUNNER_VERSION=2.318.0
ENV GITHUB_RUNNER_FILE=actions-runner-win-x64-${GITHUB_RUNNER_VERSION}.zip
ENV GITHUB_RUNNER_URL=https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/${GITHUB_RUNNER_FILE}
ENV GITHUB_RUNNER_LABELS=windows,win_x64,windows_x64,windows_vagrant_action
# GitLab Runner settings
ENV GITLAB_RUNNER_VERSION=16.5.0
ENV GITLAB_RUNNER_FILE=gitlab-runner-windows-amd64.exe
ENV GITLAB_RUNNER_URL=https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_RUNNER_VERSION}/${GITLAB_RUNNER_FILE}
ENV GITLAB_RUNNER_TAGS=windows,win_x64,windows_x64,windows_vagrant_runner
ENV PRIVILEGED=true
ENV INTERACTIVE=true
ENV DOLLAR=$

RUN rm -rf /Vagrantfile /Vagrantfile.tmp /startup.sh

COPY Vagrantfile /Vagrantfile.tmp
COPY startup.sh /
RUN chmod +x startup.sh

ENTRYPOINT ["/startup.sh"]
CMD ["/bin/bash"]
