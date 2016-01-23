---
title: '[原]Zookeeper集群搭建'
tags: []
date: 2014-08-26 10:05:51
---

<span style="font-size:14px">Zookeeper是Apache的一个开源项目，在集群管理中十分常用。它的集群搭建也十分简单，只需要简单的配置，集群的各个节点会完成自行通讯，自动选取Leader等。</span>

<span style="font-size:14px">更多关于zookeeper的信息和原理，可以参考这篇博文：[ZooKeeper原理及使用](http://blog.csdn.net/sweetvvck/article/details/38262965)</span>

<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">

</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
Zookeeper的单机模式更加简单：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
&nbsp; &nbsp; &nbsp; 在Ubuntu系统下，只需要执行sudo apt-get install zookeeper安装，然后到安装目录下找到zkServer.sh脚本，执行./zkServer.sh start就启动了zookeeper的单机模式，通过这种方式安装的zookeeper的目录通常是/usr/share/zookeeper/。通过执行zkServer.sh status可以看到zookeeper的运行状态，这里使用的是单机模式，则会显示：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">JMX enabled by default
Using config: /etc/zookeeper/conf/zoo.cfg
Mode: standalone</pre></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
&nbsp; &nbsp; &nbsp; 如果是在其他的Linux系统（CentOS）上，执行：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
tar zxf zookeeper-3.4.6.tar.gz
cd zookeeper-3.4.6/conf/</pre></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
这个目录下有一个zoo_sample.cfg文件，是官方提供的示例配置，执行：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">cp ./zoo_sample.cfg zoo.cfg</pre></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
复制一份示例配置，改名为zoo.cfg，启动zookeeper：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">../bin/zkServer.sh start</pre>

</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">

</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
下面我们来尝试一下搭建zookeeper集群，由于机器有限，我采用在一台机器上搭建伪集群的方式来搭建集群。</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
zookeeper官方推荐集群的节点数要是奇数，因此我们这里准备搭建3个节点的集群。</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
首先，创建三个文件夹分别表示三个节点：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">mkdir server0
mkdir server1
mkdir server2</pre>

</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
然后将下载好的zookeeper文件解压到每个目录下：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">tar xzvf zookeeper-3.4.6.tar.gz -C ./server0/
tar xzvf zookeeper-3.4.6.tar.gz -C ./server1/
tar xzvf zookeeper-3.4.6.tar.gz -C ./server2/</pre></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<span style="line-height:1.428571em">同时更改目录名称：</span></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">mv ./server0/zookeeper-3.4.6 ./server0/zookeeper
mv ./server1/zookeeper-3.4.6 ./server1/zookeeper
mv ./server2/zookeeper-3.4.6 ./server2/zookeeper</pre>

</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
然后进入到每个节点的zookeeper目录下，分别创建data目录以及logs目录：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">mkdir data
mkdir logs</pre>

</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
然后在data目录下创建myid文件，内容为当前节点的序号，如0,1,2：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">vim ./data/myid</pre></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
填入序号，保存；</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
接下来进入conf目录创建zoo.cfg文件：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">vim ./zoo.cfg</pre></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
内容按下面方式填写：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
tickTime=2000&nbsp;

initLimit=5&nbsp;

syncLimit=2&nbsp;

dataDir=/opt/<span style="color:#ff0000">server0</span>/zookeeper/data&nbsp;

dataLogDir=/opt/<span style="color:#ff0000">server0</span>/zookeeper/logs&nbsp;

clientPort=<span style="color:#ff0000">2180</span>

server.0=127.0.0.1:8880:7770&nbsp;

server.1=127.0.0.1:8881:7771&nbsp;

server.2=127.0.0.1:8882:7772

</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
其中标红的部分要根据当前节点序号进行修改，例如当前在server0目录下，则按照上面的配置填写，然后保存。</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
填写完配置后就可以启动zookeeper了：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">./bin/zkServer.sh start</pre></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
然后在另外两个节点的目录下重复上述操作，伪集群就搭建好啦。</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
通过./bin/zkServer.sh status可以看到当前节点在集群中的角色，显示如下：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">JMX enabled by default
Using config: /opt/zookeeper/server0/zookeeper/bin/../conf/zoo.cfg
Mode: follower</pre></div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
通过./bin/zkCli.sh -server host:port的方式能够指定任一一个节点访问到集群：</div>
<div style="margin:0px; padding:0px; border:0px; line-height:1.428571em; font-family:Helvetica,Arial,'Droid Sans',sans-serif; font-size:14px">
<pre name="code" class="plain">./bin/zkCli.sh -server 127.0.0.1:2181</pre></div>
<div>

</div>
<div>

</div>

            <div>
                作者：sweetvvck 发表于2014/8/26 10:05:51 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38842665)
            </div>
            <div>
            阅读：1153 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38842665#comments)
            </div>