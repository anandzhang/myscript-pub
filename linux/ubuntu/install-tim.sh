#!/bin/bash
# ubuntu 18.04 LTS
# install TIM
# root demand
if [ $(whoami) != "root" ]; then
    echo 'Permission Denied! Please use the administrator to execute it.'
    exit
fi

deepin_wine_ubuntu_github=https://github.com/wszqkzqk/deepin-wine-ubuntu.git
deepin_wine_ubuntu_gitee=https://gitee.com/wszqkzqk/deepin-wine-for-ubuntu.git
deepin_tim=https://mirrors.aliyun.com/deepin/pool/non-free/d/deepin.com.qq.office/deepin.com.qq.office_2.0.0deepin4_i386.deb

fix_chinese_garbled_path=/opt/deepinwine/tools/run.sh
fix_chinese_garbled_str='LC_ALL=zh_CN.UTF-8 deepin-wine'

echo '## Downloading deepin-wine-ubuntu using git'
if ! [ $(command -v git) ]; then
    echo | apt-add-repository ppa:git-core/ppa
    apt update
    apt install -y git
fi
git clone $deepin_wine_ubuntu_gitee
fullname=$(basename $deepin_wine_ubuntu_gitee)
filename=${fullname%.*}
./$filename/install.sh

echo '## Installing TIM'
wget $deepin_tim
dpkg -i $(basename $deepin_tim)

echo '## Judging system language'
if [ $LANG != 'zh_CN.UTF-8' ]; then
    echo 'Fix garbled characters on non-Chinese systems'
    sed -i "s/\(WINE_CMD=\)\".*\"/\1\"$fix_chinese_garbled_str\"/" $fix_chinese_garbled_path
fi

echo '## Installing gnome shell extension'
apt install -y gnome-tweaks gnome-shell-extension-top-icons-plus
echo -e '\n## Finally, you need to complete the following steps manually.'
echo -e '\n## Step.1 Please restart the gnome-shell (hit Alt + F2, type r).'
echo -e '\n## Step.2 Open the plugin through the Tweaks ( open Applications: Tweaks -> Extensions -> Topicons plus ).'
