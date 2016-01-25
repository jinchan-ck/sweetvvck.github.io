---
title: '[原]设计高可用Web服务'
tags: [Web 架构]
date: 2014-12-28 23:22:03
---



转载请注明出处：[设计高可用Web服务](http://blog.csdn.net/sweetvvck/article/details/42222429)




高可用的设计可以说是web服务架构的目标，如果服务达不到高可用，万一出现故障将会对产品带来重大的负面影响。高可用的架构就是能够让服务在任何情况下都能正常响应，比如双十一的淘宝，面对激增的洪峰照样正常工作；而聚美三周年时服务器的宕机恰好是高可用的反例。




**什么是高可用**




*   可用性：在应用工作周期中可用时间的百分比
*   不可用：应用无法访问，服务中断应用访问非常缓慢
*   高可用：服务一直正常可用，快速响应




**Tags**




*   SPoF：单点故障

*   Failover：故障转移
*   Disaster Recovery：灾难恢复
*   Load Balancing：负载均衡
*   …...




说到高可用，我们常常会提到上面这些标签，也是设计高可用服务需要考虑和解决的点。下面我们来看看如何设计一个高可用的架构，如何来解决上面的问题，实现高可用。




**如何设计**




在服务架构时，我们不能相信任何一个环节是100%没问题的，服务的每个层级，使用的数据库，缓存，甚至是服务器本身，服务器放置的机房这些硬件环节都不能完全相信。如果我们假设每个环节都有可能出现问题，在每个环节出现问题时都有方案应对，那么这样设计出来的服务一定就是高可用的了。上面这种考虑问题的方式我们称为“假定失效原则”，在设计服务架构时，我们就要坚持这一原则。




下面我以一个例子从浅入深的为大家讲解如何设计高可用服务：




在服务搭建初期，其实并不需要考虑太多，目标是将服务快速搭建，完成功能，验证产品；我们的架构可能是这样的：


![](http://img.blog.csdn.net/20141229004215515?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")



但是，与高可用的标准相比，这样的设计最大最直接的问题显而易见。我们可以看到整个架构就只有一个web&nbsp;server和一个数据库，那么要是它们之中任意一个无法访问，整个服务就瘫痪了；这样的故障，我们称之为SPoF—单点故障。

单点故障可难不倒我们，采用分布式架构，web server放置在不同的数据中心，同时数据库做主备或者复制集；这样就解决了单点故障，此时的架构应该是这样的：


![](http://img.blog.csdn.net/20141229004231609?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")



在这样的架构中，我们将用户的请求通过一个代理（只能做简单的分发）分发到处于不同数据中心的web&nbsp;server上解决了单点故障。可是另一个问题又来了，如果其中一个数据中心的web server无法访问，虽然另一个web server能够正常工作，但是仍然会有部分请求发送到故障的机器上，整体来说仍然不能达到高可用。面对这样的问题，我们的第一反应是是否能够让请求不要再转发到故障的机器呢？




答案是肯定的，这种做法叫failover—故障转移，与failover经常一起出现的还有一种设计方案叫灾难恢复，它们常常一起使用。要达到的效果是，代理发现某台服务器无法访问，便不将请求发往这台机器，同时会启动另外一台机器，当这台机器完成初始化便将部分请求发往新的机器上。此时的架构应该是这样的：


![](http://img.blog.csdn.net/20141229004242666?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")


![](http://img.blog.csdn.net/20141229004301090?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")






通过上面的设计，我们离高可用又近了一步，但是仍然不能说是高可用的设计。试想，现在我们的服务都是多数据中心的了，而且能够进行故障转移和灾难恢复；然而，如果我们的web server并没有出现故障，能够被访问并且响应请求，但是响应速度非常的慢，每次请求都要过很久才能返回，原因可能是请求量太大，导致机器资源消耗严重无法正常响应。我们前面说过，当一个服务不能够正常的响应，就算它能够处理请求，也算是不可用。




那么遇到这种情况该怎么处理呢？这里我需要引入一个新的概念：Scaling—伸缩。这个概念在云服务中经常能够看到，AWS，Google cloud都号称自己的计算服务是Auto&nbsp;Scaling的，意思是他们的服务能够自动伸缩，这正是我们解决上述问题的关键。




我们希望达到的效果是：当web server资源（CPU，内存等）消耗达到很高的&#20540;时，我们能够启动新的web server缓解压力；与此同时，当过了高峰期，请求量降到很低时，我们能够关闭掉多余的服务器，不至于造成资源浪费。此时的架构应该是这样的：


![](http://img.blog.csdn.net/20141229004324084?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")


![](http://img.blog.csdn.net/20141229004345937?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")




![](http://img.blog.csdn.net/20141229004405234?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")


![](http://img.blog.csdn.net/20141229004420296?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")




![](http://img.blog.csdn.net/20141229004433156?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "下载")[](https://app.yinxiang.com/shard/s18/sh/92a8e772-0432-4c4f-bbdd-ba4a449bd9fe/83b1eea9519c0456?content=# "图片集")



通过上面的设计，这样的架构我们已经基本上可以称之为高可用的了。我们对每个环节都作了考虑，出现的问题也有了相应的处理方案，让服务保持一直可用——高可用。







**总结**




*   Cluster/Distributed
*   HA&nbsp;Proxy(Load Balancing, Failover etc.)
*   Auto Scaling




我们如果能够做好上面的三点，那么搭建一个高可用的架构就不是什么难事了，虽然上面三点都是难点 :p

后面的文章中将逐个讲解难点的攻破与实现，搭建高可用web服务。







**参考资料**





*   AWS官网：[http://aws.amazon.com](http://aws.amazon.com/)
*   AWS参考架构：[http://aws.amazon.com/architecture](http://aws.amazon.com/architecture/)

*   [](http://aws.amazon.com/architecture/)


                作者：sweetvvck 发表于2014/12/28 23:22:03 [原文链接](http://blog.csdn.net/sweetvvck/article/details/42222429)


            阅读：1071 评论：8 [查看评论](http://blog.csdn.net/sweetvvck/article/details/42222429#comments)
