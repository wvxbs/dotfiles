#!/usr/bin/env bash

set -Eeuo pipefail

# --------------------------------------------------
# Configuration
# --------------------------------------------------

BUILD_DIR="${YAY_BUILD_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/yay-build}"
YAY_REPO="https://aur.archlinux.org/yay.git"

# --------------------------------------------------
# Validation
# --------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    echo "Erro: não execute este script como root."
    echo "Execute como seu usuário normal."
    exit 1
fi

if [[ ! -f /etc/arch-release ]]; then
    echo "Erro: este script é destinado ao Arch Linux."
    exit 1
fi

for cmd in sudo git makepkg; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Erro: dependência ausente: $cmd"
        exit 1
    fi
done

# --------------------------------------------------
# Existing installation
# --------------------------------------------------

if command -v yay >/dev/null 2>&1; then
    echo "yay já está instalado."
    yay --version
    exit 0
fi

# --------------------------------------------------
# System dependencies
# --------------------------------------------------

echo "Atualizando sistema e instalando dependências..."

sudo pacman -Syu --needed base-devel git go

# --------------------------------------------------
# Build directory
# --------------------------------------------------

mkdir -p "$(dirname "$BUILD_DIR")"

if [[ -d "$BUILD_DIR/.git" ]]; then
    echo "Repositório yay encontrado. Atualizando..."

    REMOTE="$(git -C "$BUILD_DIR" remote get-url origin)"

    if [[ "$REMOTE" != "$YAY_REPO" ]]; then
        echo "Erro: diretório de build contém outro repositório."
        exit 1
    fi

    git -C "$BUILD_DIR" pull --ff-only

elif [[ -e "$BUILD_DIR" ]]; then
    echo "Erro: diretório de build já existe e não é um repositório Git."
    echo "Diretório: $BUILD_DIR"
    exit 1

else
    echo "Clonando yay..."

    git clone "$YAY_REPO" "$BUILD_DIR"
fi

# --------------------------------------------------
# Build and installation
# --------------------------------------------------

cd "$BUILD_DIR"

echo "Compilando e instalando yay..."

makepkg -si

# --------------------------------------------------
# Finish
# --------------------------------------------------

echo
echo "yay instalado com sucesso!"
yay --version