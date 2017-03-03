---
title: '[译]Android学习路线（三十）高效地显示Bitmaps'
tags: [Android]
date: 2014-10-31 23:39:24
---



学习如何使用常规的技术来加载`[Bitmap](http://developer.android.com/reference/android/graphics/Bitmap.html)`&nbsp;对象，保持你的UI灵敏，同时避免溢出应用内存限制。如果你不注意，bitmaps能够很快地消费你的可用内存预算，让你的app
 crash掉，并且跑出下面这个可怕的异常：

`java.lang.OutofMemoryError: bitmap size exceeds VM budget`.
<!--more-->
下面有几个原因来说明在Android应用中加载bitmaps是很棘手的：

*   移动设备的典型特征是系统资源有限。有些Android设备每个App可以小到仅有16M的可用内存。应用应该在这种内存限制下做优化。然而，很多设备已经可以配置到更高的限制。
*   Bitmaps占用了很多内存，特别是色彩丰富的图片，像照片。例如，&nbsp;[Galaxy Nexus](http://www.android.com/devices/detail/galaxy-nexus)&nbsp;中的相机照出的相片有2592x1936 像素 (5 百万像素)。如果这个bitmap使用的配置是&nbsp;`[ARGB_8888](http://developer.android.com/reference/android/graphics/Bitmap.Config.html)`&nbsp;(从Android2.3开始的默认配置)，那么加载这个图片到内存中需要占用19MB，这样马上就用光了某些设备的每个app的内存限制。
*   Android app UI会频繁的需要多个bitmaps的一次载入。像&nbsp;`[ListView](http://developer.android.com/reference/android/widget/ListView.html)`,`[GridView](http://developer.android.com/reference/android/widget/GridView.html)`&nbsp;以及&nbsp;`[ViewPager](http://developer.android.com/reference/android/support/v4/view/ViewPager.html)`&nbsp;这些组件通常都会一次在屏幕上显示多个bitmaps同时还会有更多的bitmaps在后台等待被显示。

## 课程

* * *

**高效地加载大Bitmaps**此课程带你学习如何解码大bitmaps而不溢出app的内存限制。**在非UI线程处理Bitmaps**Bitmap处理(重置大小，从远端下载等等)都不应该在主UI线程中出现。此课程带你学习如何使用AsyncTask在后台线程中处理bitmaps，同时也会扩展一些处理并发的知识。**缓存Bitmaps**此课程教你使用内存和磁盘来缓存bitmap来提高你的UI加载大量图片时的响应速度和流畅性。**管理Bitmap内存**此课程想你解释如何管理bitmap内存来最优化你的app的表现。**在你的UI中展示Bitmaps**此课程将想你展示如何加载多个bitmaps到类&#20284;`[ViewPager](http://developer.android.com/reference/android/support/v4/view/ViewPager.html)`&nbsp;和&nbsp;`[GridView](http://developer.android.com/reference/android/widget/GridView.html)`&nbsp;的组件中，同时使用了后台线程和缓存。







                作者：sweetvvck 发表于2014/10/31 23:39:24 [原文链接](http://blog.csdn.net/sweetvvck/article/details/40663905)


            阅读：351 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/40663905#comments)
