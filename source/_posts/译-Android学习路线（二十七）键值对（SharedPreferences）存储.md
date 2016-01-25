---
title: '[译]Android学习路线（二十七）键值对（SharedPreferences）存储'
tags: []
date: 2014-09-30 23:56:29
---

如果你又一个相对较小的键&#20540;对数据想要保存，你应该使用[SharedPreferences](http://developer.android.com/reference/android/content/SharedPreferences.html)&nbsp;APIs。一个[SharedPreferences](http://developer.android.com/reference/android/content/SharedPreferences.html)&nbsp;对象指向一个包含键&#20540;对的文件，它提供简单的方法来读写他们。每个[SharedPreferences](http://developer.android.com/reference/android/content/SharedPreferences.html)&nbsp;文件系统框架管理，它们可以是私有的也可以被共享。

本课将介绍如何使用[SharedPreferences](http://developer.android.com/reference/android/content/SharedPreferences.html)&nbsp;APIs来存储和获取简单的数据。

**提示:**&nbsp;[SharedPreferences](http://developer.android.com/reference/android/content/SharedPreferences.html)&nbsp;APIs
 只能被用来操作键&#20540;对类型数据，不要把它和&nbsp;[Preference](http://developer.android.com/reference/android/preference/Preference.html)&nbsp;APIs弄混淆，Preference是用来帮助用户构建app设置界面的。更多关于&nbsp;[Preference](http://developer.android.com/reference/android/preference/Preference.html)&nbsp;APIs的信息，请移步[Settings](http://developer.android.com/guide/topics/ui/settings.html)&nbsp;向导。

##获取SharedPreferences的引用（句柄）

你可以通过下面任意一种方式创建一个新的shared preference文件或者访问一个已经存在的shared preference文件：

*   [getSharedPreferences()](http://developer.android.com/reference/android/content/Context.html#getSharedPreferences(java.lang.String, int))&nbsp;—
 Use this if you need multiple shared preference files identified by name, which you specify with the first parameter. You can call this from any&nbsp;[Context](http://developer.android.com/reference/android/content/Context.html)&nbsp;in
 your app.
*   [getSharedPreferences()](http://developer.android.com/reference/android/content/Context.html#getSharedPreferences(java.lang.String, int))&nbsp;—
 如果你通过不同的名字保存了多个shared preference文件，那么你可以使用这个方法，这个方法的第一个参数即为文件名。你可以在应用中使用Context对象来调用它。

*   [getPreferences()](http://developer.android.com/reference/android/app/Activity.html#getPreferences(int))&nbsp;—
 如果你只需要在这个activity中使用一个shared preference文件，那么你可以在activity中调用这个方法。因为这个方法会返回属于这个activity的一个默认的shared preference文件，你不需要为它提供一个名字。

例如，以下的方法会在 &nbsp;[Fragment](http://developer.android.com/reference/android/app/Fragment.html)&nbsp;中被执行。它在内部访问了一个shared
 preferences文件，这个文件被&nbsp;R.string.preference_file_key&nbsp;这个字符串指定，并且它是被私有模式（private mode）打开的，因此只能被你的app访问。

Context context = getActivity();
SharedPreferences sharedPref = context.getSharedPreferences(
&nbsp; &nbsp; &nbsp; &nbsp; getString(R.string.preference_file_key), Context.MODE_PRIVATE);

当为你的shared preference文件命名时，你应当使用一个唯一的标识，例如&quot;com.example.myapp.PREFERENCE_FILE_KEY&quot;

作为替代，如果你只想要在你的activity中使用一个shared preference文件，你可以使用&nbsp;[getPreferences()](http://developer.android.com/reference/android/app/Activity.html#getPreferences(int))方法：

SharedPreferences sharedPref = getActivity().getPreferences(Context.MODE_PRIVATE);

**注意:**&nbsp;如果你使用&nbsp;[MODE_WORLD_READABLE](http://developer.android.com/reference/android/content/Context.html#MODE_WORLD_READABLE)&nbsp;或者&nbsp;[MODE_WORLD_WRITEABLE](http://developer.android.com/reference/android/content/Context.html#MODE_WORLD_WRITEABLE)模式创建了一个shared
 preference文件，那么任何其他知道这个文件标识的app都能够访问到你的数据。

##向Shared Preferences中写入数据

* * *

要向shared preferences文件中写入数据，你需要调用SharedPreferences的edit()方法来创建一个[SharedPreferences.Editor](http://developer.android.com/reference/android/content/SharedPreferences.Editor.html)&nbsp;对象。

传入键和&#20540;给你想要调用的方法，例如&nbsp;[putInt()](http://developer.android.com/reference/android/content/SharedPreferences.Editor.html#putInt)&[putString()](http://developer.android.com/reference/android/content/SharedPreferences.Editor.html#putStringjava.lang.String, java.lang.String)。然后调用[commit()](http://developer.android.com/reference/android/content/SharedPreferences.Editor.html#commit())&nbsp;方法来存储这些改变。例如：
```java
SharedPreferences sharedPref = getActivity().getPreferences(Context.MODE_PRIVATE);
SharedPreferences.Editor editor = sharedPref.edit();
editor.putInt(getString(R.string.saved_high_score), newHighScore);
editor.commit();
```
##从Shared Preferences中读取数据

* * *

要从shared preferences文件中获取数据，可以调用getInt()或者getString()等方法，只需要提供你想要获得的&#20540;对应的key就可以了；你也可以选择再传入一个默认&#20540;，如果通过传入的key没有取道&#20540;将会返回这个默认&#20540;。例如：
```java
SharedPreferences sharedPref = getActivity().getPreferences(Context.MODE_PRIVATE);
int defaultValue = getResources().getInteger(R.string.saved_high_score_default);
long highScore = sharedPref.getInt(getString(R.string.saved_high_score), defaultValue);
```

                作者：sweetvvck 发表于2014/9/30 23:56:29 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38645065)


            阅读：765 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38645065#comments)
