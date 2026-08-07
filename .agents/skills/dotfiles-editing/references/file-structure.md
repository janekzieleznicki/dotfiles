# dotfiles File Structure Reference

## Complete Directory Tree

```
dotfiles/
├── init.lua                 # Neovim main entry
├── vimrc                    # Vim/Neovim shared config
├── .vimrc.min               # Minimal vimrc
├── tmux.conf                # tmux main config
├── tmux_readme.md           # tmux keybinding docs
├── zshrc                    # zsh main config
├── zshenv                   # zsh environment variables
│
├── vim/
│   ├── lua/
│   │   ├── lazy-config.lua  # lazy.nvim plugin management
│   │   ├── coc-config.lua   # coc.nvim LSP config
│   │   ├── map.lua          # Key mappings
│   │   ├── edit.lua         # Editor behavior
│   │   └── command.lua      # Custom commands
│   ├── toml/
│   │   ├── dein.toml        # dein plugins (legacy)
│   │   └── dein_lazy.toml   # dein lazy plugins
│   ├── plugin-settings/
│   │   ├── coc-settings.vim
│   │   ├── coc-settings.json
│   │   ├── lightline.vim
│   │   └── vim-go.vim
│   ├── ftplugin/
│   │   ├── python.vim
│   │   ├── go.vim
│   │   ├── c.vim
│   │   └── cpp.vim
│   └── snippets/
│       ├── go.snip
│       └── c.snip
│
├── zsh/
│   ├── alias.zsh            # Shell aliases
│   ├── zinit.zsh            # zinit plugin manager
│   ├── prompt.zsh           # Prompt config
│   ├── history.zsh          # History settings
│   ├── completion.zsh       # Completion settings
│   └── fzf/
│       └── key-bindings.zsh # fzf integration
│
├── scripts/
│   ├── setup.sh             # Install script
│   └── install_fzf.sh       # fzf installer
│
└── docker/
    ├── Dockerfile           # Rocky Linux 9 + tools
    ├── docker-compose.yml   # Worktree-aware compose
    └── scripts/
        ├── dotfiles-dev     # Management script
        └── entrypoint.sh    # Container init
```

## Load Order

### Neovim

1. `init.lua` (entry point)
2. `vim/lua/lazy-config.lua` (plugins)
3. `vim/lua/*.lua` (settings)
4. `vim/ftplugin/*.vim` (per filetype)

### zsh

1. `zshenv` (always first)
2. `zshrc` (interactive shell)
3. `zsh/*.zsh` (sourced from zshrc)

## Symlink Structure (in Docker)

```
~/.config/nvim/init.lua -> ~/.dotfiles/init.lua
~/.tmux.conf -> ~/.dotfiles/tmux.conf
~/.zshrc: source ~/.dotfiles/zshrc
~/.zshenv: source ~/.dotfiles/zshenv
```
