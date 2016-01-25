---
title: '[译]Twemproxy来自Twitter的Redis代理'
tags: [Redis, Twemproxy]
date: 2014-12-31 22:35:41
---

在大量用户大规模使用大型Redis节点的时候，目前从项目本身来看Redis基本上可以说是一个单例的业务。

关于这个项目的分布式我有一个很大的想法，在这个想法下，我不需要去对多线程版本的Redis做任何评估：在这个角度上对我来说，一个核就像是一台计算机，所以在多核上扩展就相当于分布在计算机之间的集群。多实例是一个无共享的架构。如果我们找到一个可用的方式来分片，那么所有事情就合理了。 :-)

这也是为什么集群会成为Redis在2013年的焦点，并且，最终Redis 2.6的发布表现出了很好的稳定性和成熟度，现在正是时候来关注Redis Cluster, Redis Sentinel, 以及一些其它期待已久的改进。

然而现实状况是，Redis Cluster目前仍然没有发布，正式版还需要几个月的工作。但是我们的用户已经需要将数据分片到不同的实例上来做负载均衡，更重要的是为数据获得更大的内存存储。

目前保底的结局方案是客户端分片。客户端分片有很多好处，例如：在客户端和节点之间没有中间层，这就意味着它是一个扩展性很好的设置（主要是线性扩展）。然而要稳定的实现（客户端分片）需要进行一些优化，需要一个同步客户端配置的方式，也需要客户端支持一致性哈希或其它分区算法。

有一个重大消息来自Twitter，世界最大的Redis集群之一部署在Twitter用于为用户提供时间轴数据。所以毫不奇怪这篇文章讨论的项目来自Twitter Open Source部门。

Twemproxy
---

Twemproxy是一个快速的单线程代理程序，支持Memcached ASCII协议和更新的Redis协议：&nbsp;

它全部用C写成，使用Apache 2.0 License授权。&nbsp;
项目在Linux上可以工作，而在OSX上无法编译，因为它依赖了epoll API.
我的测试环境为Ubuntu 12.04桌面版。&nbsp;

好吧，闲话少叙。twemproxy到底做了什么？（注：我将关注Redis到部分，但是该项目也可以对memcached做相同到事情）&nbsp;

1) 在客户端和众多Redis实例间作为代理。&nbsp;
2) 在配置的Redis实例之间进行自动到数据分片。&nbsp;
3) 支持一致性哈希，支持不同到策略和哈希方法。&nbsp;

Twemproxy最了不起的地方就在于它能在节点失败的时候卸载它，然后可以在一段时间以后重新尝试（随即）连接，又或者可以严&#26684;按照配置文件中写的键与服务器之间对应关系进行连接。这意味着Twemproxy能胜任把Redis当做数据存储（不能容忍节点未命中）的场景，也能够胜任当做缓存来使用，那些允许（它意味着少量，不是说低质量）未命中且高可用的场景。
总结来说就是：如果你能容忍未命中，那么当有节点失败你的数据也许会存储到其他节点，所以它会是弱一致性的。另一方面，如果你不能容忍未命中，那么你需要一个拥有高可用的实例的方案，例如使用Redis监控的失败自动切换功能。

安装 &nbsp;
---&nbsp;

在深入项目的更多特性之前，有一个好消息，它在Linux上非常容易构建。好吧，没有Redis那么简单，但是……你仅仅需要简单按照下面的几步操作：
apt-get install automake&nbsp;
apt-get install libtool&nbsp;
git clone git://github.com/twitter/twemproxy.git&nbsp;
cd twemproxy&nbsp;
autoreconf -fvi&nbsp;
./configure --enable-debug=log&nbsp;
make&nbsp;
src/nutcracker -h&nbsp;

它的配置也非常简单，在项目的github页面上有足够的文档可以让你有一个平滑的初体验。我使用了如下的配置：
redis1:&nbsp;
&nbsp; listen: 0.0.0.0:9999&nbsp;
&nbsp; redis: true&nbsp;
&nbsp; hash: fnv1a_64&nbsp;
&nbsp; distribution: ketama&nbsp;
&nbsp; auto_eject_hosts: true&nbsp;
&nbsp; timeout: 400&nbsp;
&nbsp; server_retry_timeout: 2000&nbsp;
&nbsp; server_failure_limit: 1&nbsp;
&nbsp; servers:&nbsp;
&nbsp; &nbsp;- 127.0.0.1:6379:1&nbsp;
&nbsp; &nbsp;- 127.0.0.1:6380:1&nbsp;
&nbsp; &nbsp;- 127.0.0.1:6381:1&nbsp;
&nbsp; &nbsp;- 127.0.0.1:6382:1&nbsp;

