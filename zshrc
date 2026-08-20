ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -r "$ZINIT_HOME/zinit.zsh" ]]; then
  command mkdir -p "${ZINIT_HOME:h}"
  command git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

zinit light zsh-users/zsh-completions
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

for plugin in git npm dotenv docker docker-compose rust vagrant terraform ansible dnf pip; do
  zinit snippet "OMZP::$plugin"
done
zinit light zsh-users/zsh-syntax-highlighting
setopt promptsubst

if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
  AGNOSTER_CONTEXT_BG=red
fi
zinit snippet OMZT::agnoster

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath 2>/dev/null'

[[ -r "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd cd zsh)"
fi

if (( $+commands[opencode] )); then
  eval "$(opencode completion zsh)"
fi

if (( $+commands[omp] )); then
  eval "$(omp completions zsh)"
fi

[[ -x "$HOME/.local/bin/balenaEtcher.AppImage" ]] && alias balenaEtcher="$HOME/.local/bin/balenaEtcher.AppImage"
[[ -x "$HOME/.local/bin/nvim.appimage" ]] && alias nvim="$HOME/.local/bin/nvim.appimage"
[[ -x "$HOME/.local/bin/lvim" ]] && alias lvim="$HOME/.local/bin/lvim"

if (( $+commands[eza] )); then
  alias ls='eza'
elif (( $+commands[exa] )); then
  alias ls='exa'
fi

OCI_COMPLETION="$HOME/.local/lib/oracle-cli/lib/python3.11/site-packages/oci_cli/bin/oci_autocomplete.sh"
[[ -r "$OCI_COMPLETION" ]] && source "$OCI_COMPLETION"
unset OCI_COMPLETION

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
