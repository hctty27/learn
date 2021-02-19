# CentOS7离线安装RabbitMQ

## 一、基础知识

### 1.1 查看自己系统版本

查看Linux 系统内核版本

```bash
uname -a
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20201126110017754.png#pic_center)
查看CentOS 系统版本号

```bash
cat /etc/redhat-release
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20201126110306517.png#pic_center)

查看Linux Ubantu 系统版本号

```bash
cat /etc/issue
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/2020112611011213.png#pic_center)

### 1.2 下载所需安装包

#### 1.2.1 各安装包后缀含义

- .deb Ubantu安装软件包

```bash
 安装： sudo dpkg -i 软件包名.deb
 卸载：sudo apt-get remove 软件包名称
```

- .rpm 是编译好的二进制包，可用rpm命令直接安装

```bash
安装：rpm -i filename.rpm
卸载 1、rpm -qa filename* 模糊查询rpm 包软件
执行卸载命令：rpm -e filename
```

- .tar.gz（bz或bz2…）需要编译后才能安装，安装方法为:

```bash
1、cd 压缩包所在目录
2、解压压缩软件
 2.1 tar -zxvf ****.tar.gz
 2.2 tar -jxvf ****.tar.bz(或bz2)
3、cd 解压缩后的目录
4、输入编译文件命令：./configure 
5、编译命令: make 
6、安装文件命令：make install
```

- .src.rpm 源程序包 需编译后再安装
- .noarch.rpm 可以在不同cpu上使用
  [常见linux系统中RPM包的通用命名规则](https://www.cnblogs.com/xnb123/p/8524716.html)
  [常见安装包卸载安装命令](https://zhidao.baidu.com/question/515999703.html)

#### 1.2.2 离线安装RabbitMQ所需安装包下载

在安装之前最好去 [这里](https://www.rabbitmq.com/which-erlang.html) 查看这2个软件搭配的必要信息
我这里用的是
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201126111602815.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzI4NDE4ODg3,size_16,color_FFFFFF,t_70#pic_center)
所需各版本只需更改链接后缀 数字即可
1、erlang/otp 19.3.1下载
https://github.com/rabbitmq/erlang-rpm/releases/tag/v19.3.1
下载文件名：erlang-19.3.2-1.el7.centos.x86_64.rpm

2、socat 版本：socat-1.7.3.2-2.el7.x86_64.rpm
百度网盘链接：https://pan.baidu.com/s/1GmPadtlVvecqGiXab4rl-Q
提取码：25m3

3、rabbitmq-server 3.6.10下载
https://github.com/rabbitmq/rabbitmq-server/releases/tag/rabbitmq_v3_6_10
下载文件名：rabbitmq-server-3.6.10-1.el7.noarch.rpm

## 二、开始安装

### 2.1 安装 erlang

```bash
sudo rpm -i erlang-19.3.2-1.el7.centos.x86_64.rpm
```

查看版本 出现下图则表示安装成功

```bash
erl -v
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20201126145532314.png#pic_center)

### 2.2 安装 socat

强制不检查依赖，安装所有rpm包

```bash
rpm -ivh 
```

1、cd 到安装包所在目录运行下面语句

```bash
sudo rpm -ivh socat-1.7.3.2-2.el7.x86_64.rpm
```

2、验证是否安装成功

```bash
socat -h
```

出现下图则表示安装成功
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201127152916849.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzI4NDE4ODg3,size_16,color_FFFFFF,t_70)
3、注意事项：
如使用 .tar.gz包安装、在安装rabbitMQ会出现缺少socat依赖；
报错信息如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201126160510922.png#pic_center)

### 2.3 安装 RabbitMQ

1、cd 到安装包所在目录运行下面语句

```bash
sudo rpm -ivh rabbitmq-server-3.6.10-1.el7.noarch.rpm
```

### 2.4 配置 RabbitMQ

查找RabbitMQ 安装目录

```bash
whereis rabbitmq
```

#### 2.4.1 设置guest用户 可通过任意网址登录

RabbitMQ 默认guest 用户 只能localhost登录
1、修改rabbit.app 文件 loopback_users选项
跳转到 rabbit.app 所在目录

```bash
cd /usr/lib/rabbitmq/lib/rabbitmq_server-3.6.10/ebin
```

2、打开文件

```bash
 sudo vim rabbit.app
```

3、修改为如下图 后存盘退出
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201127160608625.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzI4NDE4ODg3,size_16,color_FFFFFF,t_70)

#### 2.4.2 开放端口

\#默认服务端口

```bash
sudo iptables -I INPUT -ptcp --dport 5672 -j ACCEPT
```

\#默认管理界面端口

```bash
sudo iptables -I INPUT -ptcp --dport 15672 -j ACCEPT
```

#### 2.4.3 启动服务

激动人心的时刻来了
1、cd 到安装目录sbin 文件夹

```bash
cd /usr/lib/rabbitmq/lib/rabbitmq_server-3.6.10/sbin
```

2、启动服务

```bash
./rabbitmq-server -detached #-detached后台启动 不占用terminal进程
```

验证服务是否启动成功

```bash
ps -ef|grep rabbitmq
```

出现下图标识成功
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201127162649691.png)
启动管理界面

```bash
./rabbitmq-plugins enable rabbitmq_management #启动管理界面
```

在浏览器内地址栏：输入 主机IP:15672 访问打开页面
用户名：guest
密码：guest
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201127162829962.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzI4NDE4ODg3,size_16,color_FFFFFF,t_70)

## 三、 RabbitMQ 常用命令

1、cd 到安装目录sbin 文件夹

```bash
cd /usr/lib/rabbitmq/lib/rabbitmq_server-3.6.10/sbin
```

2、运行以下命令

```bash
  启动: rabbitmq-server –detached
  关闭:rabbitmqctl stop
```

