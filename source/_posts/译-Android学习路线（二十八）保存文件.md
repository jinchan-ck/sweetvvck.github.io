---
title: '[译]Android学习路线（二十八）保存文件'
tags: []
date: 2014-09-30 23:57:47
---

转载请注明出处：[Android学习路线（二十八）保存文件](http://blog.csdn.net/sweetvvck/article/details/38645095)

Android使用了一个类&#20284;其他平台的基于磁盘的文件系统。本课将介绍如何使用android的文件APIS来在这样的文件系统中读写文件。

一个[File](http://developer.android.com/reference/java/io/File.html)&nbsp;对象适用于顺序读写大块数据，而不适用于随机存取。例如它适用于文件或者其他通过网络交换的数据。

本课将想您介绍如何在app中处理基本的文件操作。在此之前，你需要对Linux文件系统以及标准的java文件apis有所了解。

## 选择内部或外部存储

* * *

所有的Android设备都由两个存储区域：“内部”和“外部”存储。这两个名字来源于早期的android版本，当时大多数设备提供“内部构建”（built-in）不可拆卸的内部存储，以及可拆卸的存储媒介，例如微型SD卡。一些设备也将持久化存储设备分为“内部”和“外部”两个部分，因此即使是没有可拆卸媒介的设备也会有两个存储区域，而API的行为与设备是否有可拆卸存储介质无关，下面总结了每个存储区域的相关要点。



**内部存储：**

*   任何时候都可用。
*   默认情况下只有在你的app中才能访问。
*   当用户卸载你的app，系统将移除该应用在内部存储中的所有文件。

当你确定用户和其他app都不能访问到的情况下，内部存储是最佳选择。




**外部存储：**

*   它并不是任何时候都可用，因为用户能够像U盘一样使用它，同时它也可能随时被从设备上移除。
*   它能被任何人访问，因此存储在这里的文件能够被其他app读取。
*   当用户卸载你的app，系统只会在你将文件保存在[getExternalFilesDir()](http://developer.android.com/reference/android/content/Context.html#getExternalFilesDir(java.lang.String))&nbsp;中时才会在这里移除你app中的文件。

当你不需要控制文件的访问权限，同时你希望将文件和其他应用共享或者能够在电脑中访问到，那么外部存储是最好的选择。



**提示:**&nbsp;即使是apps默认会被安装在内部存储中，你也可以在你的app中的manifest文件中指定[android:installLocation](http://developer.android.com/guide/topics/manifest/manifest-element.html#install)&nbsp;属性，让你的app被安装在外部存储中。当apk的大小很大时，用户会非常希望这么做，他们会有一个远大于内部存储的外部存储空间。更多信息，请参阅[App
 Install Location](http://developer.android.com/guide/topics/data/install-location.html)。

## 获取外部存储权限

* * *

要能够在外部存储中写文件，你必须在manifest文件中申请&nbsp;[WRITE_EXTERNAL_STORAGE](http://developer.android.com/reference/android/Manifest.permission.html#WRITE_EXTERNAL_STORAGE)&nbsp;权限：

&lt;manifest ...&gt;
&nbsp; &nbsp; &lt;uses-permission android:name=&quot;android.permission.WRITE_EXTERNAL_STORAGE&quot; /&gt;
&nbsp; &nbsp; ...
&lt;/manifest&gt;


**注意:**&nbsp;目前，所有的应用都有权限读取外部存储中的文件。然而，在之后的版本中将会改变。如果你的app需要读取外部存储中的文件（但是不需要写入），你需要声明[READ_EXTERNAL_STORAGE](http://developer.android.com/reference/android/Manifest.permission.html#READ_EXTERNAL_STORAGE)&nbsp;权限。这样来保证你的app能够像预期那样工作。

&lt;manifest ...&gt;
&nbsp; &nbsp; &lt;uses-permission android:name=&quot;android.permission.READ_EXTERNAL_STORAGE&quot; /&gt;
&nbsp; &nbsp; ...
&lt;/manifest&gt;

然而，如果你的app使用了[WRITE_EXTERNAL_STORAGE](http://developer.android.com/reference/android/Manifest.permission.html#WRITE_EXTERNAL_STORAGE)&nbsp;权限，那么它就同时拥有了读写权限。



保存文件到内部存储中并不需要权限。你的app一直拥有在内部存储目录下的读写权限。

## 保存一个文件到内部存储中

* * *

当保存文件到内部存储中时，你可以通过下面这两种方式获取一个合适的File对象：


[getFilesDir()](http://developer.android.com/reference/android/content/Context.html#getFilesDir())返回一个表示你的app在内部存储中的目录的[File](http://developer.android.com/reference/java/io/File.html)&nbsp;对象。[getCacheDir()](http://developer.android.com/reference/android/content/Context.html#getCacheDir())返回一个表示你的app在内部存储中的临时目录的[File](http://developer.android.com/reference/java/io/File.html)&nbsp;对象。确保在你不需要该缓存文件时将其删掉，同时要指定一个合理的缓存文件大小限制，因为当系统缺少运行空间时会在不发出警告的情况下将该目录的文件删除。

要在上面两个目录之一中创建一个文件，你可以使用&nbsp;[File()](http://developer.android.com/reference/java/io/File.html#File(java.io.File, java.lang.String))&nbsp;构造方法，传入前面获取到的File对象作为内部存储的目录。例如：

File file = new File(context.getFilesDir(), filename);

同样的，你还可以调用&nbsp;[openFileOutput()](http://developer.android.com/reference/android/content/Context.html#openFileOutput(java.lang.String, int))&nbsp;方法来获取一个&nbsp;[FileOutputStream](http://developer.android.com/reference/java/io/FileOutputStream.html)&nbsp;，用于在你的内部存储中写入一个文件。例如，下面是如果像文件中写入一些文本：

String filename = &quot;myfile&quot;;
String string = &quot;Hello world!&quot;;
FileOutputStream outputStream;

try {
&nbsp; outputStream = openFileOutput(filename, Context.MODE_PRIVATE);
&nbsp; outputStream.write(string.getBytes());
&nbsp; outputStream.close();
} catch (Exception e) {
&nbsp; e.printStackTrace();
}

再或者，如果你需要缓存一些文件，你应该使用[createTempFile()](http://developer.android.com/reference/java/io/File.html#createTempFile(java.lang.String, java.lang.String))。例如，下面的方法通过URL萃取文件名，同时使用这个文件名在内部缓存目录下创建一个文件：

public File getTempFile(Context context, String url) {
&nbsp; &nbsp; File file;
&nbsp; &nbsp; try {
&nbsp; &nbsp; &nbsp; &nbsp; String fileName = Uri.parse(url).getLastPathSegment();
&nbsp; &nbsp; &nbsp; &nbsp; file = File.createTempFile(fileName, null, context.getCacheDir());
&nbsp; &nbsp; catch (IOException e) {
&nbsp; &nbsp; &nbsp; &nbsp; // Error while creating file
&nbsp; &nbsp; }
&nbsp; &nbsp; return file;
}

**提示:**&nbsp;你的app的内部存储目录是由你的app包名指定。从技术上来说，如果你把这个文件的模式设置为可读，那么其他app就能够访问你的app的内部文件了。然而，这些其他的app必须知道你的app的包名以及内部文件的名字。如果你不特别地自定内部文件的可读或可写模式，那么别的应用也没有权限操作你的app中的内部文件。

## 保存一个文件到外部存储

* * *

由于外部存储可以不可用——例如当用户将其移除——你需要在访问它之前判断它是否可用。你可以通过调用[getExternalStorageState()](http://developer.android.com/reference/android/os/Environment.html#getExternalStorageState())方法查询到它的可用状态。如果该方法返回的状态等于[MEDIA_MOUNTED](http://developer.android.com/reference/android/os/Environment.html#MEDIA_MOUNTED)，那么你就能够读写你的文件。例如，下面的方法可用于判断外部存储是否可用：

/* Checks if external storage is available for read and write */
public boolean isExternalStorageWritable() {
&nbsp; &nbsp; String state = Environment.getExternalStorageState();
&nbsp; &nbsp; if (Environment.MEDIA_MOUNTED.equals(state)) {
&nbsp; &nbsp; &nbsp; &nbsp; return true;
&nbsp; &nbsp; }
&nbsp; &nbsp; return false;
}

/* Checks if external storage is available to at least read */
public boolean isExternalStorageReadable() {
&nbsp; &nbsp; String state = Environment.getExternalStorageState();
&nbsp; &nbsp; if (Environment.MEDIA_MOUNTED.equals(state) ||
&nbsp; &nbsp; &nbsp; &nbsp; Environment.MEDIA_MOUNTED_READ_ONLY.equals(state)) {
&nbsp; &nbsp; &nbsp; &nbsp; return true;
&nbsp; &nbsp; }
&nbsp; &nbsp; return false;
}

即使外部存储中的文件可以被用户或者其他app修改，对于下面两种类型的文件同样有合适的情况被保存在这里：


公共文件需要被所有app或者用户访问到的文件。当你卸载你的app，你希望用户留下这些文件。

例如，你的app拍下的照片或者其他下载文件。

私有文件文件隶属于你的app，并且应道在用户写在你的app是被删除。即使是这些文件在技术上来讲能够被用户或者其他app访问，实际上它在你的app外部是不会提供任何数据的。当你的app被卸载，系统将会删除你的app在外部存储中的所有私有目录。

例如，通过你的app下载的资源，或者临时的多媒体文件。



如果你希望在外部存储中保存公有文件，使用&nbsp;[getExternalStoragePublicDirectory()](http://developer.android.com/reference/android/os/Environment.html#getExternalStoragePublicDirectory(java.lang.String))&nbsp;方法来获得一个&nbsp;[File](http://developer.android.com/reference/java/io/File.html)&nbsp;对象。这个方法会接收一个参数作为对应文件类型要存放的位置。例如[DIRECTORY_MUSIC](http://developer.android.com/reference/android/os/Environment.html#DIRECTORY_MUSIC)&nbsp;或者&nbsp;[DIRECTORY_PICTURES](http://developer.android.com/reference/android/os/Environment.html#DIRECTORY_PICTURES)

public File getAlbumStorageDir(String albumName) {
&nbsp; &nbsp; // Get the directory for the user's public pictures directory.
&nbsp; &nbsp; File file = new File(Environment.getExternalStoragePublicDirectory(
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Environment.DIRECTORY_PICTURES), albumName);
&nbsp; &nbsp; if (!file.mkdirs()) {
&nbsp; &nbsp; &nbsp; &nbsp; Log.e(LOG_TAG, &quot;Directory not created&quot;);
&nbsp; &nbsp; }
&nbsp; &nbsp; return file;
}

如果你想要在外部存储中保存私有文件，那么你可以通过调用[getExternalFilesDir()](http://developer.android.com/reference/android/content/Context.html#getExternalFilesDir(java.lang.String))&nbsp;方法来获取合适的文件目录对象，同时传入一个名字来指定目录的类型。每个通过这种方式调用获得的目录，都会在应用被卸载时被清除。

例如，下面是如何创建一个独立的相册目录：

public File getAlbumStorageDir(Context context, String albumName) {
&nbsp; &nbsp; // Get the directory for the app's private pictures directory.
&nbsp; &nbsp; File file = new File(context.getExternalFilesDir(
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Environment.DIRECTORY_PICTURES), albumName);
&nbsp; &nbsp; if (!file.mkdirs()) {
&nbsp; &nbsp; &nbsp; &nbsp; Log.e(LOG_TAG, &quot;Directory not created&quot;);
&nbsp; &nbsp; }
&nbsp; &nbsp; return file;
}

如果没有合适的预定义的子目录名字适合你的文件，你可以调用&nbsp;[getExternalFilesDir()](http://developer.android.com/reference/android/content/Context.html#getExternalFilesDir(java.lang.String))&nbsp;方法，同时传入null。它会返回外部存储中你的app对应的私有目录。

要记住通过&nbsp;[getExternalFilesDir()](http://developer.android.com/reference/android/content/Context.html#getExternalFilesDir(java.lang.String))&nbsp;方法创建的目录将会在app卸载时被删除。如果这些文件需要在应用卸载后被保存，当你的应用再次安装时能够访问到，你需要调用[getExternalStoragePublicDirectory()](http://developer.android.com/reference/android/os/Environment.html#getExternalStoragePublicDirectory(java.lang.String))方法。

不管你使用的是可分享的[getExternalStoragePublicDirectory()](http://developer.android.com/reference/android/os/Environment.html#getExternalStoragePublicDirectory(java.lang.String))&nbsp;方法，或者是私有的[getExternalFilesDir()](http://developer.android.com/reference/android/content/Context.html#getExternalFilesDir(java.lang.String))&nbsp;方法，使用系统所提供的目录名称（如&nbsp;[DIRECTORY_PICTURES](http://developer.android.com/reference/android/os/Environment.html#DIRECTORY_PICTURES)）都很重要。这些目录名称将确保这些文件在系统中会被按照这些方式对待。例如，保存在[DIRECTORY_RINGTONES](http://developer.android.com/reference/android/os/Environment.html#DIRECTORY_RINGTONES)&nbsp;中的文件将会被系统识别为手机铃声而非音乐。

## 查询剩余空间

* * *

如果你知道你要保存的数据的大小，这样你就可以判断出是否有足够的空间避免导致&nbsp;[IOException](http://developer.android.com/reference/java/io/IOException.html)&nbsp;异常，可通过调用[getFreeSpace()](http://developer.android.com/reference/java/io/File.html#getFreeSpace())&nbsp;或者&nbsp;[getTotalSpace()](http://developer.android.com/reference/java/io/File.html#getTotalSpace())方法来获取剩余空间的大小。这两个方法各自返回此时的可用空间大侠和存储卷中总共的空间大小。这个方法同样可以在开始就避免占满整个存储空间。

然而，系统并不能确保你能够写入通过[getFreeSpace()](http://developer.android.com/reference/java/io/File.html#getFreeSpace())方法返回的数据大小。如果它返回的大小比你要写入的数据大小大几兆，或者文件系统还有90%的剩余空间，那么执行保存是安全的。否则，你不应该存储这些数据。

**提示:**&nbsp;在存储文件前检查可用空间不是必须操作。你可以直接保存文件，然后捕获[IOException](http://developer.android.com/reference/java/io/IOException.html)&nbsp;异常。你可以在你不知道要保存的数据有多大时使用这种方法。例如，你在保存文件前将PNG转变成JPEG，改变了文件的编码，你提前并不知道文件的大小。

## 删除一个文件

* * *

你要记得在文件不需要被使用时将其删除。最直接的删除方法调用文件对象的[delete()](http://developer.android.com/reference/java/io/File.html#delete())&nbsp;方法删除它本身。

myFile.delete();

如果文件被保存在内部存储中，你同样可以使用Context定位然后调用[deleteFile()](http://developer.android.com/reference/android/content/Context.html#deleteFile(java.lang.String))方法删除文件：

myContext.deleteFile(fileName);


**提示:**&nbsp;当用户卸载你的app，系统将会删除下面内容：

*   所有你的app保存在内部存储中的数据
*   所有通过调用[getExternalFilesDir()](http://developer.android.com/reference/android/content/Context.html#getExternalFilesDir(java.lang.String))方法保存在外部存储中的数据。

然而，你手动删除通过[getCacheDir()](http://developer.android.com/reference/android/content/Context.html#getCacheDir())&nbsp;方法生成的文件，当这些文件不再需要被使用到时。




                作者：sweetvvck 发表于2014/9/30 23:57:47 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38645095)


            阅读：582 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38645095#comments)
