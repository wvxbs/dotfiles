##############################
# GLOBAL ALIASES
##############################

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Desenvolvimento/tools/dotfiles}"

# Navigation and files
alias ls='eza -al --icons -I ".DS_Store"'
alias mkdir='mkdir -pv'
alias cat='bat'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'
alias ln='ln -i'

# Editor
alias vim='nvim'
alias svim='sudo nvim'

# Shell and dotfiles
alias src='source ~/.zshrc'
alias cfg='nvim ~/.zshrc'
alias aliases='nvim "$DOTFILES_DIR/aliases.zsh"'
alias bashtop='bpytop'

# Context configuration
CONTEXT_DEFAULT="wvxbs"
CONTEXTS=(wvxbs)

# Load custom PATH entries.
[[ -f "$DOTFILES_DIR/bin/path.zsh" ]] &&
  source "$DOTFILES_DIR/bin/path.zsh"

# Load context engine.
source "$DOTFILES_DIR/context.zsh"

# Load only declared contexts.
for _context in "${CONTEXTS[@]}"; do
  source "$DOTFILES_DIR/contexts/$_context.zsh"
done

# Initialize after all contexts have been registered.
_initialize_contexts

unset _context