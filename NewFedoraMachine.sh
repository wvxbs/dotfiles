USER_NAME=
EMAIL=

sudo dnf update -y

sudo dnf upgrade -y

sudo dnf install -y firefox geary git neofetch nodejs python gnome-pomodoro dnf-plugins-core flatpak neovim 

sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine

sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io -y

sudo dnf copr enable joseexposito/touchegg -y

sudo dnf install -y touchegg

sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

sudo dnf install -y gh

curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install com.spotify.Client

flatpak install flathub com.discordapp.Discord

flatpak install flathub us.zoom.Zoom

flatpak install flathub org.chromium.Chromium

flatpak install flathub com.google.AndroidStudio

flatpak install flathub com.getpostman.Postman

flatpak install flathub nl.hjdskes.gcolor3

flatpak install flathub org.darktable.Darktable

flatpak install flathub org.gimp.GIMP

flatpak install flathub org.inkscape.Inkscape

flatpak install flathub com.github.phase1geo.minder

flatpak install flathub com.github.muriloventuroso.easyssh

flatpak install flathub com.visualstudio.code

flatpak install flathub io.github.lainsce.Colorway

flatpak install flathub io.github.lainsce.Emulsion

git config --global user.name $USER_NAME

git config --global user.email $EMAIL
