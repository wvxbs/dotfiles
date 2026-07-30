#!/bin/zsh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}                  Mac Cleaner                   ${NC}"
echo -e "${CYAN}================================================${NC}"
echo -e "Lendo seus aplicativos para criar a whitelist...\n"

typeset -A WHITELIST

# ==========================================
# 1. WHITELIST FIXA (Sistema e Dev)
# ==========================================
WHITELIST[apple]=1; WHITELIST[com.apple]=1; WHITELIST[macos]=1
WHITELIST[store]=1; WHITELIST[safari]=1; WHITELIST[siri]=1
WHITELIST[icloud]=1; WHITELIST[xcode]=1

WHITELIST[addressbook]=1; WHITELIST[animoji]=1; WHITELIST[callhistorydb]=1
WHITELIST[callhistorytransactions]=1; WHITELIST[facetime]=1; WHITELIST[clouddocs]=1
WHITELIST[cloudkit]=1; WHITELIST[familycircle]=1; WHITELIST[familycircled]=1
WHITELIST[passkit]=1; WHITELIST[crashreporter]=1; WHITELIST[differentialprivacy]=1
WHITELIST[knowledge]=1; WHITELIST[networkserviceproxy]=1; WHITELIST[askpermissiond]=1
WHITELIST[homeenergyd]=1; WHITELIST[icdd]=1; WHITELIST[instruments]=1
WHITELIST[gamekit]=1; WHITELIST[geoservices]=1; WHITELIST[byhost]=1
WHITELIST[diagnostics_agent]=1; WHITELIST[loginwindow]=1; WHITELIST[mobilemeaccounts]=1
WHITELIST[no_backup]=1; WHITELIST[pbs]=1; WHITELIST[sharedfilelistd]=1
WHITELIST[tokenbucketratelimiter]=1; WHITELIST[fileprovider]=1

WHITELIST[code]=1; WHITELIST[codex]=1; WHITELIST[go]=1; WHITELIST[go-build]=1
WHITELIST[pypoetry]=1; WHITELIST[conda]=1; WHITELIST[conda-anaconda-tos]=1
WHITELIST[virtualenv]=1; WHITELIST[node-gyp]=1; WHITELIST[ms-playwright-go]=1
WHITELIST[gitkrakencli]=1; WHITELIST[gk]=1; WHITELIST[sentry]=1

# Ferramentas de Terminal e Telemetria Conhecida
WHITELIST[homebrew]=1; WHITELIST[io.branch]=1

