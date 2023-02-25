sudo pacman -Syu base-devel go

cd /opt
sudo git clone https://aur.archlinux.org/yay.git

sudo chown -R wvxbs:users ./yay

cd yay

makepkg -si
