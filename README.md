# dotfiles

Configurações pessoais de shell, Git e ferramentas de desenvolvimento.

## GitHub pessoal e trabalho

O `gh` mantém as contas `wvxbs` e `gabriel-ferreira-cws` no mesmo keyring.
O wrapper `gh` seleciona automaticamente a conta esperada pelo diretório atual
antes de executar o comando. O Git usa a identidade pessoal por padrão e troca
automaticamente para a identidade corporativa nos repositórios em
`~/Documents/Trabalho/cws/repos/`.

Depois de autenticar as duas contas com `gh auth login`, configure explicitamente
o `gh` como credential helper do Git:

```zsh
gh auth setup-git --hostname github.com
```

Comandos de uso diário:

```zsh
ghp       # somente ativa a conta pessoal no gh
ghs       # somente mostra conta, autor Git, repositório e remote
```

Dentro de `~/Documents/Trabalho/cws`, `gh` usa `gabriel-ferreira-cws`. Fora
desse diretório, usa `wvxbs`. O `gh auth switch` é global para `github.com`:
por isso, cada invocação do wrapper confere novamente a conta esperada. A
identidade gravada no commit é independente e continua sendo selecionada pelo
caminho do repositório.

## VS Code

Dentro de `~/Documents/Trabalho/cws`, o wrapper `code` usa o profile existente
`CWS Digital`. Antes de passar `--profile`, ele confirma que o profile está
registrado e que seu diretório existe. Se o profile tiver sido removido ou
estiver sendo recriado, executa o `code` normal sem criar ou sobrescrever nada.

O arquivo `~/.zshrc` deve carregar, nesta ordem:

```zsh
source "$HOME/Documents/tools/dotfiles/aliases"
source "$HOME/Documents/tools/dotfiles/cws.zsh"
```
