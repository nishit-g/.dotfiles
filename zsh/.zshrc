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

# ---------- History ----------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# ---------- Completion ----------
autoload -Uz compinit
# cached compinit for faster startup
if [[ ! -f "$HOME/.zcompdump" || "$HOME/.zcompdump" -ot "$ZDOTDIR/.zshrc" ]]; then
  compinit
else
  compinit -C
fi

# ---------- Antidote (plugins via bundle) ----------
if [[ -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
  source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
  if [[ -f "$HOME/.zsh_plugins.txt" ]]; then
    antidote bundle < "$HOME/.zsh_plugins.txt" > "$HOME/.zsh_plugins.zsh"
    source "$HOME/.zsh_plugins.zsh"
  fi
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

# ---------- fzf / skim integration ----------
if command -v sk >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if [[ -d "$(brew --prefix 2>/dev/null)/opt/fzf" ]]; then
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
fi

# ---------- git shortcuts ----------
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias ga='git add .'
alias gc='git commit'
alias gp='git push'
alias lg='lazygit'

# ---------- QoL options ----------
setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP

# Show time for commands that run longer than N seconds
REPORTTIME=5

# ---------- Keybindings ----------
# Accept autosuggestion with Ctrl-;
if typeset -f autosuggest-accept >/dev/null 2>&1; then
  bindkey '^;' autosuggest-accept
fi

# Use emacs-style keys by default (good in terminals)
bindkey -e

# ---------- Prompt – simple and fast ----------
PROMPT='%F{cyan}%n%f@%F{magenta}%m%f %F{yellow}%~%f %# '

# ---------- Local overrides ----------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

