#!/bin/bash
# Aliyun ECS: CentOS 7
# Setting up the environment needed to deploy a nodejs web project

echo -e '\n## Installing Node.js 12.x Stable Release\n'
# yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_12.x | bash
yum install -y nodejs

echo -e '\n## Installing nginx\n'
echo '[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1' >/etc/yum.repos.d/nginx.repo
yum install -y nginx

# Install git
install_git() {
    if [ $(command -v git) ]; then
        echo -e '\n## Remove installed git\n'
        yum remove -y git
    fi
    yum install -y https://centos7.iuscommunity.org/ius-release.rpm
    yum install -y git2u-all
    # Set clone with https to not repeatedly enter account information
    git config --global credential.helper store
}

clone_git_repository() {
    while true; do
        read -p "Enter github username : " git_username
        read -p "Enter github repository name : " git_repository
        echo -e "\nUsername: $git_username\nRepository: $git_repository\n"
        while true; do
            read -p 'Are you sure? (Y/n): ' flag_clone_info
            if [ $flag_clone_info == 'y' -o $flag_clone_info == 'Y' ]; then
                flag_clone_info=true
                break
            elif [ $flag_clone_info == 'n' -o $flag_clone_info == 'N' ]; then
                echo 'Please enter again.'
                flag_clone_info=false
                break
            else
                echo 'Please type Y/n.'
            fi
        done
        if $flag_clone_info; then
            break
        fi
    done
    echo ''
    git clone "https://github.com/$git_username/$git_repository.git"
}

question_install_git='Do you need to install git to clone the project you need to deploy？ (Y/n): '
while true; do
    read -p "$question_install_git" flag_install_git
    if [ "$flag_install_git" == 'y' -o "$flag_install_git" == 'Y' ]; then
        echo -e '\n## Installing git\n'
        install_git
        clone_git_repository
        break
    elif [ "$flag_install_git" == 'n' -o "$flag_install_git" == 'N' ]; then
        echo -e '\n## Git installation skipped\n'
        break
    else
        question_install_git='Please type Y/n : '
    fi
done

echo -e '\n## Installing pm2 to run nodejs app\n'
npm install -g pm2

echo -e '\n## Run the node project use pm2\n'
if $git_repository; then
    echo "The cloned project: $git_repository"
    echo 'Starting for you automatically......'
else
    read -p "Enter project path: (eg: ~/blog or download/blog) " custom_repository
    git_repository=custom_repository
fi
read -p "Enter entry file: (eg: index.js or src/app.js) " entry_file
pm2 start "$git_repository/$entry_file" --name web --watch

echo -e '\n## Configuring nginx\n'
master_config_file=/etc/nginx/nginx.conf
http_config_file=/etc/nginx/conf.d/default.conf
doc_root_dir=/usr/share/nginx/html
# Query server public IP
ip=$(curl -s ifconfig.me/ip)
conf=$(curl -sL https://git.io/JvCG6)
echo "${conf/ip/$ip}" >$http_config_file

echo -e '\n## Start/enable nginx server\n'
systemctl enable nginx
systemctl start nginx