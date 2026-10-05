cws_home="$HOME/Documents/Trabalho/cws"
USER_DATA_DIR="$cws_home/.vscode-cws/user-data"
EXT_DIR="$cws_home/.vscode-cws/extensions"

mkdir -p "$USER_DATA_DIR/User"
mkdir -p "$EXT_DIR"

if [ "$#" -gt 0 ]; then
  open -n -b com.microsoft.VSCode --args --user-data-dir "$USER_DATA_DIR" --extensions-dir "$EXT_DIR" "$@"
else
  # Abre uma instância completamente em branco
  open -n -b com.microsoft.VSCode --args --user-data-dir "$USER_DATA_DIR" --extensions-dir "$EXT_DIR"
fi