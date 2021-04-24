source "$HOME/.antigen/antigen.zsh"

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
# Rust
antigen bundle rust 
antigen bundle rustup 
antigen bundle cargo
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

antigen theme agnoster

# Tell Antigen that you're done.
antigen apply

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f $HOME/.local/bin/balenaEtcher-1.5.116-x64.AppImage ] && alias balenaEtcher=$HOME/.local/bin/balenaEtcher-1.5.116-x64.AppImage

[ -f $HOME/.local/bin/nvim.appimage ] && alias nvim=$HOME/.local/bin/nvim.appimage

export EDITOR='/usr/bin/nvim'
