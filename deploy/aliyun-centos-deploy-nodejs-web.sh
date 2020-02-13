#!/bin/bash
# Aliyun ECS: CentOS 7
# Setting up the environment needed to deploy a nodejs web project

echo -e '\n## Installing Node.js 12.x Stable Release\n'
curl -sL https://rpm.nodesource.com/setup_12.x | bash
yum install -y nodejs

install_mongodb() {
    echo '## Install MongoDB Community Edition'
    echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb-org-4.2.repo
    yum install -y mongodb-org
    echo '## Start MongoDB'
    systemctl start mongod
    systemctl enable mongod
}

while true; do
    read -p "Do you need to install mongo？(Y/n): " flag_install_mongo
    if [ "$flag_install_mongo" == 'y' -o "$flag_install_mongo" == 'Y' ]; then
        install_mongodb
        break
    elif [ "$flag_install_mongo" == 'n' -o "$flag_install_mongo" == 'N' ]; then
        echo -e '\n## MongoDB installation skipped\n'
        break
    else
        question_install_git='Please type Y/n : '
    fi
done
unset flag_install_mongo

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
    clone_address="https://github.com/$git_username/$git_repository.git"
    echo "Ready to clone: $clone_address"
    git clone $clone_address
    unset clone_address
    unset git_username
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
unset flag_install_git

echo -e '\n## Installing pm2 to run nodejs app\n'
npm install -g pm2

init_project() {
    current=$(pwd)
    cd $git_repository
    npm install
    while true; do
        read -p "Do you need initialization？(Y/n) :" flag_init
        if [ $flag_init == 'y' -o $flag_init == 'Y' ]; then
            while true; do
                read -p "enter command (enter exit to exit): " command
                if [ $command == 'exit' ]; then
                    break
                fi
                $command
            done
            break
        elif [ $flag_init == 'n' -o $flag_init == 'N' ]; then
            break
        else
            echo 'Please enter Y/n..'
        fi
    done
    cd $current
    unset current
    unset flag_init
}

echo -e '\n## Run the node project use pm2\n'
if [ -n $git_repository ]; then
    echo "The cloned project: $git_repository"
    echo 'Starting for you automatically......'
else
    read -p "Enter project path: (eg: ~/blog or download/blog) " git_repository
fi
read -p "Enter entry file: (eg: index.js or src/app.js) " entry_file
init_project
pm2 start "$git_repository/$entry_file" --name web --watch
unset git_repository
unset entry_file

query_public_ip() {
    ip=$(curl -s -m 3 http://ifconfig.me/ip)
    [ -z $ip ] && ehco 'Try to get public ip again' && ip=$(curl -s -m https://api.ip.sb/ip)
    [ -z $ip ] && ehco 'Try to get public ip again' && ip=$(curl -s -m http://ip.cip.cc/)
    [ -z $ip ] && ehco 'Try to get public ip again' && query_public_ip
}

echo -e '\n## Configuring nginx\n'
master_config_file=/etc/nginx/nginx.conf
http_config_file=/etc/nginx/conf.d/default.conf
doc_root_dir=/usr/share/nginx/html
query_public_ip
# nginx config
while true; do
    get_conf_statuCode=$(curl -sL -w %{http_code} -o $http_config_file https://git.io/nodejs-default.conf)
    if [ $get_conf_statuCode = 200 ]; then
        sed -i "s/ip/$ip/" $http_config_file
        break
    else
        echo "Get nginx nodejs failed， retry..."
    fi
done
unset get_conf_statuCode

echo -e '\n## Start/enable nginx server\n'
systemctl enable nginx
systemctl start nginx
