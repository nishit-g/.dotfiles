if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZDOTDIR="$HOME"
export EDITOR="nvim"
export VISUAL="nvim"

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

command -v mise &>/dev/null && eval "$(mise activate zsh)"
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v zoxide &>/dev/null && { eval "$(zoxide init zsh)"; alias c='z'; }

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY

autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

if [[ -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
  source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
  zsh_plugins="$HOME/.zsh_plugins"
  if [[ ! "${zsh_plugins}.zsh" -nt "${zsh_plugins}.txt" ]]; then
    antidote bundle < "${zsh_plugins}.txt" > "${zsh_plugins}.zsh"
  fi
  source "${zsh_plugins}.zsh"
fi

alias ..='cd ..'
alias ...='cd ../..'
alias nv='nvim'

if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first'
  alias lt='eza -T -L 2'
fi

if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'
fi

alias help='tldr'

function y() {
  local tmp cwd
  tmp=$(mktemp -t "yazi-cwd.XXXXXX")
  yazi "$@" --cwd-file="$tmp"
  cwd=$(<"$tmp")
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

_fzf_path="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf/shell"
[[ -f "$_fzf_path/key-bindings.zsh" ]] && source "$_fzf_path/key-bindings.zsh"
[[ -f "$_fzf_path/completion.zsh" ]] && source "$_fzf_path/completion.zsh"
unset _fzf_path

alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias ga='git add .'
alias gc='git commit'
alias gp='git push'
alias lg='lazygit'

function sesh-sessions() {
  exec </dev/tty
  exec <&1
  local session
  session=$(sesh list -i | fzf --height 40% --reverse --border --prompt '⚡ ' \
    --header '  ^a all ^t tmux ^x zoxide ^d kill' \
    --bind 'ctrl-a:change-prompt(⚡ )+reload(sesh list -i)' \
    --bind 'ctrl-t:change-prompt(🪟 )+reload(sesh list -t)' \
    --bind 'ctrl-x:change-prompt(📁 )+reload(sesh list -z)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡ )+reload(sesh list -i)')
  [[ -z "$session" ]] && return
  sesh connect "$session"
}
zle -N sesh-sessions
bindkey '^f' sesh-sessions

setopt AUTO_CD CORRECT NO_BEEP

REPORTTIME=5
bindkey -e

[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

export PNPM_HOME="$HOME/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"
