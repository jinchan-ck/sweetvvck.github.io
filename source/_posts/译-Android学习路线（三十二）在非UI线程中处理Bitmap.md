---
title: '[译]Android学习路线（三十二）在非UI线程中处理Bitmap'
tags: [Android]
date: 2014-10-31 23:41:35
---

如果图片源数据是从硬盘，网络或是其他非内存中读取的话，在[高效地夹在大Bitmaps](http://developer.android.com/training/displaying-bitmaps/load-bitmap.html)中讨论的[BitmapFactory.decode*](http://developer.android.com/reference/android/graphics/BitmapFactory.html#decodeByteArray(byte[], int, int, android.graphics.BitmapFactory.Options))方法就不能在主线程（UI线程）中执行。这种数据加载进内存的时间是不可预测的，并且还要依赖各种其他因素（磁盘读取速度，网络速度，图片大小，CPU性能等等）。如果这些任务的其中之一阻塞了UI线程，那么系统就认为你的app处于无响应状态并且弹出对话框提示用户关闭app。

本课介绍如何使用&nbsp;[AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)&nbsp;在后台线程中处理bitmaps，同时粗略讲解如何处理并发事件。

##使用AsyncTask

* * *

[AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)&nbsp;类提供了一个简单的方法来在后台线程处理任务，并且能够将处理结果在UI线程中返回。要使用它，需创建一个它的子类，然后覆盖几个必要的方法。下面这个例子向你展示如何使用&nbsp;[AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)&nbsp;和[`decodeSampledBitmapFromResource()`](http://developer.android.com/training/displaying-bitmaps/load-bitmap.html#decodeSampledBitmapFromResource)将大bitmap加载到ImageView中：


class BitmapWorkerTask extends AsyncTask&lt;Integer, Void, Bitmap&gt; {
&nbsp; &nbsp; private final WeakReference&lt;ImageView&gt; imageViewReference;
&nbsp; &nbsp; private int data = 0;

&nbsp; &nbsp; public BitmapWorkerTask(ImageView imageView) {
&nbsp; &nbsp; &nbsp; &nbsp; // Use a WeakReference to ensure the ImageView can be garbage collected
&nbsp; &nbsp; &nbsp; &nbsp; imageViewReference = new WeakReference&lt;ImageView&gt;(imageView);
&nbsp; &nbsp; }

&nbsp; &nbsp; // Decode image in background.
&nbsp; &nbsp; @Override
&nbsp; &nbsp; protected Bitmap doInBackground(Integer... params) {
&nbsp; &nbsp; &nbsp; &nbsp; data = params[0];
&nbsp; &nbsp; &nbsp; &nbsp; return decodeSampledBitmapFromResource(getResources(), data, 100, 100));
&nbsp; &nbsp; }

&nbsp; &nbsp; // Once complete, see if ImageView is still around and set bitmap.
&nbsp; &nbsp; @Override
&nbsp; &nbsp; protected void onPostExecute(Bitmap bitmap) {
&nbsp; &nbsp; &nbsp; &nbsp; if (imageViewReference != null &amp;&amp; bitmap != null) {
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; final ImageView imageView = imageViewReference.get();
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (imageView != null) {
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; imageView.setImageBitmap(bitmap);
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; }
&nbsp; &nbsp; &nbsp; &nbsp; }
&nbsp; &nbsp; }
}

[ImageView](http://developer.android.com/reference/android/widget/ImageView.html)&nbsp;到[WeakReference](http://developer.android.com/reference/java/lang/ref/WeakReference.html)&nbsp;确保了[AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)&nbsp;不会阻止[ImageView](http://developer.android.com/reference/android/widget/ImageView.html)&nbsp;以及它引用的对象不会被垃圾回收。由于并不能确保&nbsp;[ImageView](http://developer.android.com/reference/android/widget/ImageView.html)&nbsp;在任务执行结束后仍然存在，我们在使用它之前需要对它进行检查。[ImageView](http://developer.android.com/reference/android/widget/ImageView.html)&nbsp;有可能已经不存在了，例如，用户切换到其他的activity中又或者在任务结束前发生了配置改变（横竖屏切换）都可能导致上述情况。

要异步地加载这个bitmap，只需要简单地执行下面的代码：

public void loadBitmap(int resId, ImageView imageView) {
&nbsp; &nbsp; BitmapWorkerTask task = new BitmapWorkerTask(imageView);
&nbsp; &nbsp; task.execute(resId);
}

##处理并发

* * *

通常的视图组件像[ListView](http://developer.android.com/reference/android/widget/ListView.html)&nbsp;和&nbsp;[GridView](http://developer.android.com/reference/android/widget/GridView.html)，如果像上一节中示范的那样与&nbsp;[AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)&nbsp;一起使用会引出其他的问题。为了提高内存使用效率，这些组件在滚动过程中会重用它们的子View。如果每个子View都触发了一个&nbsp;[AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)，那么这些AsyncTask结束后没有任何确保，它们之前关联的View可能已经被重用了。并且，AsyncTask开始的顺序并不意味着它们的结束顺训。

[Multithreading for Performance](http://android-developers.blogspot.com/2010/07/multithreading-for-performance.html)&nbsp;这片文章讨论了如何处理并发，并且提供了提供了一个解决方法：将ImageView的引用存储起来，然后等到&nbsp;[AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)&nbsp;结束后查找对应的引用。使用一个类&#20284;的方法，上一节使用的&nbsp;[AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)&nbsp;将会使用类&#20284;的模式进行简单的扩展。

创建一个专用的[Drawable](http://developer.android.com/reference/android/graphics/drawable/Drawable.html)&nbsp;子类来存储任务的引用。在这种情况下，这个[BitmapDrawable](http://developer.android.com/reference/android/graphics/drawable/BitmapDrawable.html)&nbsp;的作用是让一个占位的图片在task结束后能够被显示在这个ImageView上：


static class AsyncDrawable extends BitmapDrawable {
&nbsp; &nbsp; private final WeakReference&lt;BitmapWorkerTask&gt; bitmapWorkerTaskReference;

&nbsp; &nbsp; public AsyncDrawable(Resources res, Bitmap bitmap,
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; BitmapWorkerTask bitmapWorkerTask) {
&nbsp; &nbsp; &nbsp; &nbsp; super(res, bitmap);
&nbsp; &nbsp; &nbsp; &nbsp; bitmapWorkerTaskReference =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; new WeakReference&lt;BitmapWorkerTask&gt;(bitmapWorkerTask);
&nbsp; &nbsp; }

&nbsp; &nbsp; public BitmapWorkerTask getBitmapWorkerTask() {
&nbsp; &nbsp; &nbsp; &nbsp; return bitmapWorkerTaskReference.get();
&nbsp; &nbsp; }
}

在执行[BitmapWorkerTask](http://developer.android.com/training/displaying-bitmaps/process-bitmap.html#BitmapWorkerTask)之前，你需要先创建一个[`AsyncDrawable`](http://developer.android.com/training/displaying-bitmaps/process-bitmap.html#AsyncDrawable)&nbsp;同时将它绑定到目标[ImageView](http://developer.android.com/reference/android/widget/ImageView.html)：

public void loadBitmap(int resId, ImageView imageView) {
&nbsp; &nbsp; if (cancelPotentialWork(resId, imageView)) {
&nbsp; &nbsp; &nbsp; &nbsp; final BitmapWorkerTask task = new BitmapWorkerTask(imageView);
&nbsp; &nbsp; &nbsp; &nbsp; final AsyncDrawable asyncDrawable =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; new AsyncDrawable(getResources(), mPlaceHolderBitmap, task);
&nbsp; &nbsp; &nbsp; &nbsp; imageView.setImageDrawable(asyncDrawable);
&nbsp; &nbsp; &nbsp; &nbsp; task.execute(resId);
&nbsp; &nbsp; }
}

`cancelPotentialWork`&nbsp;和上面的代码示例对应，检查是否已经有一个运行中的task与此ImageView相关联。如果是，此方法尝试通过调用[cancel()](http://developer.android.com/reference/android/os/AsyncTask.html#cancel(boolean))方法取消此任务。在少数情况下，新的task数据和已经存在的task匹配，即可直接返回。下面是`cancelPotentialWork`的示例代码：

public static boolean cancelPotentialWork(int data, ImageView imageView) {
&nbsp; &nbsp; final BitmapWorkerTask bitmapWorkerTask = getBitmapWorkerTask(imageView);

&nbsp; &nbsp; if (bitmapWorkerTask != null) {
&nbsp; &nbsp; &nbsp; &nbsp; final int bitmapData = bitmapWorkerTask.data;
&nbsp; &nbsp; &nbsp; &nbsp; // If bitmapData is not yet set or it differs from the new data
&nbsp; &nbsp; &nbsp; &nbsp; if (bitmapData == 0 || bitmapData != data) {
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; // Cancel previous task
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; bitmapWorkerTask.cancel(true);
&nbsp; &nbsp; &nbsp; &nbsp; } else {
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; // The same work is already in progress
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return false;
&nbsp; &nbsp; &nbsp; &nbsp; }
&nbsp; &nbsp; }
&nbsp; &nbsp; // No task associated with the ImageView, or an existing task was cancelled
&nbsp; &nbsp; return true;
}

`getBitmapWorkerTask()`, 用于获取与指定[ImageView](http://developer.android.com/reference/android/widget/ImageView.html)关联的任务：

private static BitmapWorkerTask getBitmapWorkerTask(ImageView imageView) {
&nbsp; &nbsp;if (imageView != null) {
&nbsp; &nbsp; &nbsp; &nbsp;final Drawable drawable = imageView.getDrawable();
&nbsp; &nbsp; &nbsp; &nbsp;if (drawable instanceof AsyncDrawable) {
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;final AsyncDrawable asyncDrawable = (AsyncDrawable) drawable;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;return asyncDrawable.getBitmapWorkerTask();
&nbsp; &nbsp; &nbsp; &nbsp;}
&nbsp; &nbsp; }
&nbsp; &nbsp; return null;
}

最后一步是在`[BitmapWorkerTask](http://developer.android.com/training/displaying-bitmaps/process-bitmap.html#BitmapWorkerTask)&nbsp;中`更新&nbsp;`onPostExecute()`&nbsp;方法，&nbsp;检查task是否被取消以及当前的task是否与跟ImageView关联的那个匹配：


class BitmapWorkerTask extends AsyncTask&lt;Integer, Void, Bitmap&gt; {
&nbsp; &nbsp; ...

&nbsp; &nbsp; @Override
&nbsp; &nbsp; protected void onPostExecute(Bitmap bitmap) {
&nbsp; &nbsp; &nbsp; &nbsp; if (isCancelled()) {
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; bitmap = null;
&nbsp; &nbsp; &nbsp; &nbsp; }

&nbsp; &nbsp; &nbsp; &nbsp; if (imageViewReference != null &amp;&amp; bitmap != null) {
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; final ImageView imageView = imageViewReference.get();
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; final BitmapWorkerTask bitmapWorkerTask =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; getBitmapWorkerTask(imageView);
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (this == bitmapWorkerTask &amp;&amp; imageView != null) {
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; imageView.setImageBitmap(bitmap);
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; }
&nbsp; &nbsp; &nbsp; &nbsp; }
&nbsp; &nbsp; }
}

这样的实现就也适用于&nbsp;`[ListView](http://developer.android.com/reference/android/widget/ListView.html)`&nbsp;和&nbsp;[GridView](http://developer.android.com/reference/android/widget/GridView.html)&nbsp;了，即使它们重用子View。&nbsp;只需要简单的在你为ImageView设置图片的地方调用一下&nbsp;loadBitmap&nbsp;方法。例如在ListView对应的Adapter的getView方法中调用。


                作者：sweetvvck 发表于2014/10/31 23:41:35 [原文链接](http://blog.csdn.net/sweetvvck/article/details/40663987)


            阅读：363 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/40663987#comments)