# ==========================================
# 2. WHITELIST DINÂMICA (Seus Apps Atuais)
# ==========================================
while IFS= read -r app_path; do
    app_name=$(basename "$app_path" .app | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    if [[ ${#app_name} -gt 3 ]]; then WHITELIST[$app_name]=1; fi
    
    first_word=$(basename "$app_path" .app | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    if [[ ${#first_word} -gt 3 ]]; then WHITELIST[$first_word]=1; fi

    bundle_id=$(defaults read "$app_path/Contents/Info.plist" CFBundleIdentifier 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if [[ -n "$bundle_id" && ${#bundle_id} -gt 3 ]]; then
        WHITELIST[$bundle_id]=1
        dev_name=$(echo "$bundle_id" | awk -F'.' '{print $2}')
        if [[ -n "$dev_name" && ${#dev_name} -gt 2 ]]; then
            WHITELIST[$dev_name]=1
        fi
    fi
done < <(find /Applications ~/Applications -maxdepth 3 -name "*.app" 2>/dev/null)

echo -e "${GREEN}✓ Whitelists carregadas! Buscando pastas órfãs...${NC}"

TARGET_DIRS=(
    "$HOME/Library/Application Support"
    "$HOME/Library/Caches"
    "$HOME/Library/Preferences"
)

POTENTIAL_ORPHANS=()

for DIR in "${TARGET_DIRS[@]}"; do
    if [ ! -d "$DIR" ]; then continue; fi

    for ITEM in "$DIR"/*; do
        BASENAME=$(basename "$ITEM")
        BASENAME_LOWER=$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
        
        if [[ "$BASENAME" == ".DS_Store" ]]; then continue; fi
        if [[ "$BASENAME_LOWER" == com.apple.* || "$BASENAME_LOWER" == *apple* || "$BASENAME_LOWER" == *macos* ]]; then continue; fi

        IS_ORPHAN=1
        for safe_word in ${(k)WHITELIST}; do
            if [[ "$BASENAME_LOWER" == *"$safe_word"* ]]; then
                IS_ORPHAN=0
                break
            fi
        done

        if [ $IS_ORPHAN -eq 1 ]; then
            POTENTIAL_ORPHANS+=("$ITEM")
        fi
    done
done

# ==========================================
# 3. ANÁLISE DO HOMEBREW
# ==========================================
BREW_INSTALLED=0
if command -v brew &> /dev/null; then
    BREW_INSTALLED=1
    echo -e "${YELLOW}➜ Analisando lixo e caches do Homebrew...${NC}"
    BREW_DRY_RUN=$(brew cleanup --dry-run 2>/dev/null)
    BREW_CACHE_DIR=$(brew --cache)
    BREW_CACHE_SIZE=$(du -sh "$BREW_CACHE_DIR" 2>/dev/null | awk '{print $1}')
fi

# ==========================================
# GERAÇÃO DO RELATÓRIO
# ==========================================
REPORT_FILE="$HOME/Desktop/Relatorio_Orfaos.txt"
echo "Relatório de Limpeza do Mac - $(date)" > "$REPORT_FILE"
echo "======================================================" >> "$REPORT_FILE"

echo -e "\n${CYAN}================================================${NC}"

if [ ${#POTENTIAL_ORPHANS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Resumo: ${#POTENTIAL_ORPHANS[@]} itens órfãos de Apps encontrados.${NC}"
    echo "Arquivos Suspeitos (Restos de Apps):" >> "$REPORT_FILE"
    for ORPHAN in "${POTENTIAL_ORPHANS[@]}"; do
        if [ ! -e "$ORPHAN" ]; then continue; fi
        SIZE=$(du -sh "$ORPHAN" 2>/dev/null | awk '{print $1}')
        echo "[ $SIZE ] $ORPHAN" | tee -a "$REPORT_FILE"
    done
else
    echo -e "${GREEN}Nenhum arquivo órfão óbvio encontrado.${NC}"
    echo "Nenhum arquivo órfão óbvio encontrado." >> "$REPORT_FILE"
fi

if [ $BREW_INSTALLED -eq 1 ]; then
    echo -e "\n======================================================" >> "$REPORT_FILE"
    echo "Análise do Homebrew:" >> "$REPORT_FILE"
    
    if [[ -n "$BREW_DRY_RUN" ]]; then
        echo -e "\n${RED}➜ Pacotes obsoletos/quebrados do Homebrew encontrados!${NC}"
        echo "Lixo a ser removido (Pacotes obsoletos/Links quebrados):" >> "$REPORT_FILE"
        echo "$BREW_DRY_RUN" >> "$REPORT_FILE"
    else
        echo -e "\n${GREEN}➜ Nenhum lixo pendente no Homebrew.${NC}"
        echo "Nenhum lixo pendente." >> "$REPORT_FILE"
    fi
    
    echo -e "Tamanho atual do Cache de downloads do Brew: ${YELLOW}$BREW_CACHE_SIZE${NC}"
    echo -e "\nTamanho do Cache de Downloads do Brew: $BREW_CACHE_SIZE" >> "$REPORT_FILE"
fi

echo -e "\n${GREEN}✓ O relatório completo foi salvo na sua Mesa: $REPORT_FILE${NC}"
echo -e "${CYAN}================================================${NC}\n"

# ==========================================
# FASE DE AÇÃO / DELEÇÃO
# ==========================================

if [ ${#POTENTIAL_ORPHANS[@]} -gt 0 ]; then
    echo -n "1) Deseja prosseguir para a exclusão manual de órfãos de apps? [s/N]: "
    read -r proceed_answer
    if [[ "$proceed_answer" == "s" || "$proceed_answer" == "S" ]]; then
        echo -e "\n${CYAN}Iniciando revisão... (s = deletar, n = pular, a = inspecionar no Finder)${NC}"
        for ORPHAN in "${POTENTIAL_ORPHANS[@]}"; do
            if [ ! -e "$ORPHAN" ]; then continue; fi
            SIZE=$(du -sh "$ORPHAN" 2>/dev/null | awk '{print $1}')
            echo -e "Suspeito: ${RED}$(basename "$ORPHAN")${NC} ($SIZE)"
            while true; do
                echo -n "Deletar este item? [s/n/a]: "
                read -r answer
                if [[ "$answer" == "s" || "$answer" == "S" ]]; then
                    rm -rf "$ORPHAN" 2>/dev/null
                    echo -e "${GREEN}✓ Excluído.${NC}\n"
                    break
                elif [[ "$answer" == "n" || "$answer" == "N" ]]; then
                    echo -e "${YELLOW}➜ Mantido.${NC}\n"
                    break
                elif [[ "$answer" == "a" || "$answer" == "A" ]]; then
                    open "$(dirname "$ORPHAN")"
                    echo -e "${CYAN}(Pasta superior aberta. Olhe o arquivo lá.)${NC}"
                else
                    echo -e "Resposta inválida."
                fi
            done
        done
    else
        echo -e "${YELLOW}➜ Revisão de órfãos ignorada.${NC}"
    fi
fi

if [ $BREW_INSTALLED -eq 1 ] && [[ -n "$BREW_DRY_RUN" ]]; then
    echo -n "\n2) Deseja remover o lixo do Homebrew (versões antigas/quebradas listadas no relatório)? (Seguro) [s/N]: "
    read -r brew_clean_ans
    if [[ "$brew_clean_ans" == "s" || "$brew_clean_ans" == "S" ]]; then
        echo -e "${CYAN}Limpando lixo do Homebrew...${NC}"
        brew cleanup
        echo -e "${GREEN}✓ Homebrew limpo.${NC}"
    else
        echo -e "${YELLOW}➜ Limpeza de pacotes do Homebrew ignorada.${NC}"
    fi
fi

echo -n "\n3) MODO COMPLETO: Deseja apagar *todos* os Caches (Apps do macOS e Caches do Homebrew)?\n   ATENÇÃO: Só faça isso se precisar urgentemente de espaço em disco. [s/N]: "
read -r deep_cache_ans
if [[ "$deep_cache_ans" == "s" || "$deep_cache_ans" == "S" ]]; then
    echo -e "${CYAN}Iniciando Limpeza Profunda de Caches...${NC}"
    
    if [ $BREW_INSTALLED -eq 1 ]; then
        rm -rf "$BREW_CACHE_DIR"/* 2>/dev/null
        echo -e "${GREEN}✓ Caches de download do Homebrew apagados.${NC}"
    fi
    
    rm -rf "$HOME/Library/Caches"/* 2>/dev/null
    echo -e "${GREEN}✓ Caches do Sistema e de Apps apagados.${NC}"
else
    echo -e "${YELLOW}➜ Limpeza de Caches pulada.${NC}"
fi

echo -e "\n${GREEN}Processo finalizado com sucesso!${NC}"
