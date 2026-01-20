if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZDOTDIR="$HOME"
export EDITOR="nvim"
export VISUAL="nvim"

typeset -gx HOMEBREW_PREFIX="/opt/homebrew"
typeset -gx HOMEBREW_CELLAR="/opt/homebrew/Cellar"
typeset -gx HOMEBREW_REPOSITORY="/opt/homebrew"
path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" "$HOME/bin" "$HOME/.local/bin" $path)
export PATH

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" 2>/dev/null
fi
source "$ZINIT_HOME/zinit.zsh"

zinit ice depth=1
zinit light romkatv/powerlevel10k

zinit wait lucid for \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting

zinit wait"1" lucid for \
  OMZP::git \
  OMZP::command-not-found

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY
setopt AUTO_CD CORRECT NO_BEEP

zinit wait"0" lucid for \
  atload'eval "$(mise activate zsh --shims)"' \
    zdharma-continuum/null \
  atload'eval "$(direnv hook zsh)"' \
    zdharma-continuum/null \
  atload'eval "$(atuin init zsh --disable-up-arrow)"' \
    zdharma-continuum/null \
  atload'eval "$(zoxide init zsh)"; alias c="z"' \
    zdharma-continuum/null

alias ..='cd ..'
alias ...='cd ../..'
alias nv='nvim'

alias ls='eza --group-directories-first'
alias ll='eza -lah --group-directories-first'
alias lt='eza -T -L 2'

alias cat='bat --paging=never'
alias catp='bat'

alias help='tldr'

alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias ga='git add .'
alias gc='git commit'
alias gp='git push'
alias lg='lazygit'

function y() {
  local tmp cwd
  tmp=$(mktemp -t "yazi-cwd.XXXXXX")
  yazi "$@" --cwd-file="$tmp"
  cwd=$(<"$tmp")
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

function sesh-sessions() {
  {
    local session
    session=$(sesh list -i | fzf --ansi --no-sort --border --prompt '⚡ ' \
      --header '  ^a all ^t tmux ^x zoxide ^d kill' \
      --bind 'ctrl-a:change-prompt(⚡ )+reload(sesh list -i)' \
      --bind 'ctrl-t:change-prompt(🪟 )+reload(sesh list -t)' \
      --bind 'ctrl-x:change-prompt(📁 )+reload(sesh list -z)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡ )+reload(sesh list -i)')
    if [[ -n "$session" ]]; then
      if [[ -n "$TMUX" ]]; then
        sesh connect --switch "$session"
      else
        sesh connect "$session"
      fi
    fi
  } </dev/tty
  zle reset-prompt
}
zle -N sesh-sessions
bindkey '^f' sesh-sessions

bindkey -e
REPORTTIME=5

[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

export PNPM_HOME="$HOME/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && path+=("$PNPM_HOME")
