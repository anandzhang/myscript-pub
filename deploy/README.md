# 脚本说明

该文件夹内的脚本主要与部署有关。

## 部署 Nodejs Web 项目

### 简介

已测试环境：阿里云ECS的 CentOS 7.7 64位

脚本通过 nginx 反向代理 nodejs 项目，可以选择是否安装 git 克隆项目并自动启动运行。

流程：

1. 安装 Nodejs 12.x

2. 安装 Nginx

3. 是否安装 git 来克隆项目

   > 是：
   >
   > 1. 安装 git
   > 2. 输入github用户名和github项目名
   > 3. https 克隆项目（私有仓库git会提示输入github账号密码）

   > 否：跳过这一部分

4. 安装 pm2 （用来运行nodejs项目）

5. 运行 nodejs 项目

   > 前面通过git克隆了项目的话，会提示输入项目入口文件位置。比如：index.js 或者 src/index.js 等
   >
   > 没有git克隆项目就需要输入项目文件位置和入口文件位置

6. 配置 Nginx 反向代理

7. 启动 Nginx

### 使用方法

服务器环境一般都为 root用户，脚本就没有再进行管理员检测。

```shell
bash <(curl -sL https://git.io/aliyun-centos-deploy-nodejs-web.sh)
```



