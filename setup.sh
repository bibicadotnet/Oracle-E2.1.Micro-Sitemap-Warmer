#!/bin/bash

# cập nhập OS
sudo apt update && sudo apt upgrade -y

# set locale
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Tắt Firewall
sudo apt remove iptables-persistent -y
sudo ufw disable
sudo iptables -F

# Chỉnh về múi giờ Việt Nam
timedatectl set-timezone Asia/Ho_Chi_Minh

# Tạo swap 4GB RAM
sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile && echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
cat <<EOF > /etc/sysctl.d/99-xs-swappiness.conf
vm.swappiness=10
EOF

# Enable TCP BBR congestion control
cat <<EOF > /etc/sysctl.conf
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

# Cài đặt docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $(whoami)
sudo systemctl start docker
sudo systemctl enable docker

# Bypass Oracle VM.Standard.E2.1.Micro
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/NeverIdle-Oracle/master/VM.Standard.E2.1.Micro.sh -O /usr/local/bin/bypass_oracle.sh
chmod +x /usr/local/bin/bypass_oracle.sh
nohup /usr/local/bin/bypass_oracle.sh >> ./out 2>&1 <&- &
crontab -l > bypass_oracle
echo "@reboot nohup /usr/local/bin/bypass_oracle.sh >> ./out 2>&1 <&- &" >> bypass_oracle
crontab bypass_oracle

# Cài đặt DATUAN Sitemap Warmer
crontab -l > sitemap_warmer_oracle
echo "0 1 * * * reboot" >> sitemap_warmer_oracle
echo "0 */4 * * * docker run tdtgit/sitemap-warmer bibica.net -a" >> sitemap_warmer_oracle
crontab sitemap_warmer_oracle
