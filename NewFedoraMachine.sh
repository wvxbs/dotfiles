USER_NAME=
EMAIL=

sudo dnf update -y

sudo dnf upgrade -y

sudo dnf install -y firefox geary git neofetch npm python python3 python-pip marker gnome-pomodoro dnf-plugins-core flatpak neovim 

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

sudo dnf update && sudo dnf install -y code

sudo dnf install -y akmod-nvidia install xorg-x11-drv-nvidia-cuda

curl https://cli-assets.heroku.com/install.sh | sh

sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine

sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io -y

sudo dnf copr enable joseexposito/touchegg -y

sudo dnf install -y touchegg

sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

sudo dnf install -y gh

curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash

bash -c "$(curl -fsSL https://raw.githubusercontent.com/denysdovhan/gnome-terminal-one/master/one-dark.sh)"

bash -c "$(curl -fsSL https://raw.githubusercontent.com/denysdovhan/gnome-terminal-one/master/one-light.sh)"

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install com.spotify.Client

flatpak install flathub com.discordapp.Discord

flatpak install flathub us.zoom.Zoom

flatpak install flathub org.chromium.Chromium

flatpak install flathub com.jetbrains.IntelliJ-IDEA-Community

flatpak install flathub com.google.AndroidStudio

flatpak install flathub com.getpostman.Postman

flatpak install flathub nl.hjdskes.gcolor3

flatpak install flathub org.darktable.Darktable

flatpak install flathub org.gimp.GIMP

flatpak install flathub org.inkscape.Inkscape

flatpak install flathub com.github.phase1geo.minder

flatpak install flathub com.github.muriloventuroso.easyssh

flatpak install flathub io.github.lainsce.Colorway

flatpak install flathub io.github.lainsce.Emulsion

git config --global user.name $USER_NAME

git config --global user.email $EMAIL
