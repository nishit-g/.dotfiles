# ---------- Core ----------
export ZDOTDIR="$HOME"
export EDITOR="nvim"
export VISUAL="nvim"

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# PATH tweaks
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# ---------- Antidote (plugins via bundle) ----------
if [[ -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
  source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
  antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh
  source ~/.zsh_plugins.zsh
fi

# ---------- zoxide (better cd) ----------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias c='z'
fi

alias ..='cd ..'
alias ...='cd ../..'

# ---------- modern ls (eza) ----------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first'
  alias lt='eza -T -L 2'
fi

# ---------- nnn / broot ----------
alias fm='nnn'
alias br='broot'

# ---------- fzf / skim bindings ----------
if [[ -d "$(brew --prefix 2>/dev/null)/opt/fzf" ]]; then
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
fi

if command -v sk >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# ---------- git shortcuts ----------
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias ga='git add .'
alias gc='git commit'
alias gp='git push'
alias lg='lazygit'

# ---------- quality of life ----------
setopt auto_cd
setopt correct
setopt hist_ignore_dups
setopt share_history

# Prompt – simple and fast
PROMPT='%F{cyan}%n%f@%F{magenta}%m%f %F{yellow}%~%f %# '

# ---------- Local overrides ----------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
