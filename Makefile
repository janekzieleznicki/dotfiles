.PHONY: shell test build build-test build-full clean \
        verify-zsh verify-tmux verify-nvim verify-nvim-e2e verify-plugins verify-paths verify-omzp smoke

IMAGE_TEST := dotfiles-test:base
IMAGE_FULL := dotfiles:latest

MOUNT := -v $(CURDIR):/home/testuser/dotfiles:z
NVIM_DATA := -v dotfiles-nvim-data:/home/testuser/.local/share/nvim:z
RUN := podman run --rm --userns=keep-id -e TERM=xterm-256color $(MOUNT) $(NVIM_DATA) -w /home/testuser/dotfiles $(IMAGE_TEST)

RUN_FULL := podman run --rm -e TERM=xterm-256color $(NVIM_DATA) -w /home/testuser $(IMAGE_FULL)

# Buduje etap testowy
build-test:
	podman build --pull=always --target test -t $(IMAGE_TEST) .

# Buduje pełny, gotowy obraz ze skopiowanymi dotfiles i pobranymi wtyczkami
build-full:
	podman build --pull=always --target full -t $(IMAGE_FULL) .

build: build-test build-full

shell: build-full
	@echo "=== Starting interactive shell in pre-baked full image ==="
	podman run --rm -it --userns=keep-id $(IMAGE_FULL) zsh -i

# Zestaw testów wykonuje się na etapie 'test' z zamontowanym kodem źródłowym
test: build-test verify-zsh verify-tmux test-nvim verify-plugins verify-paths verify-omzp
	@echo "=== All tests passed! ==="

verify-zsh: build-test
	@echo "=== Testing ZSH configuration ==="
	$(RUN) /bin/bash -c "bash install && zsh -ic 'echo \"ZSH: OK\" && echo ZSH_VERSION=\${ZSH_VERSION}'"

verify-tmux: build-test
	@echo "=== Testing TMUX configuration ==="
	$(RUN) /bin/bash -c "bash install && tmux new-session -d -s test && tmux source ~/.tmux.conf && echo 'TMUX: OK' && tmux -V && tmux kill-session"

# Dotychczasowy szybki check dymny (Sanity check)
verify-nvim: build-test
	@echo "=== Testing Neovim (Syntax, plugins & load errors) ==="
	$(RUN) /bin/bash -c "bash install && \
	  nvim --headless +'source ./nvim/test/verify.lua' 2>&1 | tail -60"

# Nowy test E2E z mini.test (Klawiatura, komendy, TUI Screenshots)
verify-nvim-e2e: build-test
	@echo "=== Testing Neovim E2E (Keymaps, Commands & TUI Rendering) ==="
	$(RUN) /bin/bash -c "\
	  bash install && \
	  nvim --headless -c 'Lazy! sync' -c 'qa!' && \
	  nvim --headless -u nvim/init.lua -c 'luafile nvim/test/run_mini_test.lua'"

# Łączony target dla pełnego zestawu
test-nvim: build-test verify-nvim verify-nvim-e2e
	@echo "=== All Neovim smoke and E2E tests passed! ==="

verify-plugins: build-test
	@echo "=== Testing plugin synchronization ==="
	$(RUN) /bin/bash -c "bash install && nvim --headless -c 'Lazy! sync' -c 'qa!' 2>&1 | tail -20 && echo 'PLUGINS: OK'"

verify-paths: build-test
	@echo "=== Testing PATH conditional logic ==="
	$(RUN) /bin/bash -c "bash install && zsh -ic 'echo PATH=\${path}'"

verify-omzp: build-test
	$(RUN) /bin/bash -c "bash install && ls ~/.local/share/zinit/snippets/OMZP::* | head -20 && echo 'OMZP: OK'"

smoke: build-test
	@echo "=== Running smoke test ==="
	$(RUN) /bin/bash -c "bash install && \
	  zsh -ic 'echo \"[OK] ZSH loaded\"' && \
	  tmux new-session -d -s smoke_test && tmux source ~/.tmux.conf && echo '[OK] TMUX loaded' && tmux kill-session && \
	  nvim --headless -c 'qa!' && echo '[OK] NVIM started' && \
	  echo '=== Smoke test passed! ==='"

clean:
	-podman rmi $(IMAGE_TEST) $(IMAGE_FULL) 2>/dev/null || true