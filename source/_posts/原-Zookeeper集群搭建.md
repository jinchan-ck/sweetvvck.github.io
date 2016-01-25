---
title: '[原]Zookeeper集群搭建'
tags: [zookeeper]
categories: [运维, 架构]
date: 2014-08-26 10:05:51
---

Zookeeper是Apache的一个开源项目，在集群管理中十分常用。它的集群搭建也十分简单，只需要简单的配置，集群的各个节点会完成自行通讯，自动选取Leader等。

更多关于zookeeper的信息和原理，可以参考这篇博文：[ZooKeeper原理及使用](http://blog.csdn.net/sweetvvck/article/details/38262965)





Zookeeper的单机模式更加简单：

&nbsp; &nbsp; &nbsp; 在Ubuntu系统下，只需要执行sudo apt-get install zookeeper安装，然后到安装目录下找到zkServer.sh脚本，执行./zkServer.sh start就启动了zookeeper的单机模式，通过这种方式安装的zookeeper的目录通常是/usr/share/zookeeper/。通过执行zkServer.sh status可以看到zookeeper的运行状态，这里使用的是单机模式，则会显示：

JMX enabled by default
Using config: /etc/zookeeper/conf/zoo.cfg
Mode: standalone

&nbsp; &nbsp; &nbsp; 如果是在其他的Linux系统（CentOS）上，执行：

wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
tar zxf zookeeper-3.4.6.tar.gz
cd zookeeper-3.4.6/conf/

这个目录下有一个zoo_sample.cfg文件，是官方提供的示例配置，执行：

cp ./zoo_sample.cfg zoo.cfg

复制一份示例配置，改名为zoo.cfg，启动zookeeper：

../bin/zkServer.sh start






下面我们来尝试一下搭建zookeeper集群，由于机器有限，我采用在一台机器上搭建伪集群的方式来搭建集群。

zookeeper官方推荐集群的节点数要是奇数，因此我们这里准备搭建3个节点的集群。

首先，创建三个文件夹分别表示三个节点：

mkdir server0
mkdir server1
mkdir server2



然后将下载好的zookeeper文件解压到每个目录下：

tar xzvf zookeeper-3.4.6.tar.gz -C ./server0/
tar xzvf zookeeper-3.4.6.tar.gz -C ./server1/
tar xzvf zookeeper-3.4.6.tar.gz -C ./server2/

同时更改目录名称：

mv ./server0/zookeeper-3.4.6 ./server0/zookeeper
mv ./server1/zookeeper-3.4.6 ./server1/zookeeper
mv ./server2/zookeeper-3.4.6 ./server2/zookeeper



然后进入到每个节点的zookeeper目录下，分别创建data目录以及logs目录：

mkdir data
mkdir logs



然后在data目录下创建myid文件，内容为当前节点的序号，如0,1,2：

vim ./data/myid

填入序号，保存；

接下来进入conf目录创建zoo.cfg文件：

vim ./zoo.cfg

内容按下面方式填写：

tickTime=2000&nbsp;

initLimit=5&nbsp;

syncLimit=2&nbsp;

dataDir=/opt/server0/zookeeper/data&nbsp;

dataLogDir=/opt/server0/zookeeper/logs&nbsp;

clientPort=2180

server.0=127.0.0.1:8880:7770&nbsp;

server.1=127.0.0.1:8881:7771&nbsp;

server.2=127.0.0.1:8882:7772



其中标红的部分要根据当前节点序号进行修改，例如当前在server0目录下，则按照上面的配置填写，然后保存。

填写完配置后就可以启动zookeeper了：

./bin/zkServer.sh start

然后在另外两个节点的目录下重复上述操作，伪集群就搭建好啦。

通过./bin/zkServer.sh status可以看到当前节点在集群中的角色，显示如下：

JMX enabled by default
Using config: /opt/zookeeper/server0/zookeeper/bin/../conf/zoo.cfg
Mode: follower

通过./bin/zkCli.sh -server host:port的方式能够指定任一一个节点访问到集群：

./bin/zkCli.sh -server 127.0.0.1:2181








                作者：sweetvvck 发表于2014/8/26 10:05:51 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38842665)


            阅读：1153 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38842665#comments)
