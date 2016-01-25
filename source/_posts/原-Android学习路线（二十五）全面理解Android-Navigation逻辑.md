---
title: '[原]Android学习路线（二十五）全面理解Android Navigation逻辑'
tags: [Android]
categories: [Native app]
date: 2014-08-27 01:23:17
---



转载请注明出处：[Android学习路线（二十五）全面理解Android Navigation逻辑](http://blog.csdn.net/sweetvvck/article/details/38832809)

应用导航的一致性是整体用户体验的重要组成部分，如果app的导航方式不一样，用户不能很快理解，那么这个应用会让用户有很大的挫败感，大大地影响了用户体验。

Android 3.0后，系统像大家介绍了其在全局导航表现上的重大改变。全面地理解“Back”以及“Up”的导航效果以及意义，能够大大地减少用户的学习时间，用户在使用过程中很快能够学习如何在应用的各个界面间的切换。

Android 2.3以及它之前的系统都是通过“Back”按钮来为app导航的。在Android 3.0后出现的Actionbar则带来了另一种一致性的导航方式：“Up”，它位于Actionbar的最左边，通常由应用的Icon以及Title组成。

下图分别展示了“Back”和“Up”的示例：

![](http://img.blog.csdn.net/20140826002202399?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



# Up vs. Back

* * *

Up的导航逻辑是根据界面的层次结构决定的。例如A界面有一个列表，点击列表的Item进入B界面，这个时候，在B界面应该要提供一个Up按钮，点击Up则应该返回到A界面。

如果一个界面是app的主界面，则这个界面是不需要提供Up按钮的，而Back按钮在所有的界面都会起作用。

在应用中，Back的作用是返回到上一个界面中。如果把一个一个打开界面看成是入栈，那么点击Back按钮无疑代表着出栈，用户应该总是能够通过back操作找到上一个界面。

如果当前界面的上一个界面正好也是当前界面的父级界面，那么Back和Up的效果是同样的。但是，Up主要是在app内部使用，而Back则能够让用户回到手机的主界面，甚至能够回到其他的app中。

举个简单的例子：

![](http://img.blog.csdn.net/20140826003932624?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



在手机的主界面点击Gmail应用，进入到Gmail主界面中，主界面包含邮件的会话列表，点击其中一个会话会进入会话的详情界面。在会话详情页上，上一个界面和该界面的上级界面都是会话列表界面，因此点击Back和Up的效果是相同的，都会回到会话列表界面。可以发现，会话列表式Gmail的主界面，所以这个界面上是没有Up按钮的，这个时候则可以通过点击Back回到手机的主界面上。

Back除了能够处理这些界面间的切换，同时它还能处理一些统一界面上的导航逻辑，例如：

点击Back能够让当前界面的对话框消失，还能解除当前界面的文字高亮，同时它还能隐藏输入键盘等。

##  单个应用内部导航

当一个界面有很多入口时，在这个界面点击Up按钮应该回到进入到这个界面的相关界面，这样的效果和Back回到上一个界面的效果是相同的。例如设置界面，应用中可能有很多地方能够进入设置界面，此时点击Up和Back都会返回它的上一个界面。

如果在一个界面内切换视图，例如一个界面包含ViewPager，虽然左右滑动导致界面上的视图更改，但是此界面在app的界面层级并没有改变，同时也没有创建新的导航历史，因此这样的操作时不会引起Up和Back有新 的行为的。

例如：

![](http://img.blog.csdn.net/20140826010627726?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



在会话列表界面点击了其中一条会话，进入详情，在详情页左右滑动查看前后会话详情内容；但是此操作并没有切换界面（在app界面中的层级），因此这样并不能影响Back和Up的效果。

然而，如果在详情页点击了某个按钮进入了另一个详情界面，并且此时创建了导航历史。这样的话，点击Back会回到该详情页的上一个界面，而点击Up则会回到该界面在app中层级的上一级界面。

例如：

![](http://img.blog.csdn.net/20140826011742859?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



我们还可以让导航更加智能，比如我们在某个种类的列表界面点击Item进入详情页跳转到另一种类型的详情页，这时点击Back界面会转到上一个详情页，而点击Up则会返回到这种类型的列表页；如下图所示：

![](http://img.blog.csdn.net/20140827003353545?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



上过上面的讲解，我们可以大致了解Back和Up的不同作用与目的。用户进入到App，切换不同的界面，每个界面都会被加入到一个栈里，通常情况下Back的作用是返回到栈中的上一个界面；而Up与这个栈没有直接关系，除了应用主界面，其他界面都会有一个父级界面，Up的作用正是返回到当前界面的父级界面。





然而，有些情况为了让Back的效果有更好的可预测性，我们应到手动向Back的界面栈中添加界面，这样用户就能更清楚是如何进入到当前界面的。例如，当点击Android桌面上的Widgets进入到一个非app主界面中，如果没有向界面栈中手动插入app的主界面，点击返回就直接退到了手机Home界面，这样的体验不太好；因此我们会做手动向栈中插入界面的操作。详情如下图所示：

![](http://img.blog.csdn.net/20140827004907843?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



##  **跨应用导航**

在同一个App中Back和Up各司其职，有相同的地方也有不同的地方；而在夸应用的情况下，Back和Up有更多的不同之处。

要知道Back和Up跨App的导航效果，首先要知道下面三个概念：

Activities：我们都知道，一个Activity是一个展示信息界面与用户交互的应用组件，而一个app可以看成包含多个activities的集合；而这些activities可以是app自身定义的也可以是对其他app中activity的重用；

Task：Task表示用户一次完整操作的流程。例如用户打开某个应用，在应用的某个界面中点击分享内容，选择通过邮件方式分享；这样的一个过程称为task，可以看到这个过程是跨app的，这次task包含多个activities；

Intent：Intent表示界面跳转的意图，可以指定界面跳转，也可以根据界面支持的action跳转。例如系统中“Share”这个Intent，它会列出系统中所有支持分享的app；

了解了上面的概念后我们来看看这个例子：

![](http://img.blog.csdn.net/20140827011051401?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



用户在某个界面点击分享，跳转到Gmail中分享内容，这个过程是一个task，此时如果点击Back，则会返回到之前的app中；而如果点击Up，则会留在Gmail中，并且跳转到Gmail的主界面（当前界面的父级界面），这个过程是一个新的task。这个新的task会把老的task给覆盖掉，点击Back则返回系统Home界面。





纵观全文，我们了解到了系统推荐的导航准则。我们可以按照规范来，但是在我们的app中，我们也可以具体情况具体分析，总之一个原则就是让用户更快地学习使用app，让界面的导航有更好的可预测性。

本文大致解释了新版Android系统推荐的导航机制，想了解更加细致的内容请参考：[Navigation with Back and Up](http://developer.android.com/design/patterns/navigation.html)&nbsp;。本人也会在后续的文章中介绍ActionBar如何实现Up导航。










                作者：sweetvvck 发表于2014/8/27 1:23:17 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38832809)


            阅读：2657 评论：10 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38832809#comments)
