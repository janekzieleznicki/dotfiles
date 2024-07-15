export ZSH="$HOME/.oh-my-zsh"

# Load the oh-my-zsh's library.

plugins=(
  ansible
  git
  npm
  dotenv
  docker
  rust
  fzf
  vagrant
  terraform
  dnf
  pip
  zoxide
    zsh-autosuggestions
)

ZSH_THEME="agnoster"
zstyle ':omz:update' mode auto

source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ${HOME}/.local/bin/balenaEtcher.AppImage ] && alias balenaEtcher="${HOME}/.local/bin/balenaEtcher.AppImage"

[ -f ${HOME}/.local/bin/nvim.appimage ] && alias nvim="${HOME}/.local/bin/nvim.appimage"

[ -f ${HOME}/.local/bin/lvim ] && alias lvim="${HOME}/.local/bin/lvim"

[ ! -z "$(command -v exa)" ] && alias ls=exa

export EDITOR='nvim'

export PATH=${HOME}/.local/bin:${HOME}/go/bin:${HOME}/.cargo/bin:${PATH}

[[ -e "${HOME}/.local/lib/oracle-cli/lib/python3.11/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "${HOME}/.local/lib/oracle-cli/lib/python3.11/site-packages/oci_cli/bin/oci_autocomplete.sh"

eval "$(zoxide init --cmd cd zsh)"
