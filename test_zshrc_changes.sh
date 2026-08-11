#!/bin/bash

# Test script to verify zshrc changes

echo "Testing zshrc changes..."

# Source zshrc in a way that captures output and errors
OUTPUT=$(zsh -c "
  # Set up minimal environment for testing
  export HOME=/tmp/test-home
  mkdir -p \$HOME
  export XDG_DATA_HOME=\$HOME/.local/share
  export XDG_CACHE_HOME=\$HOME/.cache
  
  # Source our zshrc
  source /home/jzieleznicki/Sources/dotfiles/zshrc 2>&1
  
  # Check for duplicate fzf.zsh sourcing
  echo \"=== Checking for duplicate fzf.zsh sourcing ===\"
  if [[ \${ZSH_VERSION} ]]; then
    # Count how many times fzf.zsh would be sourced
    FZF_COUNT=0
    if [[ -r \"\$HOME/.fzf.zsh\" ]]; then
      # This is tricky to test without actually sourcing, but we can check the logic
      echo \"\$HOME/.fzf.zsh exists\"
    fi
    
    # Check plugin list
    echo \"=== Checking plugin list ===\"
    # We can't easily check the plugin list after sourcing, but we can verify the zshrc content
    grep -n \"for plugin in\" /home/jzieleznicki/Sources/dotfiles/zshrc
    grep -n \"zinit light zsh-users/zsh-syntax-highlighting\" /home/jzieleznicki/Sources/dotfiles/zshrc
    
    # Check that zsh-syntax-highlighting comes after OMZP snippets
    echo \"=== Checking plugin order ===\"
    LINENUM_COMPLETIONS=\$(grep -n \"zinit light zsh-users/zsh-completions\" /home/jzieleznicki/Sources/dotfiles/zshrc | cut -d: -f1)
    LINENUM_AUTOSUGGESTIONS=\$(grep -n \"zinit light zsh-users/zsh-autosuggestions\" /home/jzieleznicki/Sources/dotfiles/zshrc | cut -d: -f1)
    LINENUM_FZF_TAB=\$(grep -n \"zinit light Aloxaf/fzf-tab\" /home/jzieleznicki/Sources/dotfiles/zshrc | cut -d: -f1)
    LINENUM_OMZP_LOOP_START=\$(grep -n \"for plugin in\" /home/jzieleznicki/Sources/dotfiles/zshrc | cut -d: -f1)
    LINENUM_OMZP_LOOP_END=\$(grep -n \"done\" /home/jzieleznicki/Sources/dotfiles/zshrc | grep -A5 \"\$LINENUM_OMZP_LOOP_START\" | head -2 | tail -1 | cut -d: -f1)
    LINENUM_SYNTAX_HIGHLIGHTING=\$(grep -n \"zinit light zsh-users/zsh-syntax-highlighting\" /home/jzieleznicki/Sources/dotfiles/zshrc | cut -d: -f1)
    
    echo \"zsh-completions at line: \$LINENUM_COMPLETIONS\"
    echo \"zsh-autosuggestions at line: \$LINENUM_AUTOSUGGESTIONS\"
    echo \"fzf-tab at line: \$LINENUM_FZF_TAB\"
    echo \"OMZP loop starts at line: \$LINENUM_OMZP_LOOP_START\"
    echo \"OMZP loop ends at line: \$LINENUM_OMZP_LOOP_END\"
    echo \"zsh-syntax-highlighting at line: \$LINENUM_SYNTAX_HIGHLIGHTING\"
    
    # Verify order: completions -> autosuggestions -> fzf-tab -> OMZP snippets -> syntax highlighting
    if [[ \$LINENUM_COMPLETIONS -lt \$LINENUM_AUTOSUGGESTIONS && \$LINENUM_AUTOSUGGESTIONS -lt \$LINENUM_FZF_TAB && \$LINENUM_FZF_TAB -lt \$LINENUM_OMZP_LOOP_START && \$LINENUM_OMZP_LOOP_END -lt \$LINENUM_SYNTAX_HIGHLIGHTING ]]; then
      echo \"PASS: Plugin load order is correct\"
    else
      echo \"FAIL: Plugin load order is incorrect\"
    fi
  fi
")

echo \"$OUTPUT\"

# Check for specific changes in the file
echo \"=== Checking specific file changes ===\"
echo \"1. Duplicate fzf.zsh sourcing removed (line 62 should be empty):\"
sed -n '62p' /home/jzieleznicki/Sources/dotfiles/zshrc | cat -A
echo \"2. fzf removed from OMZP plugin list:\"
grep \"for plugin in\" /home/jzieleznicki/Sources/dotfiles/zshrc
echo \"3. zsh-syntax-highlighting moved after OMZP loop:\"
grep -n \"zinit light zsh-users/zsh-syntax-highlighting\" /home/jzieleznicki/Sources/dotfiles/zshrc
echo \"4. Obsolete omz:update zstyle removed:\"
grep -n \"zstyle ':omz:update' mode disabled\" /home/jzieleznicki/Sources/dotfiles/zshrc || echo \"Not found (good!)\"