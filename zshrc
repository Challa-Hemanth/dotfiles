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

ZSH_HIGHLIGHT_MAXLENGTH=60
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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
alias pip='pip3'
alias serve='python3 -m http.server'
alias myip='curl ifconfig.me'
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
# LAZY LOAD: pyenv
# ─────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
pyenv() {
  unfunction pyenv
  eval "$(command pyenv init -)"
  eval "$(command pyenv virtualenv-init -)" 2>/dev/null
  pyenv "$@"
}
python3() {
  unfunction python3
  eval "$(command pyenv init -)"
  python3 "$@"
}
pip3() {
  unfunction pip3
  eval "$(command pyenv init -)"
  pip3 "$@"
}

# ─────────────────────────────────────────────
# LAZY LOAD: rbenv
# ─────────────────────────────────────────────
export PATH="$HOME/.rbenv/bin:$PATH"
rbenv() {
  unfunction rbenv
  eval "$(command rbenv init -)"
  rbenv "$@"
}
ruby() {
  unfunction ruby
  eval "$(command rbenv init -)"
  ruby "$@"
}
gem() {
  unfunction gem
  eval "$(command rbenv init -)"
  gem "$@"
}
bundle() {
  unfunction bundle
  eval "$(command rbenv init -)"
  bundle "$@"
}

# ─────────────────────────────────────────────
# LAZY LOAD: nvm
# ─────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && source "/usr/local/opt/nvm/nvm.sh"
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
}
nvm() { unfunction nvm; _load_nvm; nvm "$@" }
node() { unfunction node; _load_nvm; node "$@" }
npm() { unfunction npm; _load_nvm; npm "$@" }
npx() { unfunction npx; _load_nvm; npx "$@" }
yarn() { unfunction yarn; _load_nvm; yarn "$@" }

# ─────────────────────────────────────────────
# LAZY LOAD: jenv
# ─────────────────────────────────────────────
export PATH="$HOME/.jenv/bin:$PATH"
_load_jenv() {
  eval "$(command jenv init -)"
}
jenv() { unfunction jenv; _load_jenv; jenv "$@" }
java() { unfunction java; _load_jenv; java "$@" }
javac() { unfunction javac; _load_jenv; javac "$@" }
mvn() { unfunction mvn; _load_jenv; mvn "$@" }
gradle() { unfunction gradle; _load_jenv; gradle "$@" }

# ─────────────────────────────────────────────
# AWS
# ─────────────────────────────────────────────
export AWS_CLI_AUTO_PROMPT=on-partial
alias awswho='aws sts get-caller-identity'
alias awsprofiles='cat ~/.aws/credentials | grep "\["'

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

