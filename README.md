lixian-portal
=============

给`iambus/xunlei-lixian`做的一个简洁实用的gui。

# 这是啥

我也不知道这是啥，见下一章说明吧

# 典型使用场景

1. 家里有个连着移动硬盘的树莓派
2. 我平常刷微博时发现先几个好看的电影，和想玩的游戏，然后再xxx上找到这些电影和游戏的ed2k链接，然后输入进去
3. 周末我通过smb文件共享打开树莓派里已经下好的电影和游戏，看之且玩之
4. 室友也可以看（如果有室友的话）

# 界面预览

![http://ww3.sinaimg.cn/large/7a464815jw1e5klmtnyu6j20zk0m8my3.jpg](http://ww3.sinaimg.cn/large/7a464815jw1e5klmtnyu6j20zk0m8my3.jpg)

![http://ww3.sinaimg.cn/large/7a464815jw1e5kln13fotj20zk0m8myv.jpg](http://ww3.sinaimg.cn/large/7a464815jw1e5kln13fotj20zk0m8myv.jpg)

# 环境

* linux/osx （对不起了windows）
* python2
* nodejs

# 安装方法

## 安装

```bash
sudo npm install lixian-portal -g
```

## 设置daemon

* 每个系统的daemon管理器不一样，所以……（此处省略好多字）
* 首先通过命令`which lixian-portal`看一看安装后的具体路径是啥
* 然后该路径就是启动的脚本了
* 下载的位置为当前目录（current working directory），所以daemonize时注意调整
* 必须要有HOME变量，（给iambus/xunlei-lixian存放偏好文件）


