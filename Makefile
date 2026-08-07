.PHONY: shell test build clean \
        verify-zsh verify-tmux verify-nvim verify-plugins verify-paths verify-omzp

IMAGE := dotfiles-test:fedora
MOUNT := -v $(CURDIR):/home/testuser/dotfiles
RUN := podman run --rm --userns=keep-id -e TERM=xterm-256color $(MOUNT) -w /home/testuser/dotfiles $(IMAGE)

build:
	podman build -t $(IMAGE) .

shell:
	@echo "=== Starting interactive shell with dotfiles installed ==="
	podman run --rm -it \
	  --userns=keep-id \
	  -e TERM=xterm-256color \
	  -v $(CURDIR):/home/testuser/dotfiles \
	  -w /home/testuser/dotfiles \
	  $(IMAGE) \
	  /bin/bash -c "bash install && exec zsh -i"

# Full test suite - each target runs in fresh container
test: build verify-zsh verify-tmux verify-nvim verify-plugins verify-paths verify-omzp
	@echo "=== All tests passed! ==="

# Individual verification targets
verify-zsh: build
	@echo "=== Testing ZSH configuration ==="
	$(RUN) /bin/bash -c "bash install && zsh -ic 'echo \"ZSH: OK\" && echo ZSH_VERSION=\${ZSH_VERSION}'"

verify-tmux: build
	@echo "=== Testing TMUX configuration ==="
	$(RUN) /bin/bash -c "bash install && tmux new-session -d -s test && tmux source ~/.tmux.conf && echo 'TMUX: OK' && tmux -V && tmux kill-session"

verify-nvim: build
	@echo "=== Testing Neovim ==="
	$(RUN) /bin/bash -c "bash install && nvim --headless -c 'qa!' && echo 'NVIM: OK' && nvim --version | head -1"

verify-plugins: build
	@echo "=== Testing plugin synchronization ==="
	$(RUN) /bin/bash -c "bash install && nvim --headless -c 'Lazy! sync' -c 'qa!' 2>&1 | tail -20 && echo 'PLUGINS: OK'"

verify-paths: build
	@echo "=== Testing PATH conditional logic ==="
	$(RUN) /bin/bash -c "bash install && zsh -ic 'echo PATH=\${path}'"

verify-omzp: build
	@echo "=== Testing OMZP plugins ==="
	$(RUN) /bin/bash -c "bash install && ls ~/.oh-my-zsh/plugins/ | head -20 && echo 'OMZP: OK'"

# Quick smoke test (single container)
smoke: build
	@echo "=== Running smoke test ==="
	$(RUN) /bin/bash -c "bash install && \
	  zsh -ic 'echo \"[OK] ZSH loaded\"' && \
	  tmux new-session -d -s smoke_test && tmux source ~/.tmux.conf && echo '[OK] TMUX loaded' && tmux kill-session && \
	  nvim --headless -c 'qa!' && echo '[OK] NVIM started' && \
	  echo '=== Smoke test passed! ==='"

clean:
	-podman rmi $(IMAGE) 2>/dev/null || true