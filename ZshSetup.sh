sudo usermod -s /bin/zsh $USER

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cd ~/.oh-my-zsh/plugins

git clone https://github.com/zsh-users/zsh-autosuggestions
