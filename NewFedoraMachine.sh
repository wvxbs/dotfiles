user=

sudo dnf update -y

sudo dnf upgrade -y

sudo dnf install -y firefox geary git neofetch npm python python3 python-pip cargo marker gnome-pomodoro dnf-plugins-core flatpak neovim zsh bat exa tokei doas

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

sudo dnf update && sudo dnf install -y code

curl https://cli-assets.heroku.com/install.sh | sh

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

flatpak install flathub  com.spotify.Client com.discordapp.Discord us.zoom.Zoom org.chromium.Chromium com.jetbrains.IntelliJ-IDEA-Community com.google.AndroidStudio com.getpostman.Postman org.darktable.Darktable org.gimp.GIMP org.inkscape.Inkscape com.github.phase1geo.minder com.github.muriloventuroso.easyssh io.github.lainsce.Colorway io.github.lainsce.Emulsion de.haeckerfelix.Fragments com.obsproject.Studio md.obsidian.Obsidian com.rafaelmardojai.Blanket com.rafaelmardojai.WebfontKitGenerator com.github.gi_lom.dialect

sudo usermod -s /bin/zsh $user

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
