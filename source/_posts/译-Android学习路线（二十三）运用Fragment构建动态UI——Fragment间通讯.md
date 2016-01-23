---
title: '[译]Android学习路线（二十三）运用Fragment构建动态UI——Fragment间通讯'
tags: [Android, Fragment]
date: 2014-08-15 00:07:26
---

为了要重用Fragment的UI组件，你应该为它们每一个都构建一个完整独立的，模块化的组件来定义他自身的布局和行为。一旦你定义了这些可重用的Fragments，你可以通过activity关联它们同时通过应用逻辑连接它们来实现所有复杂的UI。

你通常都希望一个fragment能够和其他的fragment进行交互，例如基于用户的操作改变内容。所有的fragment之间的交流的完成都通过activity的关联。两个fragment之间一定不要直接交流。

##
定义一个接口

* * *

要允许一个fragment和它的activity通讯，你可以在fragment类中定义一个接口，然后再activity中实现它。Fragment在onAttach()方法中获取这个接口的实现，这样之后就能够调用这些接口来达到和activity通讯的目的。

下面是一个fragment和activity通讯的例子：

<pre class="prettyprint" style="font-size:13px; margin-top:0px; margin-bottom:1em; color:rgb(0,102,0); line-height:1.5; padding:1em; overflow:auto; border:1px solid rgb(221,221,221); background:rgb(247,247,247)"><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">class</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">HeadlinesFragment</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">extends</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">ListFragment</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="typ" style="color:rgb(102,0,102)">OnHeadlineSelectedListener</span><span class="pln" style="color:rgb(0,0,0)"> mCallback</span><span class="pun" style="color:rgb(102,102,0)">;</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; </span><span class="com">// Container Activity must implement this interface</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">interface</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">OnHeadlineSelectedListener</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">void</span><span class="pln" style="color:rgb(0,0,0)"> onArticleSelected</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="kwd" style="color:rgb(0,0,136)">int</span><span class="pln" style="color:rgb(0,0,0)"> position</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; </span><span class="lit" style="color:rgb(0,102,102)">@Override</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">void</span><span class="pln" style="color:rgb(0,0,0)"> onAttach</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="typ" style="color:rgb(102,0,102)">Activity</span><span class="pln" style="color:rgb(0,0,0)"> activity</span><span class="pun" style="color:rgb(102,102,0)">)</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">super</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">onAttach</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="pln" style="color:rgb(0,0,0)">activity</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// This makes sure that the container activity has implemented</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// the callback interface. If not, it throws an exception</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">try</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; mCallback </span><span class="pun" style="color:rgb(102,102,0)">=</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="typ" style="color:rgb(102,0,102)">OnHeadlineSelectedListener</span><span class="pun" style="color:rgb(102,102,0)">)</span><span class="pln" style="color:rgb(0,0,0)"> activity</span><span class="pun" style="color:rgb(102,102,0)">;</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">catch</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="typ" style="color:rgb(102,0,102)">ClassCastException</span><span class="pln" style="color:rgb(0,0,0)"> e</span><span class="pun" style="color:rgb(102,102,0)">)</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">throw</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">new</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">ClassCastException</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="pln" style="color:rgb(0,0,0)">activity</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">toString</span><span class="pun" style="color:rgb(102,102,0)">()</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">&#43;</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="str" style="color:rgb(136,0,0)">&quot; must implement OnHeadlineSelectedListener&quot;</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp;
&nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">...</span><span class="pln" style="color:rgb(0,0,0)">
</span><span class="pun" style="color:rgb(102,102,0)">}</span></pre>

现在这个fragment可以通过使用onHeadlineSelectedListener接口的实例mCallback来调用`onArticleSelected()`&nbsp;方法（或者这个接口中的其它方法）来向activity传递消息了。

例如，当用户点击fragment中列表的item时，下面的方法将会被调用。这个fragment会使用这个回调接口来将事件传递给它的父activity。

