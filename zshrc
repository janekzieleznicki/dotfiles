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

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history
setopt append_history inc_append_history share_history
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

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

# Git prompt status symbols (normally provided by oh-my-zsh's lib/git.zsh).
# Without these, parse_git_dirty() always returns empty and the agnoster
# git segment never switches to dirty colors.
ZSH_THEME_GIT_PROMPT_DIRTY="✘"
ZSH_THEME_GIT_PROMPT_CLEAN=""
zinit snippet OMZL::git.zsh
zinit snippet OMZT::agnoster

zinit snippet OMZL::key-bindings.zsh
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
  _omp_comp="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/omp-completions.zsh"
  if [[ ! -s "$_omp_comp" || "${commands[omp]}" -nt "$_omp_comp" ]]; then
    command mkdir -p "${_omp_comp:h}"
    command omp completions zsh >| "$_omp_comp" 2>/dev/null
  fi
  [[ -s "$_omp_comp" ]] && source "$_omp_comp"
  unset _omp_comp
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


omp() {
    if [[ -f ~/.tokens.env ]]; then
        set -a
        source ~/.tokens.env
        set +a
    fi

    command omp "$@"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