redis2:&nbsp;
&nbsp; listen: 0.0.0.0:10000&nbsp;
&nbsp; redis: true&nbsp;
&nbsp; hash: fnv1a_64&nbsp;
&nbsp; distribution: ketama&nbsp;
&nbsp; auto_eject_hosts: false&nbsp;
&nbsp; timeout: 400&nbsp;
&nbsp; servers:&nbsp;
&nbsp; &nbsp;- 127.0.0.1:6379:1&nbsp;
&nbsp; &nbsp;- 127.0.0.1:6380:1&nbsp;
&nbsp; &nbsp;- 127.0.0.1:6381:1&nbsp;
&nbsp; &nbsp;- 127.0.0.1:6382:1&nbsp;

第一个集群配置为（故障时）节点自动排除，第二个集群则在所有实例上配置了静态映射。&nbsp;

有趣的是，针对同一组服务器你能同时有多个部署。然而在生产环境更适合使用多个示例以利用多核的能力。

单点失效？&nbsp;
---&nbsp;

还有另一件有趣的事情，使用这个部署并不意味着有单点失效问题，你可以通过运行多套twemproxy，让你的客户端连接到第一个可用的实例。&nbsp;

通过使用twemproxy你基本上把分片逻辑和客户端进行了分离。在这种情况下，一个基本的客户端就可以实现目的，分片将完全由代理来处理。
这是一个直接而安全的方法，个人观点。
现在Redis Cluster还不成熟，twemproxy是大多数希望利用Redis集群的用户的好方法。也不要太激动，先看看这种方法的限制 ;)

不足
---
我认为Twemproxy没有支持批量操作的命令和事物是对的。当然，AFAIK甚至比Redis cluster更严&#26684;，反而它对于相同的键允许批量操作。
但是恕我直言按照这种方式，分散的集群带来分散的效率，并且将这个挑战带给了早期的用户，而且花费了大量的资源，从大量的实例中汇总数据，得到仅仅是“能用”的结果，而且你将很快开始有严重的负载问题，因为你有太多的时间花费在数据的传输上。

可是有一些批量操作命令还是支持了的。MGET和DEL是处理的非常好的。有趣的是MGET命令在不同的服务器之间切分请求并且返回一个结果。这一点相当酷，也许我以后不能有更好的性能（看以后的吧）。
无论如何，批量操作和事物的不支持的现状意味着Twemproxy不适用于每个人，特别像Redis cluster本身。特别是它显然不支持EVAL（我认为他们应该支持它！它是多通用的，EVAL被设计可以在代理中工作，是因为键的名字已经明确了）。

有待改进的地方
---
错误报告机制并不稳定，发送一个Redis不支持的命令会导致连接被关闭。比如从redis-cli只发送一个‘GET‘并不会报&quot;参数个数不正确”的错误，只会导致连接被挂起。
总体看来，服务器返回的其它错误都可以准确的传给客户端：
redis metal: 10000 &gt; get list
(错误)类型操作错误，键匹配了错误的&#20540;类型
另外一个我想要看到的特性是对自动故障恢复的支持。有很多种替代方案：
1) twemproxy已经能够监控实例错误信息、错误的数量、在检测出足够多的错误的情况下断开节点。但是很遗憾twemproxy不能够拿从节点作为替代方案，这样就可以发送一个SLAVE OFNOONE命令来弃用备用节点，而不用只是断开错误节点。这种情况下twemproxy才是一个具有高可用性的解决方案。
2) 或者，我希望twemproxy能够与Redis Sentinel一起协同工作，定期检查Sentinel配置，如果出现故障则更新服务端配置
3) 另外一种替代方案是提供一种热配置twemproxy的方式，一旦节点出故障，Redis Sentinel就能够切换ASAP代理配置
有很多种替代方案，总体来说，如果能够提供对HA(高可用性)的底层支持就非常棒了。

性能&nbsp;
---
Twemproxy很快，真的很快，接近直接与Redis通讯的速度。我敢说你用的话最多损失20%的性能。
我对性能唯一的意见是可以有更高效的方法把IMHO MGET命令分发到实例之间
如果twemproxy与所有Redis实例的延迟很相&#20284;的话(很有可能)，在MGETs命令在同一时间发出的情况下，twemproxy很有可能会在同一时间接收到所有节点的命令，所以我希望看到的是当我在所有实例上运行MGET命令的时候，发送的数量和twemproxy接收到的数量是一致的，但是实际上twemproxy在一秒内只接收到了50%的MGET命令。也许是时候重构twemproxy的应答模块了。

结论
---
这是个伟大的项目，鉴于Redis Cluster还未发布，我强烈建议有需求的Redis用户试一下Twemproxy
我正打算将它链接到Redis项目网站上，因为我认为Twitter的伙计已经用他们的项目为Redis做了不小的贡献，所以...
这是Twitter赢得荣誉！


                作者：sweetvvck 发表于2014/12/31 22:35:41 [原文链接](http://blog.csdn.net/sweetvvck/article/details/42302675)


            阅读：1373 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/42302675#comments)
