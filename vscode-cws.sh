cws_home="${CWS_HOME:-$HOME/Documents/Trabalho/cws}"
USER_DATA_DIR="$cws_home/.vscode/user-data"
EXT_DIR="$cws_home/.vscode/extensions"

open -n -a "Visual Studio Code" --args \
  --user-data-dir "$USER_DATA_DIR" \
  --extensions-dir "$EXT_DIR" \
  "$@"