<pre class="prettyprint" style="font-size:13px; margin-top:0px; margin-bottom:1em; color:rgb(0,102,0); line-height:1.5; padding:1em; overflow:auto; border:1px solid rgb(221,221,221); background:rgb(247,247,247)"><span class="pln" style="color:rgb(0,0,0)">&nbsp; &nbsp; </span><span class="lit" style="color:rgb(0,102,102)">@Override</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">void</span><span class="pln" style="color:rgb(0,0,0)"> onListItemClick</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="typ" style="color:rgb(102,0,102)">ListView</span><span class="pln" style="color:rgb(0,0,0)"> l</span><span class="pun" style="color:rgb(102,102,0)">,</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">View</span><span class="pln" style="color:rgb(0,0,0)"> v</span><span class="pun" style="color:rgb(102,102,0)">,</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">int</span><span class="pln" style="color:rgb(0,0,0)"> position</span><span class="pun" style="color:rgb(102,102,0)">,</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">long</span><span class="pln" style="color:rgb(0,0,0)"> id</span><span class="pun" style="color:rgb(102,102,0)">)</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// Send the event to the host activity</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; mCallback</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">onArticleSelected</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="pln" style="color:rgb(0,0,0)">position</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span></pre>

##
实现这个接口

* * *

为了接收fragment的回调事件，包含这个fragment的activity就必须实现定义在fragment的接口。

例如，下面的这个activity就实现了上面例子中的接口：

<pre class="prettyprint" style="font-size:13px; margin-top:0px; margin-bottom:1em; color:rgb(0,102,0); line-height:1.5; padding:1em; overflow:auto; border:1px solid rgb(221,221,221); background:rgb(247,247,247)"><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">static</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">class</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">MainActivity</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">extends</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">Activity</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">implements</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">HeadlinesFragment</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="typ" style="color:rgb(102,0,102)">OnHeadlineSelectedListener</span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">...</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp;
&nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">void</span><span class="pln" style="color:rgb(0,0,0)"> onArticleSelected</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="kwd" style="color:rgb(0,0,136)">int</span><span class="pln" style="color:rgb(0,0,0)"> position</span><span class="pun" style="color:rgb(102,102,0)">)</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// The user selected the headline of an article from the HeadlinesFragment</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// Do something here to display that article</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span><span class="pln" style="color:rgb(0,0,0)">
</span><span class="pun" style="color:rgb(102,102,0)">}</span></pre>

##
向Fragment传递消息

* * *

宿主activity可以通过使用`[findFragmentById()](http://developer.android.com/reference/android/support/v4/app/FragmentManager.html#findFragmentById(int))`获取的fragment实例来向fragment传递消息，然后直接调用这些fragment的public方法。&nbsp;

例如，设想上面的那个activity包含另一个fragment，这个fragment是用来展示通过前面的回调方法返回的数据指定的item。在这个案例中，这个activity可以这个activity可以将接收的这些信息传递给其它的fragment用来显示这个item：

