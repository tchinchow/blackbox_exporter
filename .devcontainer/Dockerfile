FROM mcr.microsoft.com/devcontainers/go:1.26-bookworm

# Pre-create volume mount-point parents so Docker does not create them as root.
USER root
RUN mkdir -p /home/vscode/.cache/go-build /home/vscode/go/pkg/mod \
    && chown -R vscode:vscode /home/vscode/.cache /home/vscode/go
USER vscode
