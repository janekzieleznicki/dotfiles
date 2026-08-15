# ==========================================
# STAGE 1: Test Base
# ==========================================
FROM fedora:latest AS test

ARG TARGETARCH

RUN dnf install -y dnf-plugins-core && \
    dnf --refresh install -y \
    git \
    zsh \
    tmux \
    fzf \
    zoxide \
    eza \
    go \
    rust \
    cargo \
    python3 \
    python3-pip \
    nodejs \
    npm \
    make \
    gcc \
    gcc-c++ \
    cmake \
    unzip \
    wget \
    curl \
    tar \
    gzip \
    which \
    xclip \
    sudo \
    findutils \
    procps-ng \
    ripgrep \
    fd-find \
    bat \
    clang \
    clang-tools-extra \
    luarocks \
    lua-devel \
    && dnf clean all

RUN if [ "$TARGETARCH" = "arm64" ]; then \
    NVIM_ARCH="nvim-linux-arm64"; \
    else \
    NVIM_ARCH="nvim-linux-x86_64"; \
    fi && \
    curl -LO https://github.com/neovim/neovim/releases/latest/download/${NVIM_ARCH}.tar.gz && \
    tar -C /opt -xzf ${NVIM_ARCH}.tar.gz && \
    ln -s /opt/${NVIM_ARCH}/bin/nvim /usr/local/bin/nvim && \
    rm ${NVIM_ARCH}.tar.gz

ARG USERNAME=testuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

ENV TERM=xterm-256color
ENV SHELL=/bin/zsh

RUN mkdir -p ~/.cache/zsh ~/.local/share/nvim ~/.config/nvim ~/.config/tmux/plugins

CMD ["/bin/zsh"]


# ==========================================
# STAGE 2: Full Image (dotfiles + Lazy + Mason)
# ==========================================
FROM test AS full

COPY --chown=testuser:testuser . /home/testuser/dotfiles

WORKDIR /home/testuser/dotfiles

# Rozdzielone instrukcje nvim, aby Mason wymusił załadowanie po zsynchronizowaniu wtyczek przez Lazy
RUN bash install && \
    nvim --headless -c 'Lazy! restore' -c 'qa!' && \
    nvim --headless -c 'MasonToolsInstallSync' -c 'qa!'

WORKDIR /home/testuser

CMD ["/bin/zsh"]