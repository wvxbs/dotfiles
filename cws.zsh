# Contextos pessoal e CWS para Git, GitHub CLI e Docker.
#
# O gh guarda as duas contas no keyring e a troca é explícita. Não usamos um
# GH_CONFIG_DIR separado para manter o gh e o Git na mesma conta ativa.
export CWS_HOME="${CWS_HOME:-$HOME/Documents/Trabalho/cws}"
export PATH="$HOME/Documents/tools/dotfiles/bin:$PATH"

typeset -g GITHUB_PERSONAL_USER="wvxbs"
typeset -g GITHUB_WORK_USER="gabriel-ferreira-cws"

_github_active_user() {
  command gh auth status \
    --active \
    --hostname github.com \
    --json hosts \
    --jq '.hosts["github.com"][0].login' 2>/dev/null
}

_github_expected_user() {
  case "$PWD/" in
    "$CWS_HOME"/*) print -r -- "$GITHUB_WORK_USER" ;;
    *)             print -r -- "$GITHUB_PERSONAL_USER" ;;
  esac
}

_sync_github_context() {
  local active_user expected_user

  active_user="$(_github_active_user)"
  expected_user="$(_github_expected_user)"

  if [[ -n "$expected_user" && "$active_user" != "$expected_user" ]]; then
    command gh auth switch \
      --hostname github.com \
      --user "$expected_user" >/dev/null 2>&1
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook -d chpwd _sync_github_context 2>/dev/null
add-zsh-hook chpwd _sync_github_context
_sync_github_context

# Mantém configurações e credenciais do Docker isoladas por contexto. O helper
# CWS adiciona um namespace ao registro antes de delegar ao Keychain do macOS,
# permitindo que as duas contas do Docker Hub coexistam com segurança.
docker() {
  local config_dir="$HOME/.docker"
  local docker_cli

  if [[ "$(uname -s)" == "Darwin" && "$PWD/" == "$CWS_HOME/"* ]]; then
    config_dir="$CWS_HOME/.docker"
  fi

  docker_cli="$(whence -p docker 2>/dev/null)"
  if [[ -z "$docker_cli" ]]; then
    docker_cli="/Applications/Docker.app/Contents/Resources/bin/docker"
  fi

  if [[ ! -x "$docker_cli" ]]; then
    print -u2 -r -- "docker: CLI não encontrado"
    return 127
  fi

  DOCKER_CONFIG="$config_dir" command "$docker_cli" "$@"
}

github-status() {
  local active_user expected_user git_name git_email remote repo_root

  active_user="$(_github_active_user)"
  expected_user="$(_github_expected_user)"

  if [[ -z "$active_user" ]]; then
    active_user="indisponível"
  fi

  if repo_root="$(command git rev-parse --show-toplevel 2>/dev/null)"; then
    git_name="$(command git config user.name 2>/dev/null)"
    git_email="$(command git config user.email 2>/dev/null)"
    remote="$(command git remote get-url origin 2>/dev/null)"
    [[ -z "$remote" ]] && remote="sem origin"
  else
    repo_root="fora de um repositório Git"
    git_name="$(command git config --global user.name 2>/dev/null)"
    git_email="$(command git config --global user.email 2>/dev/null)"
    remote="n/a"
  fi

  print -r -- "GitHub CLI : $active_user"
  print -r -- "Esperado   : $expected_user"
  print -r -- "Autor Git  : $git_name <$git_email>"
  print -r -- "Repositório: $repo_root"
  print -r -- "Remote     : $remote"

  if [[ "$active_user" != "$expected_user" ]]; then
    print -u2 -r -- "AVISO: a conta ativa não corresponde ao contexto desta pasta."
  fi

  return 0
}
