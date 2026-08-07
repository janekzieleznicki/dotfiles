FROM fedora:latest

RUN dnf install -y dnf-plugins-core && \
    dnf update -y && \
    dnf install -y \
      git \
      zsh \
      tmux \
      neovim \
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
      sudo \
      findutils \
      procps-ng \
      ripgrep \
      fd-find \
      bat \
      clang \
      clang-tools-extra \
      && dnf clean all

# Optional: Uncomment to enable COPR neovim-nightly if needed
# RUN dnf copr enable -y uglyegg/neovim && dnf update -y neovim

ARG USERNAME=testuser
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p ~/.cache/zsh ~/.local/share/nvim ~/.config/nvim ~/.config/tmux/plugins