#!/usr/bin/bash
#     _    ____  
#    / \  / ___|   Alexandre Stanescot
#   / _ \ \___ \   http://alexstan67.github.io/profile/
#  / ___ \ ___) |  https://github.com/alexstan67/
# /_/   \_\____/ 
#
# Date:	   30/09/2024
# Update:  30/09/2024
# Title: Post installation script after Ubuntu-24.04.1-LTS fresh install
# Download manually this file from https://github.com/as-consult/setup
# make it executable and execute it.

echo "####################################################################"
echo "----------- Create directories and update/upgrade APT"
echo "####################################################################"
mkdir ~/Github ~/Apps ~/Git ~/VMs
sudo apt update && sudo apt -y upgrade

echo "####################################################################"
echo "----------- Install APT Packages"
echo "####################################################################"
sudo apt install -y git gh usb-creator-gtk python3-pip vim lynx tree gimp \
                    imagemagick vlc inkscape qalc gpick exiv2 easytag figlet \
                    mat2 kleopatra neofetch qrencode xournalpp font-manager \
                    testdisk openscad librecad stellarium nextcloud-desktop \
                    nautilus-nextcloud qemu-system virt-manager bridge-utils \
                    zsh curl net-tools whois nmap traceroute transmission \
                    metadata-cleaner timeshift pdftk postgresql-client
# testdisk  = recovery tool
# pdftk     = manage pdf (concat, ..) https://www.pdflabs.com/docs/pdftk-cli-examples/
# qrencode  = generate a qr code, c.f. qrencode -o "wef" -s 6 -l H -m 2 "https://weekend-fly.com"
# xournalpp = pdf annotations
sleep 2

echo "####################################################################"
echo "-----------  Install SNAP Packages"
echo "####################################################################"
sudo snap install postman thunderbird brave cherrytree dbeaver-ce projectlibre \
                  cups marble torrhunt signal-desktop podcasts slack \
                  libreoffice
sleep 2

echo "####################################################################"
echo "-----------  Install Docker"
echo "####################################################################"
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install latest version
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
                    docker-compose-plugin

# Post-install to run docker as non-root
#sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# Configure Docker to start on boot with systemd
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sleep 2

echo "####################################################################"
echo "------------- Configuration Files"
echo "####################################################################"

echo "------------- Setup vim"
mkdir -p ~/Github/as-consult && cd ~/Github/as-consult
git clone https://github.com/as-consult/setup.git
ln -s ~/Github/as-consult/setup/vimrc ~/.vimrc
mkdir -p ~/.vim/spell
mkdir -p ~/.vim/plugged
cd ~/.vim/spell
wget http://ftp.vim.org/pub/vim/runtime/spell/fr.utf-8.spl
wget http://ftp.vim.org/pub/vim/runtime/spell/fr.utf-8.sug
wget http://ftp.vim.org/pub/vim/runtime/spell/de.utf-8.spl
wget http://ftp.vim.org/pub/vim/runtime/spell/de.utf-8.sug
sleep 2

echo "------------- Install VIM Plugins"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sleep 2

echo "------------- Setup OH-MY-ZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sleep 2

echo "------------- Setup environment variables"
echo "# Environment variables" >> ~/.zshrc
echo 'export EDITOR=vim' >> ~/.zshrc
sleep 2

echo "------------- Setup Aliases"
echo "# Aliases" >> ~/.zshrc
echo 'alias e='exit'' >> ~/.zshrc
echo 'alias myip="curl https://ipinfo.io/json"' >> ~/.zshrc
echo 'alias r-grep="grep -rin --exclude-dir={tmp,log}"'  >> ~/.zshrc
sleep 2

echo "------------- Setup oh-my-zsh plugin"
cd /home/alex/.oh-my-zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="af-magic"/g' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(gitfast last-working-dir zsh-syntax-highlighting ssh-agent)/g' ~/.zshrc

echo "------------- Setup Git config"
ln -s ~/Github/as-consult/setup/gitconfig ~/.gitconfig
git config --global pull.ff only
sleep 2

echo "------------- Setup Lynx"
sudo chmod 777 /etc/lynx/lynx.cfg
echo 'ACCEPT_ALL_COOKIES:TRUE' >> /etc/lynx/lynx.cfg
sleep 2

echo "------------- Install Ledger Nano S USB Support"
wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash
sudo add-apt-repository universe
sudo apt install -y libfuse2
sudo apt install -y libfuse3-3
sleep 2

echo "------------- Setup Hosts"
sudo chown alex:root /etc/hosts
echo '192.168.77.16	 nas-001' >> /etc/hosts
echo '192.168.77.19	 mac-001' >> /etc/hosts
echo '54.37.152.178  vps-001' >> /etc/hosts
echo '51.210.106.100 vps-002' >> /etc/hosts
echo '141.94.17.140  vps-003' >> /etc/hosts
sleep 2

echo "------------- Setup Firewall"
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow 80      #http
sudo ufw allow 443     #https
sudo ufw allow 22      #ssh
sudo ufw allow 993     #imaps
sudo ufw allow 25      #smtp
sudo ufw allow 631     #ipp printers
sudo ufw allow 15001   #nas
sudo ufw allow 5432    #postgresql
sudo ufw allow 11194   #openvpn
sudo ufw enable
sleep 2

echo "------------- Setup crontab -e"
crontab ~/Github/as-consult/setup/crontab_purge  #To purge logs
sleep 2

echo "------------- Download Samsung SCX-470 Drivers"
cd ~/Downloads && wget https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M4580FX/uld_V1.00.39_01.17.tar.gz 

echo "####################################################################"
echo "-----------  APT Clean"
echo "####################################################################"
sudo apt update && sudo apt -y upgrade && sudo apt autoclean && \
sudo apt -y autoremove

echo "####################################################################"
echo "-----------  End of Post Install Process"
echo "####################################################################"
