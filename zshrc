source "$HOME/.antigen/antigen.zsh"

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
# Docker
antigen bundle docker
antigen bundle docker-compose

antigen bundle nmap
antigen bundle pip
antigen bundle dnf
antigen bundle terraform
antigen bundle vagrant
antigen bundle zsh-users/zsh-completions
antigen bundle command-not-found
antigen bundle zsh-users/zsh-autosuggestions
# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle chrissicool/zsh-256color

antigen theme agnoster

# Tell Antigen that you're done.
antigen apply

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ${HOME}/.local/bin/balenaEtcher.AppImage ] && alias balenaEtcher="${HOME}/.local/bin/balenaEtcher.AppImage"

[ -f ${HOME}/.local/bin/nvim.appimage ] && alias nvim="${HOME}/.local/bin/nvim.appimage"

[ -x $(command -v exa) ] && alias ls=exa

export EDITOR='nvim'
