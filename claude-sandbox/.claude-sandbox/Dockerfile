FROM node:22-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      git ripgrep curl ca-certificates jq less zsh sudo \
      tcpdump uuid-runtime procps \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

RUN curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

RUN useradd -m -u 1001 -s /bin/zsh claude \
    && echo 'claude ALL=(root) NOPASSWD: /usr/local/bin/log-egress.sh' \
         > /etc/sudoers.d/claude-egress \
    && chmod 0440 /etc/sudoers.d/claude-egress

COPY run-agent.sh log-egress.sh /usr/local/bin/
COPY commit-msg-hook.sh /usr/local/etc/git-hooks/commit-msg
RUN chmod +x /usr/local/bin/run-agent.sh /usr/local/bin/log-egress.sh \
             /usr/local/etc/git-hooks/commit-msg

# System-wide gitconfig for the container. Points every repo at our hooks
# directory (so the commit-msg co-author trailer fires) without touching the
# host's ~/.gitconfig or writing into the /home/claude volume.
RUN printf '[core]\n\thooksPath = /usr/local/etc/git-hooks\n' > /etc/gitconfig-claude

USER claude
ENV HOME=/home/claude
ENV PATH="/home/claude/.local/share/mise/shims:${PATH}"

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/run-agent.sh"]
