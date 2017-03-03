---
title: Javascript 工作原理
date: 2016-08-01 11:30:11
tags: [Javascript, V8, 运行时环境, NodeJs]
categories: [编程语言, Javascript]
---



## Javascript 定义
+ 单线程
+ 异步 IO
+ 并发
+ 基于原型的面线对象
+ 脚本语言

## Javascript 引擎与运行时环境
Javascript 引擎和运行时环境这两个概念很容易被弄混，但它俩真不是一个东西。Javascript 引擎做的事情是实现 ECMAScript 标准，解释（或编译） Javascript 代码；而运行环境是包括引擎并提供一些类库让 Javascript 代码能够在其上运行，例如 Chrome, Node。
<!--more-->
## 为什么设计为单线程？
> JavaScript语言的一大特点就是单线程，也就是说，同一个时间只能做一件事。那么，为什么JavaScript不能有多个线程呢？这样能提高效率啊。
JavaScript的单线程，与它的用途有关。作为浏览器脚本语言，JavaScript的主要用途是与用户互动，以及操作DOM。这决定了它只能是单线程，否则会带来很复杂的同步问题。比如，假定JavaScript同时有两个线程，一个线程在某个DOM节点上添加内容，另一个线程删除了这个节点，这时浏览器应该以哪个线程为准？
所以，为了避免复杂性，从一诞生，JavaScript就是单线程，这已经成了这门语言的核心特征，将来也不会改变。
为了利用多核CPU的计算能力，HTML5提出Web Worker标准，允许JavaScript脚本创建多个线程，但是子线程完全受主线程控制，且不得操作DOM。所以，这个新标准并没有改变JavaScript单线程的本质。
> 摘自 http://www.ruanyifeng.com/blog/2014/10/event-loop.html

## 单线程如何异步，如何并发？
我们知道，在一段程序代码中发起一个调用并等待直到调用返回结果再执行接下来的代码，这个调用对于这段程序来说是同步的；而发起一个调用后不用等待调用结果而直接执行后面的代码，这个调用对于这段程序来说就是异步的。

异步意味着在主逻辑中被异步调用的代码和主逻辑继续执行的代码会同时执行，这其实是实现了并发。回想一下我们在 Java 或者其它多线程语言中是如何实现异步的，一般来说，要创建一个异步任务，我们通常会创建一个线程然后在线程中执行该任务，这个任务和创建它的线程就可以并发执行了。但 Javascript 单线程的特性显然和这异步、并发是有冲突的，那么为什么说 Javascript 支持异步，支持并发呢？

其实理解起来也很简单，Javascript 本身并不是异步的，而 Javascript 程序是异步的。具体来说就是，Javascript 编写的代码自身运行于单线程中，当遇到 IO 调用，就把它丢给运行时环境处理，自身继续执行后面的代码，当 IO 调用有了结果，会将结果及回调放在一个队列里，Javascript 线程会在合适的时机将回调函数取出并执行。

Javascript 程序的异步由其运行时环境提供，通过`event loop`实现异步编程，并提供并发支持。

实现异步编程可以有很多种方式(`编程模型`)，想了解更多可以先看看[这篇文章](http://www.jianshu.com/p/c4dc7866eb81)。

## Javascript 具体是如何工作的
单说`Javascript 是如何工作的`其实不太准确，应该说`Javascript 在其运行时环境上是如何工作的`才对，Node 和 Chrome 都是 Javascript 的运行时环境，它们使用相同的  JavaScript 引擎(V8)，都应用基于 `event loop` 的并发模型( Chrome 内核使用了 libevent 而 Node 则基于 libuv )，那么 Javascript 在这样的运行时环境下是如何工作的呢？

是时候祭出这张图了
![](https://pub.int64ago.org/5couq20oh7kfu8ebqpvi.png)
> 此图来自Philip Roberts的演讲[《Help, I'm stuck in an event-loop》](http://vimeo.com/96425312)

这张图讲的是 Javascript 在浏览器中的工作原理，在 Node 中也差不多，很具有代表性。

**看图说话**
1. V8 在编译执行 Javascript 代码过程中会生成堆( heap ) 和栈 ( stack )，heap 存放的程序运行过程中产生的一些对象，stack 是 Javascript 执行栈，程序代码会根据调用关系被压入栈中执行；
2. 当遇到调用 WebAPIs（IO 或者 定时器）时，浏览器会响应调用并直接返回，stack 继续执行剩余 Javascript 代码；
3. 当 WebAPIs 调用完成，会将相应的回调与结果依次放入 `callback queue` 中；
4. 当执行栈中如果没有要执行的 Javascript 代码，则会通过 `event loop` 检查并取出 `callback queue` 中第一个回调函数，并执行它。

这样，我们所编写的 Javascript 代码会在`执行引擎`的执行栈中以单线程的方式运行，而所有 IO 或定时任务会通过运行环境异步执行，并将执行结果放在 `callback queue` 中等待被调用，这就是所谓的单线程异步的工作原理，当然  Javascript 实际运行环境的实现会比这复杂一些，但基本原理就是这样；理解这个原理能够让我们更加清楚我们的每一段代码在运行环境中是如何执行的，有很多疑惑例如：程序代码中的多个回调会在什么时候被调用？为什么复杂的计算逻辑要使用 `setImmediate(function () { // 计算逻辑 }); 或 process.nextTick(function () { // 计算逻辑 });` 包起来？就容易理解了。

## 小结
本文主要解释了 Javascript 作为单线程语言，其程序是如何实现异步的，同时也大概讲解了 Javascript 在其运行时环境中的工作原理；在解惑的同时也带来了一些疑惑：

+ `setImmediate 和 process.nextTick` 的区别是什么？
+ 既然 Javascript 程序也是通过(运行时环境)底层的多线程实现异步，那跟多线程语言实现的异步有什么不同？
+ 为什么说基于 `Event loop` 实现异步编程模型的 `Node` 更适合 IO 密集型的应用，底层不都是多线程吗？

这些问题也是我在做 Javascript 开发不同阶段中真真实实遇到的疑惑，通过自己一步一步的探索得到了一些解释，希望也能帮到正遇到这些疑惑的朋友们，如有问题，请指出。

篇幅原因（才怪，因为懒）这些疑惑下一篇再来探讨。

## 参考
[朴灵评注-JavaScript 运行机制详解：再谈Event Loop](http://blog.csdn.net/lin_credible/article/details/40143961)
[Help, I'm stuck in an event-loop](http://vimeo.com/96425312)  
[并发模型与Event Loop](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/EventLoop)
[关于node.js的误会](http://www.cnblogs.com/dolphinX/p/3475090.html)  
[通过什么途径能够深入了解JavaScript解析引擎是如何工作的？](https://github.com/goddyZhao/GPosts/blob/master/javascript/%E9%80%9A%E8%BF%87%E4%BB%80%E4%B9%88%E9%80%94%E5%BE%84%E8%83%BD%E5%A4%9F%E6%B7%B1%E5%85%A5%E4%BA%86%E8%A7%A3JavaScript%E8%A7%A3%E6%9E%90%E5%BC%95%E6%93%8E%E6%98%AF%E5%A6%82%E4%BD%95%E5%B7%A5%E4%BD%9C%E7%9A%84%EF%BC%9F.md)  
[nodejs异步IO的实现](https://cnodejs.org/topic/4f16442ccae1f4aa2700113b)


<!--有没有真正的异步编程模型-->
