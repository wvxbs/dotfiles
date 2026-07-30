#!/bin/bash

# Nome do arquivo de saída direcionado para a Mesa (Desktop)
OUTPUT="$HOME/Documents/Mac$(date +%Y%m%d_%H%M%S).md"
exec > >(tee -a "$OUTPUT") 2>&1

echo "# Diagnóstico Avançado do MacBook (Bateria, Sleep, Displays e Tema)"
echo "**Data:** $(date)"
echo ""
echo "Este script foi expandido para incluir powermetrics, análise de WindowServer e validações profundas de Location Services."
echo ""

echo "## 1. System Inventory & Hardware"
echo "\`\`\`text"
system_profiler SPHardwareDataType SPSoftwareDataType
echo "\`\`\`"
echo ""

echo "## 2. Battery & Power Data"
echo "\`\`\`text"
pmset -g batt
echo ""
echo "--- Power Settings (pmset -g) ---"
pmset -g custom
echo ""
echo "--- Thermal Status ---"
pmset -g therm
echo "\`\`\`"
echo ""

echo "## 3. Sleep, Wake & Power Assertions"
echo "\`\`\`text"
echo "--- Current Power Assertions ---"
pmset -g assertions
echo ""
echo "--- Ultimos eventos de Sleep/Wake (Ultimas 24h) ---"
pmset -g log | grep -iE "( Sleep | Wake | DarkWake | Wake request | due to )" | tail -n 50
echo "\`\`\`"
echo ""

echo "## 4. External Display & WindowServer (Básico)"
echo "\`\`\`text"
system_profiler SPDisplaysDataType
echo ""
echo "--- WindowServer CPU/Memory Usage ---"
top -l 1 -s 0 | grep -i "WindowServer"
echo "\`\`\`"
echo ""

echo "## 5. Specific Processes Analysis (Global)"
echo "\`\`\`text"
echo "--- TOP 15 Processos que mais consomem CPU no sistema inteiro ---"
ps -eo user,pid,pcpu,pmem,comm | sort -nr -k 3 | head -n 15
echo "\`\`\`"
echo ""

echo "## 6. Análise de Usuários e Serviços Específicos"
echo "\`\`\`text"
for u in wvxbs cws; do
    echo "========================================="
    echo " INSPECIONANDO USUÁRIO: $u"
    echo "========================================="
    dscl . -read /Users/$u UniqueID PrimaryGroupID RecordName NFSHomeDirectory 2>/dev/null | grep -v "AppleMetaNode"
    echo ""
    sudo -u $u defaults read /Users/$u/Library/Preferences/ByHost/com.apple.coreservices.useractivityd.dynamicuseractivites.plist 2>/dev/null || echo "Preferência Handoff não encontrada para $u."
    echo ""
    sudo -u $u launchctl list | grep -iE "(cloudd|handoff|location)" || echo "Nenhum serviço mapeado listado."
    echo ""
done
echo "\`\`\`"
echo ""

echo "## 8. Power Metrics (Apple Silicon)"
echo "\`\`\`text"
sudo powermetrics --samplers cpu_power,gpu_power,thermal -n 1
echo ""
echo "--- Tasks Metric (Se suportado) ---"
sudo powermetrics --samplers tasks -n 1
echo "\`\`\`"
echo ""

echo "## 9. Energy Impact"
echo "\`\`\`text"
top -l 1 -stats pid,command,cpu,mem,power,time -o power | head -n 30
echo "\`\`\`"
echo ""

echo "## 10. WindowServer"
echo "\`\`\`text"
ps -axo pid,pcpu,pmem,etime,command | grep WindowServer
echo ""
log show --last 2h --predicate 'process == "WindowServer"' --style compact | tail -200
echo "\`\`\`"
echo ""

echo "## 11. Location Services"
echo "\`\`\`text"
defaults read /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd 2>/dev/null
echo ""
sudo defaults read /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd 2>/dev/null
echo ""
systemsetup -gettimezone
echo ""
systemsetup -getusingnetworktime
echo ""
log show --last 24h --predicate 'process == "locationd"' | tail -300
echo "\`\`\`"
echo ""

echo "## 12. Geo Services"
echo "\`\`\`text"
log show --last 24h --predicate 'process == "geod"' | tail -200
echo "\`\`\`"
echo ""

echo "## 13. Dynamic Appearance"
echo "\`\`\`text"
defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Modo claro ativo."
defaults read -g AppleInterfaceStyleSwitchesAutomatically 2>/dev/null || echo "Troca automática ausente."
defaults read com.apple.controlcenter 2>/dev/null
defaults read com.apple.CoreBrightness 2>/dev/null
log show --last 24h --predicate 'process == "corebrightnessd"' | tail -300
echo "\`\`\`"
echo ""

echo "## 14. Displays"
echo "\`\`\`text"
system_profiler SPDisplaysDataType
echo ""
ioreg -lw0 | grep IODisplay
echo ""
ioreg -lw0 | grep -i refresh
echo ""
ioreg -lw0 | grep -i vrr
echo "\`\`\`"
echo ""

echo "## 15. USB"
echo "\`\`\`text"
system_profiler SPUSBDataType
echo ""
ioreg -p IOUSB
echo "\`\`\`"
echo ""

echo "## 16. Kernel"
echo "\`\`\`text"
top -l 1 | grep kernel_task
echo ""
sysctl machdep.cpu 2>/dev/null || echo "machdep.cpu não suportado em Apple Silicon. Tentando hw.cpufrequency / hw.activecpu"
sysctl hw.activecpu hw.ncpu
echo "\`\`\`"
echo ""

