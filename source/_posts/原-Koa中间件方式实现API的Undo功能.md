---
title: '[原]Koa中间件方式实现API的Undo功能'
tags: [koa, api ,undo]
date: 2015-05-08 23:12:05
---

# Koa中间件方式实现API的Undo功能

##  API的Undo功能

使用过Gmail或者163邮箱的同学会经常看到，当对邮件进行一些操作时会出现一个类似Toast的提示（大致意思是：操作已经完成，是否撤销）如下图所示：

![](http://img.blog.csdn.net/20150508220504487)

![](http://img.blog.csdn.net/20150508220843186)

当点击撤销时，之前执行的操作能够被还原，这种设计对于用户的误操作是一个非常棒的补救方案。

之前听过一句有关交互设计的话说的非常好，不要在用户每做一步操作时弹出Alert让用户选择”确定”或者”取消”，更好的做法是执行操作，然后让用户能够Undo。

##  实现API Undo的方案

其实Undo是很老的技术，在编辑器中无处不在，只是在API设计中使用的还比较少。最近一直在使用Node开发，因此想使用Node实现一下API的Undo。

首先要明确几点：

*   并不是所有的API都需要Undo，比如获取数据的接口就完全没有Undo的必要（而且逻辑上也没办法做）
*   只能针对用户最后一次操作进行Undo
*   Undo是在用户维度的，用户不能Undo其他用户的操作

###  传统方案(Plan A)：

*   需要对所有需要Undo的接口提供Undo逻辑;
*   当用户要Undo最近一次操作时需要调用这个方法（常常会涉及数据库操作）。

###  新方案(Plan B)：

*   以中间件(类似Java中的拦截器)方式提供Undo服务
*   对需要Undo的API逻辑放入指定队列延迟执行
*   调用Undo接口时将最近一次操作从延迟执行的队列中移除
*   调用其他接口是立即执行延迟队列中的逻辑

##  方案对比

###  优点：

####  方案A:

*   可以对任意接口进行undo操作；
*   逻辑简单，undo时无需操作数据库；

####  方案B:

*   操作真实反映到了数据库；
*   无需限制undo过期时间；

###  缺点

####  方案A:

*   访问可undo接口后，再访问非undo接口，之前逻辑不能undo；

####  方案B:

*   逻辑较为复杂，undo需要做数据库操作；
*   并非所有操作都能够undo；

##  方案实现

通过上边的方案对比，我发现Plan A更简单、灵活，因此决定实现Plan A。

使用过Koa的通许都知道，koa的中间件非常强大（类似Java web开发中的拦截器），它能够拦截所有请求并执行一些逻辑，例如计算API请求到响应时长等，这里我们就可以使用这个特性将需要Undo的API延迟执行。

首先我们要设置Undo的超时时间，以及那些API需要Undo：

    var apis = (options || {}).apis;
    var expired = (options || {}).expired || 3000;`

    还要明确当前访问API的用户：

    `/**
     * `x-identify-key` is used to identify the user of this request,
     * one user can not undo another`s request.
     */

    var user = context.header['x-identify-key'];`

    然后延迟执行API逻辑：

    `var undo = yield delayNext(user, expired, context);`

    如果用户没有调用Undo接口，则执行逻辑，否则返回’undo’:

    `if (!undo) { return yield next; }
    this.body = 'undo';`

    如果用户调用Undo接口，移除延迟执行的逻辑；调用其他接口则立即执行延迟的逻辑：

    `clearTimeout(undoObj.timeoutId);
    if (path === '/undo' &amp;&amp; method === 'POST') {
      undoObj.delayFn.call(undoObj.context, true);
      context.body = 'done';
      return;
    } else if (undoObj.delayFn) {
      undoObj.delayFn.call(undoObj.context, false);
    }`

    具体实现逻辑大概就这些，完整代码如下：

    `
    /**
     * Store users' undo context
     *
     * @type {Object}
     */
    var undos = {};

    /**
     * Expose `undo`
     *
     * @param {Object} options Config object for undo
     * @example
     * {
     *   expired: 3000
     * }
     */
    module.exports = function (options) {
      var apis = (options || {}).apis;
      var expired = (options || {}).expired || 3000;

      return function* (next) {
        var context = this;
        var path = context.path;
        var needUndo = false;

        if (apis &amp;&amp; Array.isArray(apis) &amp;&amp; apis.length) {
          needUndo = apis.filter(function (api) {
            return path === api;
          }).length;
        }

        if (!needUndo &amp;&amp; path !== '/undo') { return yield next; }

        var method = context.method;
        /**
         * Can not undo get request.
         */
        if (method === 'GET') { return yield next; }
        /**
         * 'x-identify-key' is used to identify the user of this request,
         * one user can not undo another's request.
         */
        var user = context.header['x-identify-key'];
        if (!user) { return yield next; }

        var undoObj = undos[user];
        if (undoObj) {
          clearTimeout(undoObj.timeoutId);
          if (path === '/undo' &amp;&amp; method === 'POST') {
            undoObj.delayFn.call(undoObj.context, true);
            context.body = 'done';
            return;
          } else if (undoObj.delayFn) {
            undoObj.delayFn.call(undoObj.context, false);
          }
        }
        var undo = yield delayNext(user, expired, context);
        if (!undo) { return yield next; }
        this.body = 'undo';
      };
    };

    /**
     * Block the logic for specified ms.
     *
     * @param {String} user The user's identity
     * @param {String} expired The expired ms
     * @param {Object} context The koa context object
     * @api private
     */
    function delayNext(user, expired, context) {
      return function (callback) {
        var delayFn = function (undo) {
          delete undos[user];
          callback(null, undo);
        };
        var timeoutId = setTimeout(delayFn, expired);
        undos[user] = {
          timeoutId: timeoutId,
          delayFn: delayFn,
          context: context
        };
      };
    }

##  项目相关

目前此项目托管在Github上，[https://github.com/sweetvvck/koa-undo](https://github.com/sweetvvck/koa-undo)，koa-undo具体使用方法项目主页有详细介绍，感兴趣的同学欢迎提Issue、PR；同时koa-undo也发布到了Npm上，[https://www.npmjs.com/package/koa-undo](https://www.npmjs.com/package/koa-undo) ，欢迎大家使用。


                作者：sweetvvck 发表于2015/5/8 23:12:05 [原文链接](http://blog.csdn.net/sweetvvck/article/details/45585997)


            阅读：730 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/45585997#comments)
