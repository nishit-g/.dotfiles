.PHONY: install update link brew apps macos clean help

DOTFILES := $(shell pwd)
STOW_DIRS := nvim zsh tmux alacritty git sesh atuin yazi bat mise aerospace karabiner dev bin ssh opencode vibe-kanban

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install   Full installation (brew + apps + link + macos)"
	@echo "  update    Update dotfiles and reinstall"
	@echo "  link      Symlink configs with stow"
	@echo "  unlink    Remove symlinks"
	@echo "  brew      Install Homebrew formulae"
	@echo "  apps      Install GUI applications"
	@echo "  macos     Apply macOS defaults"
	@echo "  clean     Remove generated files"

install: brew apps link macos zinit
	@echo "✔ Installation complete"

update:
	@git pull --rebase origin v2
	@$(MAKE) install

brew:
	@./bootstrap.sh brew

apps:
	@./bootstrap.sh apps

link:
	@mkdir -p $(HOME)/.config $(HOME)/bin
	@for dir in $(STOW_DIRS); do \
		if [ "$$dir" = "vibe-kanban" ]; then continue; fi; \
		if [ -d "$$dir" ]; then \
			stow --dir=$(DOTFILES) --target=$(HOME) --restow $$dir 2>/dev/null || true; \
		fi \
	done
	@./scripts/link-vibe-kanban.sh
	@echo "✔ Configs linked"

unlink:
	@for dir in $(STOW_DIRS); do \
		if [ -d "$$dir" ]; then \
			stow --dir=$(DOTFILES) --target=$(HOME) --delete $$dir 2>/dev/null || true; \
		fi \
	done
	@echo "✔ Configs unlinked"

macos:
	@bash scripts/macos.sh

zinit:
	@if [ ! -d "$(HOME)/.local/share/zinit/zinit.git" ]; then \
		mkdir -p $(HOME)/.local/share/zinit; \
		git clone https://github.com/zdharma-continuum/zinit.git $(HOME)/.local/share/zinit/zinit.git; \
		echo "✔ zinit installed"; \
	fi

clean:
	@rm -rf $(HOME)/.zcompdump* $(HOME)/.zsh_history.lock
	@echo "✔ Cleaned"
