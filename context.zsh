##############################
# CONTEXT ENGINE
##############################

# Context registry
typeset -gA CONTEXT_HOME
typeset -gA CONTEXT_DEVELOPMENT_DIR
typeset -gA CONTEXT_GITHUB_USER
typeset -gA CONTEXT_CODE_PROFILE
typeset -gA CONTEXT_DOCKER_CONTEXT

CONTEXT_HOME=()
CONTEXT_DEVELOPMENT_DIR=()
CONTEXT_GITHUB_USER=()
CONTEXT_CODE_PROFILE=()
CONTEXT_DOCKER_CONTEXT=()

typeset -gi _CONTEXT_COUNT=0
typeset -g _CONTEXT_DEFAULT="${CONTEXT_DEFAULT:-personal}"
typeset -g _LAST_CONTEXT=""

# register_context NAME HOME [GITHUB_USER] [CODE_PROFILE] [DOCKER_CONTEXT] [DEVELOPMENT_DIR]
register_context() {
  local name="$1"
  local home="$2"
  local github_user="${3:-}"
  local code_profile="${4:-}"
  local docker_context="${5:-}"
  local development_dir="${6:-}"

  if [[ -z "$name" || -z "$home" ]]; then
    print -u2 -r -- "register_context: name and home are required"
    return 1
  fi

  home="${home:A}"

  # Default development directory is HOME/Desenvolvimento.
  if [[ -z "$development_dir" ]]; then
    development_dir="$home/Desenvolvimento"
  elif [[ "$development_dir" != /* ]]; then
    development_dir="$home/$development_dir"
  fi

  CONTEXT_HOME[$name]="$home"
  CONTEXT_GITHUB_USER[$name]="$github_user"
  CONTEXT_CODE_PROFILE[$name]="$code_profile"
  CONTEXT_DOCKER_CONTEXT[$name]="$docker_context"
  CONTEXT_DEVELOPMENT_DIR[$name]="${development_dir:A}"
}

# Resolve the most specific matching context.
_current_context() {
  local current="$PWD"
  local context context_home
  local best_context="$_CONTEXT_DEFAULT"
  local best_length=0

  for context in "${(@k)CONTEXT_HOME}"; do
    context_home="${CONTEXT_HOME[$context]}"

    if [[ "$current/" == "$context_home/"* ]] &&
       (( ${#context_home} > best_length )); then
      best_context="$context"
      best_length=${#context_home}
    fi
  done

  print -r -- "$best_context"
}

_current_context_home() {
  local context="${1:-$(_current_context)}"
  print -r -- "${CONTEXT_HOME[$context]}"
}

# Navigation
context() {
  local target="${1:-$_CONTEXT_DEFAULT}"
  local home="${CONTEXT_HOME[$target]}"

  if [[ -z "$home" ]]; then
    print -u2 -r -- "Unknown context: $target"
    return 1
  fi

  builtin cd -- "$home"
}

repos() {
  local context="$(_current_context)"
  local directory="${CONTEXT_DEVELOPMENT_DIR[$context]}/repos"

  [[ -n "$CONTEXT_DEVELOPMENT_DIR[$context]" ]] || return 1
  builtin cd -- "$directory"
}

tools() {
  local context="$(_current_context)"
  local directory="${CONTEXT_DEVELOPMENT_DIR[$context]}/tools"

  [[ -n "$CONTEXT_DEVELOPMENT_DIR[$context]" ]] || return 1
  builtin cd -- "$directory"
}

# GitHub identity
_github_active_user() {
  command gh auth status \
    --active \
    --hostname github.com \
    --json hosts \
    --jq '.hosts.github.com[0].login' 2>/dev/null
}

_github_expected_user() {
  local context="$1"
  local user="${CONTEXT_GITHUB_USER[$context]}"

  # Unconfigured contexts inherit the default identity.
  if [[ -z "$user" && "$context" != "$_CONTEXT_DEFAULT" ]]; then
    user="${CONTEXT_GITHUB_USER[$_CONTEXT_DEFAULT]}"
  fi

  print -r -- "$user"
}

_sync_github_context() {
  local context="$1"
  local expected_user
  local active_user

  expected_user="$(_github_expected_user "$context")"
  [[ -n "$expected_user" ]] || return 0

  active_user="$(_github_active_user)"
  [[ "$active_user" == "$expected_user" ]] && return 0

  command gh auth switch \
    --hostname github.com \
    --user "$expected_user" >/dev/null 2>&1
}

# Docker identity
typeset -gi _DOCKER_CONTEXT_MANAGEMENT=0
typeset -gi _DOCKER_HOME_CONTEXT_SET=0
typeset -g _DOCKER_HOME_CONTEXT=""

_initialize_docker_contexts() {
  local context

  # Only non-default contexts can activate Docker management.
  for context in "${(@k)CONTEXT_DOCKER_CONTEXT}"; do
    [[ "$context" == "$_CONTEXT_DEFAULT" ]] && continue

    if [[ -n "${CONTEXT_DOCKER_CONTEXT[$context]}" ]]; then
      _DOCKER_CONTEXT_MANAGEMENT=1
      break
    fi
  done

  (( _DOCKER_CONTEXT_MANAGEMENT )) || return 0

  # Preserve the original Docker environment.
  if (( ${+DOCKER_CONTEXT} )); then
    _DOCKER_HOME_CONTEXT_SET=1
    _DOCKER_HOME_CONTEXT="$DOCKER_CONTEXT"
  fi
}

_sync_docker_context() {
  (( _DOCKER_CONTEXT_MANAGEMENT )) || return 0

  local context="$1"
  local docker_context="${CONTEXT_DOCKER_CONTEXT[$context]}"

  if [[ -n "$docker_context" ]]; then
    export DOCKER_CONTEXT="$docker_context"
  elif (( _DOCKER_HOME_CONTEXT_SET )); then
    export DOCKER_CONTEXT="$_DOCKER_HOME_CONTEXT"
  else
    unset DOCKER_CONTEXT
  fi
}

# VS Code profile
code() {
  local context="$(_current_context)"
  local profile="${CONTEXT_CODE_PROFILE[$context]}"

  if [[ -n "$profile" ]]; then
    command code --profile "$profile" "$@"
  else
    command code "$@"
  fi
}

# Apply integrations only when the context changes.
_apply_context() {
  local context="$1"

  _sync_github_context "$context"
  _sync_docker_context "$context"
}

_sync_context_on_directory_change() {
  (( _CONTEXT_COUNT > 1 )) || return 0
  local context="$(_current_context)"

  [[ "$context" == "$_LAST_CONTEXT" ]] && return 0

  _LAST_CONTEXT="$context"
  _apply_context "$context"
}

# Initialize after every declared context has been loaded.
_initialize_contexts() {
  _CONTEXT_COUNT=${#CONTEXT_HOME}

  # A single context needs no automatic switching.
  (( _CONTEXT_COUNT > 1 )) || return 0

  _initialize_docker_contexts

  local context="$(_current_context)"
  _LAST_CONTEXT="$context"

  # Do not query integrations when starting in the default context.
  if [[ "$context" != "$_CONTEXT_DEFAULT" ]]; then
    _apply_context "$context"
  fi

  autoload -Uz add-zsh-hook
  add-zsh-hook -d chpwd _sync_context_on_directory_change 2>/dev/null
  add-zsh-hook chpwd _sync_context_on_directory_change
}

# Explicit personal GitHub switching.
ghp() {
  local user="${CONTEXT_GITHUB_USER[$_CONTEXT_DEFAULT]}"

  if [[ -z "$user" ]]; then
    print -u2 -r -- "Default GitHub account is not configured"
    return 1
  fi

  command gh auth switch \
    --hostname github.com \
    --user "$user"
}

# Diagnostics
github-status() {
  local context expected active local_user remote

  context="$(_current_context)"
  expected="$(_github_expected_user "$context")"
  active="$(_github_active_user)"

  print -r -- "Context:         $context"
  print -r -- "Expected GitHub: ${expected:-not configured}"
  print -r -- "Active GitHub:   ${active:-not available}"

  if [[ -n "$expected" && "$active" != "$expected" ]]; then
    print -u2 -r -- "Warning: active GitHub account does not match this context"
  fi

  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local_user="$(command git config --local user.name)"
    remote="$(command git remote get-url origin 2>/dev/null)"

    print -r -- "Git user:        ${local_user:-not configured}"
    print -r -- "Git origin:      ${remote:-not configured}"
  else
    print -r -- "Git repository:  none"
  fi
}

whoami() {
  print -r -- "System user: $(command whoami)"
  print -r -- "Context:     $(_current_context)"

  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print -r -- "Git identity: $(command git config --local user.name) <$(command git config --local user.email)>"
  fi
}

alias ghs='github-status'

##############################
# CHEAT SHEET
##############################
#
# Contexts:
#   context             Go to the default context
#   context NAME        Go to a named context
#
# Navigation:
#   repos               Go to current context's repos directory
#   tools               Go to current context's tools directory
#
# Identity:
#   whoami              Show system user and context
#   github-status       Show GitHub and Git status
#
# Editors:
#   code                Open VS Code with context profile
#
# Registration:
#   register_context [NAME] [HOME] [GITHUB_USER] [CODE_PROFILE] [DOCKER_CONTEXT] [DEVELOPMENT_DIR]
#
##############################