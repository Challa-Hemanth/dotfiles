# ─────────────────────────────────────────────
# Startup timer
# ─────────────────────────────────────────────
timezsh() { time zsh -i -c exit }

# ─────────────────────────────────────────────
# Homebrew (Intel Mac)
# Only eval if not already set (avoids double-init on login shells)
# ─────────────────────────────────────────────
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ─────────────────────────────────────────────
# ZSH Options
# ─────────────────────────────────────────────
setopt AUTO_CD
setopt CORRECT
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# ─────────────────────────────────────────────
# Completions (compiled bytecode cache)
# Only rebuild dump if older than 20 hours
# ─────────────────────────────────────────────
FPATH="/usr/local/share/zsh-completions:$FPATH"
mkdir -p ~/.zsh/cache
autoload -Uz compinit
compinit -C -d ~/.zcompdump
# Recompile dump in background only when stale — never blocks startup
[[ ! ~/.zcompdump.zwc -nt ~/.zcompdump ]] && zcompile ~/.zcompdump &!

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ─────────────────────────────────────────────
# Plugins
# ─────────────────────────────────────────────
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true

ZSH_HIGHLIGHT_MAXLENGTH=512
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#14b8a6,bold'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#14b8a6,bold'

# History substring search — type prefix, ↑/↓ cycles matching history
# Must load after syntax-highlighting
[[ -f /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && {
  source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}


# ─────────────────────────────────────────────
# FZF (cached init — skips subprocess on every shell start)
# ─────────────────────────────────────────────
_fzf_cache="$HOME/.zsh/cache/fzf_init.zsh"
if [[ ! -s "$_fzf_cache" || "${commands[fzf]}" -nt "$_fzf_cache" ]]; then
  fzf --zsh >| "$_fzf_cache"
fi
source "$_fzf_cache"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border
  --color=bg+:#1a0a2e,bg:#000000,spinner:#d946ef,hl:#8b5cf6
  --color=fg:#e2e8f0,header:#d946ef,info:#6366f1,pointer:#f59e0b
  --color=marker:#10b981,fg+:#f8fafc,prompt:#a78bfa,hl+:#e879f9'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# ─────────────────────────────────────────────
# Environment
# ─────────────────────────────────────────────
export EDITOR='code --wait'
export VISUAL='code --wait'
export LESS='-R'
export MANPAGER='sh -c "col -bx | bat -l man -p"'
export MANROFFOPT='-c'

# ─────────────────────────────────────────────
# Modern tool aliases (interactive shells only)
# Guarded to prevent breakage in scripts that source this file
# ─────────────────────────────────────────────
if [[ $- == *i* ]]; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza --tree --icons --level=2'
  alias llt='eza --tree --icons --level=3'

  alias cat='bat --style=auto --paging=never'
  alias catp='bat --style=full'
  alias catr='command cat'

  alias find='fd'
  alias findr='command find'

  alias grep='rg'
  alias grepr='command grep'

  alias cd='z'
  alias cdi='zi'
  alias cdr='command cd'
fi

# ─────────────────────────────────────────────
# Git aliases
# ─────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gst='git stash'
alias gstp='git stash pop'
alias grb='git rebase'
alias grs='git restore'
alias grss='git restore --staged'
alias lg='lazygit'

# ─────────────────────────────────────────────
# Dev aliases
# ─────────────────────────────────────────────
alias py='python3'
alias serve='python3 -m http.server'
alias uvrun='uv run'
alias uvadd='uv add'
alias uvsync='uv sync'
alias myip='curl ifconfig.me'
alias help='tldr'
alias df='dust'
alias top='btm'
alias reload='source ~/.zshrc'
alias zshconfig='open -e ~/.zshrc'
alias starshipconfig='open -e ~/.config/starship.toml'
alias brewup='brew update && brew upgrade --greedy && brew cleanup && rm -f ~/.zsh/cache/*_init.zsh'
alias pubkey='cat ~/.ssh/id_ed25519.pub | pbcopy && echo "SSH key copied to clipboard"'

# ─────────────────────────────────────────────
# Directory shortcuts
# ─────────────────────────────────────────────
alias ..='cdr ..'
alias ...='cdr ../..'
alias ....='cdr ../../..'
alias ~='cdr ~'
alias dl='cdr ~/Downloads'
alias dt='cdr ~/Desktop'
alias dev='cdr ~/Developer'

# ─────────────────────────────────────────────
# uv — Python version + package management
# ─────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# Cached uv completions
_uv_cache="$HOME/.zsh/cache/uv_init.zsh"
if [[ ! -s "$_uv_cache" || "${commands[uv]}" -nt "$_uv_cache" ]]; then
  uv generate-shell-completion zsh >| "$_uv_cache"
fi
source "$_uv_cache"

# Default venv — always-available libs for quick scripting
# Project venvs (uv init) override this automatically
export VIRTUAL_ENV_DISABLE_PROMPT=1
[[ -f "$HOME/.venv/bin/activate" ]] && source "$HOME/.venv/bin/activate"

# ─────────────────────────────────────────────
# fnm — fast Node version manager (replaces nvm)
# ─────────────────────────────────────────────
_fnm_cache="$HOME/.zsh/cache/fnm_init.zsh"
if [[ ! -s "$_fnm_cache" || "${commands[fnm]}" -nt "$_fnm_cache" ]]; then
  fnm env --use-on-cd --shell zsh >| "$_fnm_cache"
fi
source "$_fnm_cache"

# ─────────────────────────────────────────────
# AWS
# ─────────────────────────────────────────────
export AWS_CLI_AUTO_PROMPT=on-partial
alias awswho='aws sts get-caller-identity'
alias awsprofiles='cat ~/.aws/credentials | grep "\["'

# ─────────────────────────────────────────────
# direnv — per-project .env auto-loading
# ─────────────────────────────────────────────
_direnv_cache="$HOME/.zsh/cache/direnv_init.zsh"
if [[ ! -s "$_direnv_cache" || "${commands[direnv]}" -nt "$_direnv_cache" ]]; then
  direnv hook zsh >| "$_direnv_cache"
fi
source "$_direnv_cache"

# gh — GitHub CLI completions
_gh_cache="$HOME/.zsh/cache/gh_completions.zsh"
if [[ ! -s "$_gh_cache" || "${commands[gh]}" -nt "$_gh_cache" ]]; then
  gh completion -s zsh >| "$_gh_cache"
fi
source "$_gh_cache"

# ─────────────────────────────────────────────
# Zoxide (cached init)
# ─────────────────────────────────────────────
_zoxide_cache="$HOME/.zsh/cache/zoxide_init.zsh"
if [[ ! -s "$_zoxide_cache" || "${commands[zoxide]}" -nt "$_zoxide_cache" ]]; then
  zoxide init zsh --cmd z >| "$_zoxide_cache"
fi
source "$_zoxide_cache"

# ─────────────────────────────────────────────
# Starship (cached init — always last)
# ─────────────────────────────────────────────
_starship_cache="$HOME/.zsh/cache/starship_init.zsh"
if [[ ! -s "$_starship_cache" || "${commands[starship]}" -nt "$_starship_cache" ]]; then
  starship init zsh >| "$_starship_cache"
fi
source "$_starship_cache"

