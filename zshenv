typeset -U path PATH
path=(
  "$HOME/.local/bin"
  $path
)
[[ -d "$HOME/go/bin" ]] && path+=("$HOME/go/bin")
[[ -d "$HOME/.cargo/bin" ]] && path+=("$HOME/.cargo/bin")
export PATH
export EDITOR="nvim"
export VISUAL="$EDITOR"

[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
