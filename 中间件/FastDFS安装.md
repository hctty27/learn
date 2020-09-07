# FastDFS安装

## 环境准备

1. FastDFS_v5.05.tar.gz （FastDFS安装包）
2. libfastcommonV1.0.7.tar.gz （FastDFS依赖程序）
3. nginx-1.8.0.tar.gz （nginx安装包,用于做文件请求http代理服务器）
4. fastdfs-nginx-module_v1.16.tar.gz （nginx和fastdfs的桥梁插件模块）

## 1.C/C++ 编译环境

```powershell
yum -y install gcc gcc-c++
```

## 2.安装 libfastcommon

```powershell
cd /usr/local/src
# 解压
tar -zxf    libfastcommonV1.0.7.tar.gz
cd libfastcommon-1.0.7
#编译
./make.sh
#安装
./make.sh install
```

**注意：** 由于FastDFS程序引用usr/lib目录所以需要将/usr/lib64下的库文件拷贝至/usr/lib下

```powershell
cp /usr/lib64/libfastcommon.so /usr/lib
```

## 4.创建数据存储目录

**说明**：后面各个服务 配置文件制定的文件夹

```powershell
mkdir -p
# tracker  追踪服务
/usr/local/FastDFS/tracker  
# storage 文件存储
/usr/local/FastDFS/storage 
# client 客户端
/usr/local/FastDFS/client
```

## 5.安装FastDFS

```powershell
cd /usr/local/src
tar -zxf FastDFS_v5.05.tar.gz
cd FastDFS
./make.sh
./make.sh install
cd conf
# 安装成功将安装目录下的conf下的文件拷贝到/etc/fdfs/下
cp * /etc/fdfs
```

## 6.配置Tracker（追踪服务器）

```powershell
vim  /etc/fdfs/tracker.conf
#和你上面创建的文件夹一致
base_path=/usr/local/FastDFS/tracker
```

**启动：**

```powershell
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf
```

**查看状态：**

```powershell
netstat -apn|grep fdfs
```

## 7.配置Storage（数据存储）

```powershell
vim /etc/fdfs/storage.conf

base_path=/usr/local/FastDFS/storage
## 你创建的数据存储目录
store_path0=/usr/local/FastDFS/storage
## 换成你的ip 记得开放这个端口：22122
tracker_server = 192.168.100.151:22122 #这个ip可能需要换成服务器内网ip，不然启动不了
```

**启动：**

```powershell
usr/bin/fdfs_storaged /etc/fdfs/storage.conf
```

## 8.配置测试

**注意：** 开放22122、23000端口 我这里是云服务器在安全组里配置
![image-20200907160236726](C:\Users\vlink\AppData\Roaming\Typora\typora-user-images\image-20200907160236726.png)

**从编译完的FastDFS目录复制libfastclient.so 到/usr/lib目录**

```powershell
cd /usr/local/src/FastDFS/client

cp libfdfsclient.so /usr/lib
```

**修改客户端连接文件**

```powershell
vi /etc/fdfs/client.conf
#上面自己创建的文件夹
base_path=/usr/local/FastDFS/client
#换成你自己的ip
tracker_server=192.168.100.151:22122
```

测试上传：

```powershell
/usr/bin/fdfs_test /etc/fdfs/client.conf upload xxx.png
```

## 9.安装 Fastdfs-nginx-module

```powershell
 yum install -y gcc-c++  

 yum install -y pcre pcre-devel

 yum install -y zlib zlib-devel

 yum install -y openssl openssl-devel
```

**解压:**

```powershell
cd /usr/local/src

tar -zxf fastdfs-nginx-module_v1.16.tar.gz
```

**修改config文件 把‘local’ 去掉即可**

```powershell
vim  fastdfs-nginx-module/src/config

CORE_INCS="$CORE_INCS /usr/local/include/fastdfs /usr/include/fastcommon/"
修改为：CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"

CORE_LIBS="$CORE_LIBS -L/usr/local/lib -lfastcommon -lfdfsclient"
修改为：CORE_LIBS="$CORE_LIBS -L/usr/lib -lfastcommon -lfdfsclient"
```

**复制fastdfs-nginx-module/src/mod_fastdfs.conf 到/etc/fdfs目录下**

```powershell
tracker_server=192.168.100.151:22122

url_have_group_name = true

storage_server_port=23000

group_name=group1
## 你的文件存储目录
store_path0=/usr/local/FastDFS/storage
```

## 10.安装 Nginx

###### 备注：如果之前安装了Nginx，需要配置编译之前的安装包添加模块进去再覆盖Nginx文件

**用于HTTP直接获取FastDFS服务器中的文件**

```powershell
cd /usr/local/src

tar -zxf  nginx-1.8.0.tar.gz

cd nginx-1.8.0

./configure --add-module=/usr/local/src/fastdfs-nginx-module/src/

make

make install
```

**配置：**

```powershell
cd /usr/local/nginx/conf

vim nginx.conf
```

**配置内容:**

```powershell
server{
    listen     9999;
    server_name     localhost;
    location /group1/M00/{
        ngx_fastdfs_module;
    }
}
```

**启动Nginx**

```powershell
cd /usr/local/nginx/sbin
./nginx
```

# 11.常用命令

```powershell
启动追踪服务 /usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf

启动数据存储 /usr/bin/fdfs_storaged /etc/fdfs/storage.conf

测试上传 /usr/bin/fdfs_test /etc/fdfs/client.conf upload xxx.png
```

