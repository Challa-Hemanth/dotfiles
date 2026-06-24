
eval "$(/usr/local/bin/brew shellenv zsh)"

# SSH agent — start once per login session, load key into Keychain
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s)" > /dev/null 2>&1
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null || true
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
