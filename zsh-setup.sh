set -euo pipefail

# --------------------------------------------------
# Configuration
# --------------------------------------------------

DEV_DIR="${DEV_DIR:-$HOME/Desenvolvimento}"
DOTFILES_DIR="${DOTFILES_DIR:-$DEV_DIR/tools/dotfiles}"

ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"

P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"

ZSHRC="$HOME/.zshrc"

# --------------------------------------------------
# Dependencies
# --------------------------------------------------

if ! command -v zsh >/dev/null 2>&1; then
    echo "Erro: Zsh não está instalado."
    exit 1
fi

for cmd in git curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Erro: dependência ausente: $cmd"
        exit 1
    fi
done

ZSH_BIN="$(command -v zsh)"

echo "Configurando Zsh..."
echo "Home:       $HOME"
echo "Dev:        $DEV_DIR"
echo "Dotfiles:   $DOTFILES_DIR"

# --------------------------------------------------
# Default shell
# --------------------------------------------------

ZSH_BIN="$(command -v zsh)"

if [[ ! -x "$ZSH_BIN" ]]; then
    echo "Erro: executável do Zsh inválido: $ZSH_BIN"
    exit 1
fi

# Reuse an existing /etc/shells entry pointing to
# the same executable, including symlinks.
REGISTERED_ZSH=""

if [[ -r /etc/shells ]]; then
    while IFS= read -r shell; do
        [[ -x "$shell" ]] || continue

        if [[ "$shell" -ef "$ZSH_BIN" ]]; then
            REGISTERED_ZSH="$shell"
            break
        fi
    done < /etc/shells
fi

if [[ -n "$REGISTERED_ZSH" ]]; then
    ZSH_BIN="$REGISTERED_ZSH"
else
    echo "Registrando $ZSH_BIN em /etc/shells..."

    printf '%s\n' "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
fi

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" != "$ZSH_BIN" ]]; then
    echo "Alterando shell padrão para $ZSH_BIN..."
    chsh -s "$ZSH_BIN"
else
    echo "Zsh já é o shell padrão."
fi


# --------------------------------------------------
# Oh My Zsh
# --------------------------------------------------

if [[ ! -d "$ZSH_DIR" ]]; then
    echo "Instalando Oh My Zsh..."

    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh já instalado."
fi

mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"

# --------------------------------------------------
# Powerlevel10k
# --------------------------------------------------

if [[ ! -d "$P10K_DIR" ]]; then
    echo "Instalando Powerlevel10k..."

    git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "$P10K_DIR"
else
    echo "Powerlevel10k já instalado."
fi

# --------------------------------------------------
# Plugins
# --------------------------------------------------

if [[ ! -d "$AUTOSUGGESTIONS_DIR" ]]; then
    echo "Instalando zsh-autosuggestions..."

    git clone --depth=1 \
        https://github.com/zsh-users/zsh-autosuggestions \
        "$AUTOSUGGESTIONS_DIR"
else
    echo "zsh-autosuggestions já instalado."
fi

# --------------------------------------------------
# Zsh configuration
# --------------------------------------------------

if [[ -f "$ZSHRC" && ! -f "$ZSHRC.pre-setup-backup" ]]; then
    cp "$ZSHRC" "$ZSHRC.pre-setup-backup"
fi

echo "Gerando $ZSHRC..."

cat > "$ZSHRC" <<EOF
# --------------------------------------------------
# Powerlevel10k instant prompt
# --------------------------------------------------

if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
    source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi

# --------------------------------------------------
# Oh My Zsh
# --------------------------------------------------

export ZSH="\$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    sudo
    zsh-autosuggestions
)

source "\$ZSH/oh-my-zsh.sh"

# --------------------------------------------------
# Personal dotfiles
# --------------------------------------------------

if [[ -r "$DOTFILES_DIR/aliases.zsh" ]]; then
    source "$DOTFILES_DIR/aliases.zsh"
fi

# --------------------------------------------------
# Powerlevel10k configuration
# --------------------------------------------------

[[ -r "\$HOME/.p10k.zsh" ]] && source "\$HOME/.p10k.zsh"
EOF

# --------------------------------------------------
# Finish
# --------------------------------------------------

echo
echo "Zsh configurado com sucesso!"
echo
echo "Próximos passos:"
echo "  1. Execute: exec zsh"
echo "  2. Execute: p10k configure"
echo