echo "## 17. Spotlight"
echo "\`\`\`text"
mdutil -sa
echo ""
ps aux | grep mds
echo ""
log show --last 12h --predicate 'process == "mds"' | tail -100
echo "\`\`\`"
echo ""

echo "## 18. Launch Agents"
echo "\`\`\`text"
launchctl print system | grep -E "disabled|active" | head -n 30
echo ""
launchctl print gui/$(id -u) | grep -E "disabled|active" | head -n 30
echo "\`\`\`"
echo ""

echo "## 19. Login Items"
echo "\`\`\`text"
osascript <<EOF
tell application "System Events"
get the name of every login item
end tell
EOF
echo "\`\`\`"
echo ""

echo "## 20. Battery History"
echo "\`\`\`text"
pmset -g batt
echo "\`\`\`"
echo ""

echo "## 21. Memory"
echo "\`\`\`text"
memory_pressure
echo ""
vm_stat
echo "\`\`\`"
echo ""

echo "## 22. Thermal"
echo "\`\`\`text"
pmset -g therm
echo ""
log show --last 24h --predicate 'subsystem == "com.apple.PowerManagement"' | tail -300
echo "\`\`\`"
echo ""

echo "## 23. Sleep Report"
echo "\`\`\`text"
pmset -g assertions
echo ""
pmset -g assertionslog | tail -500
echo ""
pmset -g log | tail -500
echo "\`\`\`"
echo ""

echo "## 24. Processos"
echo "\`\`\`text"
for USER in wvxbs cws
do
echo ""
echo "========== \$USER =========="
ps -u \$USER -o pid,pcpu,pmem,time,command | sort -nr -k2 | head -40
done
echo "\`\`\`"
echo ""

echo "## 25. Resumo de Problemas Automatizados (Flags)"
echo "\`\`\`text"

# Check WindowServer CPU > 20%
WS_CPU=\$(ps -axo pcpu,command | grep WindowServer | grep -v grep | awk '{print \$1}')
if (( \$(echo "\$WS_CPU > 20.0" | bc -l) )); then
    echo "⚠️ WindowServer acima de 20% de CPU: \$WS_CPU%"
fi

# Check kernel_task CPU > 300%
KT_CPU=\$(ps -axo pcpu,command | grep kernel_task | grep -v grep | awk '{print \$1}')
if (( \$(echo "\$KT_CPU > 300.0" | bc -l) )); then
    echo "⚠️ kernel_task acima de 300%: \$KT_CPU%"
fi

# Check mds running continuously (CPU > 15% as heuristic)
MDS_CPU=\$(ps -axo pcpu,command | grep mds | grep -v mds_stores | grep -v grep | head -n 1 | awk '{print \$1}')
if [[ -n "\$MDS_CPU" ]] && (( \$(echo "\$MDS_CPU > 15.0" | bc -l) )); then
    echo "⚠️ mds consumindo CPU alto: \$MDS_CPU%"
fi

# Check DarkWake count in last 24h
DW_COUNT=\$(pmset -g log | grep -c "DarkWake")
if [ "\$DW_COUNT" -gt 10 ]; then
    echo "⚠️ Mais de 10 eventos de DarkWake nas últimas 24 horas. Count: \$DW_COUNT"
fi

# Check for lghub_agent timeout
LGHUB=\$(pmset -g log | grep -c "lghub_agent timed out")
if [ "\$LGHUB" -gt 0 ]; then
    echo "⚠️ lghub_agent timed out foi registrado nos logs de energia."
fi

# Check Location Services enabled
LOC_STAT=\$(sudo defaults read /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled 2>/dev/null)
if [ "\$LOC_STAT" != "1" ]; then
    echo "⚠️ Location Services desativado ou ilegível (LocationServicesEnabled != 1)."
fi

# Check Auto Interface Style
AUTO_STYLE=\$(defaults read -g AppleInterfaceStyleSwitchesAutomatically 2>/dev/null)
if [ -z "\$AUTO_STYLE" ] || [ "\$AUTO_STYLE" != "1" ]; then
    echo "⚠️ AppleInterfaceStyleSwitchesAutomatically ausente ou desativado."
fi

# Two users graphic check via Users logged in (heuristic: users running WindowServer or Dock)
MULTI_USER=\$(ps aux | grep Dock | grep -v grep | awk '{print \$1}' | sort | uniq | wc -l)
if [ "\$MULTI_USER" -gt 1 ]; then
    echo "⚠️ Dois (ou mais) usuários gráficos ativos simultaneamente."
fi

# Check powerd assertions
POW_ASS=\$(pmset -g assertions | grep -c "PreventUserIdleSystemSleep")
if [ "\$POW_ASS" -gt 0 ]; then
    echo "⚠️ powerd com assertions persistentes ativas (PreventUserIdleSystemSleep)."
fi

# Check external monitor refresh rate > 120Hz
RR=\$(ioreg -lw0 | grep -i refresh | awk '{print \$4}')
if [[ "\$RR" != "" ]]; then
     echo "⚠️ Monitor externo refresh rate config detectada. Favor checar bloco 14 para 144Hz/165Hz."
fi

echo "\`\`\`"
echo ""

echo "=================================================="
echo " DIAGNÓSTICO AVANÇADO CONCLUÍDO "
echo " O arquivo foi salvo em: \$OUTPUT"
echo "=================================================="