<pre class="prettyprint" style="font-size:13px; margin-top:0px; margin-bottom:1em; color:rgb(0,102,0); line-height:1.5; padding:1em; overflow:auto; border:1px solid rgb(221,221,221); background:rgb(247,247,247)"><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">static</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">class</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">MainActivity</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">extends</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">Activity</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">implements</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">HeadlinesFragment</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="typ" style="color:rgb(102,0,102)">OnHeadlineSelectedListener</span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">...</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">public</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">void</span><span class="pln" style="color:rgb(0,0,0)"> onArticleSelected</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="kwd" style="color:rgb(0,0,136)">int</span><span class="pln" style="color:rgb(0,0,0)"> position</span><span class="pun" style="color:rgb(102,102,0)">)</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// The user selected the headline of an article from the HeadlinesFragment</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// Do something here to display that article</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="typ" style="color:rgb(102,0,102)">ArticleFragment</span><span class="pln" style="color:rgb(0,0,0)"> articleFrag </span><span class="pun" style="color:rgb(102,102,0)">=</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="typ" style="color:rgb(102,0,102)">ArticleFragment</span><span class="pun" style="color:rgb(102,102,0)">)</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; getSupportFragmentManager</span><span class="pun" style="color:rgb(102,102,0)">().</span><span class="pln" style="color:rgb(0,0,0)">findFragmentById</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="pln" style="color:rgb(0,0,0)">R</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">id</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">article_fragment</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="kwd" style="color:rgb(0,0,136)">if</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="pln" style="color:rgb(0,0,0)">articleFrag </span><span class="pun" style="color:rgb(102,102,0)">!=</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">null</span><span class="pun" style="color:rgb(102,102,0)">)</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// If article frag is available, we're in two-pane layout...</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// Call a method in the ArticleFragment to update its content</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; articleFrag</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">updateArticleView</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="pln" style="color:rgb(0,0,0)">position</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">else</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="pun" style="color:rgb(102,102,0)">{</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// Otherwise, we're in the one-pane layout and must swap frags...</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// Create fragment and give it an argument for the selected article</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="typ" style="color:rgb(102,0,102)">ArticleFragment</span><span class="pln" style="color:rgb(0,0,0)"> newFragment </span><span class="pun" style="color:rgb(102,102,0)">=</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">new</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">ArticleFragment</span><span class="pun" style="color:rgb(102,102,0)">();</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="typ" style="color:rgb(102,0,102)">Bundle</span><span class="pln" style="color:rgb(0,0,0)"> args </span><span class="pun" style="color:rgb(102,102,0)">=</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="kwd" style="color:rgb(0,0,136)">new</span><span class="pln" style="color:rgb(0,0,0)"> </span><span class="typ" style="color:rgb(102,0,102)">Bundle</span><span class="pun" style="color:rgb(102,102,0)">();</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">putInt</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="typ" style="color:rgb(102,0,102)">ArticleFragment</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">ARG_POSITION</span><span class="pun" style="color:rgb(102,102,0)">,</span><span class="pln" style="color:rgb(0,0,0)"> position</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; newFragment</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">setArguments</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="pln" style="color:rgb(0,0,0)">args</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="typ" style="color:rgb(102,0,102)">FragmentTransaction</span><span class="pln" style="color:rgb(0,0,0)"> transaction </span><span class="pun" style="color:rgb(102,102,0)">=</span><span class="pln" style="color:rgb(0,0,0)"> getSupportFragmentManager</span><span class="pun" style="color:rgb(102,102,0)">().</span><span class="pln" style="color:rgb(0,0,0)">beginTransaction</span><span class="pun" style="color:rgb(102,102,0)">();</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// Replace whatever is in the fragment_container view with this fragment,</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// and add the transaction to the back stack so the user can navigate back</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; transaction</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">replace</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="pln" style="color:rgb(0,0,0)">R</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">id</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">fragment_container</span><span class="pun" style="color:rgb(102,102,0)">,</span><span class="pln" style="color:rgb(0,0,0)"> newFragment</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; transaction</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">addToBackStack</span><span class="pun" style="color:rgb(102,102,0)">(</span><span class="kwd" style="color:rgb(0,0,136)">null</span><span class="pun" style="color:rgb(102,102,0)">);</span><span class="pln" style="color:rgb(0,0,0)">

&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span><span class="com">// Commit the transaction</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; transaction</span><span class="pun" style="color:rgb(102,102,0)">.</span><span class="pln" style="color:rgb(0,0,0)">commit</span><span class="pun" style="color:rgb(102,102,0)">();</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; &nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span><span class="pln" style="color:rgb(0,0,0)">
&nbsp; &nbsp; </span><span class="pun" style="color:rgb(102,102,0)">}</span><span class="pln" style="color:rgb(0,0,0)">
</span><span class="pun" style="color:rgb(102,102,0)">}</span></pre>

            <div>
                作者：sweetvvck 发表于2014/8/15 0:07:26 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38569351)
            </div>
            <div>
            阅读：1416 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38569351#comments)
            </div>
