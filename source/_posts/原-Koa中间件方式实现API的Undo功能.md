---
title: '[原]Koa中间件方式实现API的Undo功能'
tags: []
date: 2015-05-08 23:12:05
---

# Koa中间件方式实现API的Undo功能

## API的Undo功能

使用过Gmail或者163邮箱的同学会经常看到，当对邮件进行一些操作时会出现一个类似Toast的提示（大致意思是：操作已经完成，是否撤销）如下图所示：

![](http://img.blog.csdn.net/20150508220504487)

![](http://img.blog.csdn.net/20150508220843186)

当点击撤销时，之前执行的操作能够被还原，这种设计对于用户的误操作是一个非常棒的补救方案。

之前听过一句有关交互设计的话说的非常好，不要在用户每做一步操作时弹出Alert让用户选择”确定”或者”取消”，更好的做法是执行操作，然后让用户能够Undo。

## 实现API Undo的方案

其实Undo是很老的技术，在编辑器中无处不在，只是在API设计中使用的还比较少。最近一直在使用Node开发，因此想使用Node实现一下API的Undo。

首先要明确几点：

*   并不是所有的API都需要Undo，比如获取数据的接口就完全没有Undo的必要（而且逻辑上也没办法做）
*   只能针对用户最后一次操作进行Undo
*   Undo是在用户维度的，用户不能Undo其他用户的操作

### 传统方案(Plan A)：

*   需要对所有需要Undo的接口提供Undo逻辑;
*   当用户要Undo最近一次操作时需要调用这个方法（常常会涉及数据库操作）。

### 新方案(Plan B)：

*   以中间件(类似Java中的拦截器)方式提供Undo服务
*   对需要Undo的API逻辑放入指定队列延迟执行
*   调用Undo接口时将最近一次操作从延迟执行的队列中移除
*   调用其他接口是立即执行延迟队列中的逻辑

## 方案对比

### 优点：

#### 方案A:

*   可以对任意接口进行undo操作；
*   逻辑简单，undo时无需操作数据库；

#### 方案B:

*   操作真实反映到了数据库；
*   无需限制undo过期时间；

### 缺点

#### 方案A:

*   访问可undo接口后，再访问非undo接口，之前逻辑不能undo；

#### 方案B:

*   逻辑较为复杂，undo需要做数据库操作；
*   并非所有操作都能够undo；

## 方案实现

通过上边的方案对比，我发现Plan A更简单、灵活，因此决定实现Plan A。

使用过Koa的通许都知道，koa的中间件非常强大（类似Java web开发中的拦截器），它能够拦截所有请求并执行一些逻辑，例如计算API请求到响应时长等，这里我们就可以使用这个特性将需要Undo的API延迟执行。

首先我们要设置Undo的超时时间，以及那些API需要Undo：

    <span class="hljs-keyword">var</span> apis = (options || {}).apis;
    <span class="hljs-keyword">var</span> expired = (options || {}).expired || <span class="hljs-number">3000</span>;`</pre>

    还要明确当前访问API的用户：

    <pre class="prettyprint">`<span class="hljs-javadoc">/**
     * `x-identify-key` is used to identify the user of this request,
     * one user can not undo another`s request.
     */</span>

    <span class="hljs-keyword">var</span> user = context.header[<span class="hljs-string">'x-identify-key'</span>];`</pre>

    然后延迟执行API逻辑：

    <pre class="prettyprint">`<span class="hljs-keyword">var</span> undo = <span class="hljs-keyword">yield</span> delayNext(user, expired, context);`</pre>

    如果用户没有调用Undo接口，则执行逻辑，否则返回’undo’:

    <pre class="prettyprint">`<span class="hljs-keyword">if</span> (!undo) { <span class="hljs-keyword">return</span> <span class="hljs-keyword">yield</span> next; }
    <span class="hljs-keyword">this</span>.body = <span class="hljs-string">'undo'</span>;`</pre>

    如果用户调用Undo接口，移除延迟执行的逻辑；调用其他接口则立即执行延迟的逻辑：

    <pre class="prettyprint">`clearTimeout(undoObj.timeoutId);
    <span class="hljs-keyword">if</span> (path === <span class="hljs-string">'/undo'</span> &amp;&amp; <span class="hljs-function"><span class="hljs-keyword">method</span> === '<span class="hljs-title">POST</span>') <span class="hljs-comment">{
      undoObj.delayFn.call(undoObj.context, true);
      context.body = 'done';
      return;
    }</span> <span class="hljs-title">else</span> <span class="hljs-title">if</span> <span class="hljs-params">(undoObj.delayFn)</span> <span class="hljs-comment">{
      undoObj.delayFn.call(undoObj.context, false);
    }</span></span>`</pre>

    具体实现逻辑大概就这些，完整代码如下：

    <pre class="prettyprint">`
    <span class="hljs-javadoc">/**
     * Store users' undo context
     * 
     * <span class="hljs-javadoctag">@type</span> {Object}
     */</span>
    <span class="hljs-keyword">var</span> undos = {};

    <span class="hljs-javadoc">/**
     * Expose `undo`
     *
     * <span class="hljs-javadoctag">@param</span> {Object} options Config object for undo
     * <span class="hljs-javadoctag">@example</span>
     * {
     *   expired: 3000
     * }
     */</span>
    module.exports = function (options) {
      <span class="hljs-keyword">var</span> apis = (options || {}).apis;
      <span class="hljs-keyword">var</span> expired = (options || {}).expired || <span class="hljs-number">3000</span>;

      <span class="hljs-keyword">return</span> function* (next) {
        <span class="hljs-keyword">var</span> context = <span class="hljs-keyword">this</span>;
        <span class="hljs-keyword">var</span> path = context.path;
        <span class="hljs-keyword">var</span> needUndo = <span class="hljs-keyword">false</span>;

        <span class="hljs-keyword">if</span> (apis &amp;&amp; Array.isArray(apis) &amp;&amp; apis.length) {
          needUndo = apis.filter(function (api) {
            <span class="hljs-keyword">return</span> path === api;
          }).length;
        }

        <span class="hljs-keyword">if</span> (!needUndo &amp;&amp; path !== <span class="hljs-string">'/undo'</span>) { <span class="hljs-keyword">return</span> <span class="hljs-keyword">yield</span> next; }

        <span class="hljs-keyword">var</span> method = context.method;
        <span class="hljs-javadoc">/**
         * Can not undo get request.
         */</span>
        <span class="hljs-keyword">if</span> (method === <span class="hljs-string">'GET'</span>) { <span class="hljs-keyword">return</span> <span class="hljs-keyword">yield</span> next; }
        <span class="hljs-javadoc">/**
         * 'x-identify-key' is used to identify the user of this request,
         * one user can not undo another's request.
         */</span>
        <span class="hljs-keyword">var</span> user = context.header[<span class="hljs-string">'x-identify-key'</span>];
        <span class="hljs-keyword">if</span> (!user) { <span class="hljs-keyword">return</span> <span class="hljs-keyword">yield</span> next; }

        <span class="hljs-keyword">var</span> undoObj = undos[user];
        <span class="hljs-keyword">if</span> (undoObj) {
          clearTimeout(undoObj.timeoutId);
          <span class="hljs-keyword">if</span> (path === <span class="hljs-string">'/undo'</span> &amp;&amp; method === <span class="hljs-string">'POST'</span>) {
            undoObj.delayFn.call(undoObj.context, <span class="hljs-keyword">true</span>);
            context.body = <span class="hljs-string">'done'</span>;
            <span class="hljs-keyword">return</span>;
          } <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> (undoObj.delayFn) {
            undoObj.delayFn.call(undoObj.context, <span class="hljs-keyword">false</span>);
          }
        }
        <span class="hljs-keyword">var</span> undo = <span class="hljs-keyword">yield</span> delayNext(user, expired, context);
        <span class="hljs-keyword">if</span> (!undo) { <span class="hljs-keyword">return</span> <span class="hljs-keyword">yield</span> next; }
        <span class="hljs-keyword">this</span>.body = <span class="hljs-string">'undo'</span>;
      };
    };

    <span class="hljs-javadoc">/**
     * Block the logic for specified ms.
     *
     * <span class="hljs-javadoctag">@param</span> {String} user The user's identity
     * <span class="hljs-javadoctag">@param</span> {String} expired The expired ms
     * <span class="hljs-javadoctag">@param</span> {Object} context The koa context object
     * <span class="hljs-javadoctag">@api</span> private
     */</span>
    function delayNext(user, expired, context) {
      <span class="hljs-keyword">return</span> function (callback) {
        <span class="hljs-keyword">var</span> delayFn = function (undo) {
          delete undos[user];
          callback(<span class="hljs-keyword">null</span>, undo);
        };
        <span class="hljs-keyword">var</span> timeoutId = setTimeout(delayFn, expired);
        undos[user] = {
          timeoutId: timeoutId,
          delayFn: delayFn,
          context: context
        };
      };
    }

## 项目相关

目前此项目托管在Github上，[https://github.com/sweetvvck/koa-undo](https://github.com/sweetvvck/koa-undo)，koa-undo具体使用方法项目主页有详细介绍，感兴趣的同学欢迎提Issue、PR；同时koa-undo也发布到了Npm上，[https://www.npmjs.com/package/koa-undo](https://www.npmjs.com/package/koa-undo) ，欢迎大家使用。

            <div>
                作者：sweetvvck 发表于2015/5/8 23:12:05 [原文链接](http://blog.csdn.net/sweetvvck/article/details/45585997)
            </div>
            <div>
            阅读：730 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/45585997#comments)
            </div>