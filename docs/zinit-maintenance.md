# Zinit Maintenance

## Update Zinit
```bash
cd ~/.local/share/zinit/zinit.git && git pull
```

## Update Plugins
```bash
zsh -ic 'zinit update --all'
```
Or for a specific plugin:
```bash
zsh -ic 'zinit update zsh-users/zsh-completions'
```

## Pinning vs Latest
**Decision:** Track latest releases (default Zinit behavior). For reproducibility, pin specific commits in `zshrc` using `zinit ice commit=<hash>` before each `zinit light`/`snippet` if needed. Currently unpinned — updates pull latest on `zinit update`.

## Submodule Updates
The `modules/fzf` submodule provides the fzf install script. Update periodically:
```bash
git submodule update --remote modules/fzf
```
Then re-run `~/.fzf/install --key-bindings --completion --update-rc`.