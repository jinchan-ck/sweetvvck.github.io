---
title: '[译]Android学习路线（三十三）缓存Bitmap'
tags: [Android]
date: 2014-10-31 23:43:14
---

加载一个bitmap到UI上是很简单的，然而，如果要一次加载一个大的图片集事情就变的复杂了许多。在多数情况下（例如在使用在[ListView](http://developer.android.com/reference/android/widget/ListView.html),[GridView](http://developer.android.com/reference/android/widget/GridView.html)和[ViewPager](http://developer.android.com/reference/android/support/v4/view/ViewPager.html)中），屏幕上的图片以及将要滚动到屏幕的图片的总数大体上是无限的。

内存使用量可以通过回收不在屏幕上显示的子View来保持较低的状态。在不保持引用长期有效的情况下，GC也会将这些加载过的bitmaps回收。 这样做其实很好，但是要保持一个流畅快速响应的UI，你可能想要避免每次都重复的加载图片近内存。在这种情况下，磁盘加上内存双重缓存能够帮上大忙，它能够让相同的图片快速复用。

本课介绍使用加载大量图片的情况下使用磁盘内存缓存来提升UI的响应速度和流畅度。

##使用内存缓存

* * *

内存缓存是通过消耗珍贵的app内存资源来提供快速访问bitmaps的功能。[LruCache](http://developer.android.com/reference/android/util/LruCache.html)类
 (API等级4以上的低版本可以使用[Support Library](http://developer.android.com/reference/android/support/v4/util/LruCache.html)) 是专用的缓存bitmaps的，它将最近使用的bitmaps的强引用保存在一个[LinkedHashMap](http://developer.android.com/reference/java/util/LinkedHashMap.html)中，当缓存数量达到限制时将最久没有使用过的引用从缓存中剔除。

**提示:**在之前，流行的内存缓存实现使用的都是[SoftReference](http://developer.android.com/reference/java/lang/ref/SoftReference.html)或者[WeakReference](http://developer.android.com/reference/java/lang/ref/WeakReference.html)bitmap
 缓存，然而这样不被推荐。从Android 2.3 (API Level 9)开始，GC对soft/weak 引用的回收大大加强了，这回导致它们很快就失效了。

要为[LruCache](http://developer.android.com/reference/android/util/LruCache.html)选择一个合适的大小，下面几点因素需要考虑：

*   你的App所剩余的内存情况？
*   一次在屏幕上会显示多少图片？有多少图片准备好在屏幕上显示？
*   设备的屏幕大小和密度？高分辨率例如密度为xhdpi的设备需要一个更大的缓存来在内存上保存相同数量的图片。
*   这些Bitmaps的尺寸和配置，以及它们所需要消耗的内存大小。
*   这些图片被访问的频度是多少？是否它们中的某些比剩余的访问频度高很多？如果是这样，你可能想要将这些高频访问的图片一直放在内存中，或者使用多个LruCache用于不同频度的bitmaps集合。
*   你能够保持数量和质量的平衡吗？有时候保存大量的低分辨率bitmaps，然后在后台加载他们的高分辨率版本是很有效的做法。

没有一个能够适用于所有app的LruCache的大小和使用方式，这要依据不同app的内存使用量和一些其他因素，经过分析后得出一个最佳方案。缓存太小只会带来额外的内存消耗而没有任何好处，然而缓存太大又有可能导致java.lang.OutOfMemory异常，得不偿失。

下面是为Bitmaps设置LruCache的示例：
```java
private LruCache&lt;String, Bitmap&gt; mMemoryCache;

@Override
protected void onCreate(Bundle savedInstanceState) {
  ...
  // Get max available VM memory, exceeding this amount will throw an
  // OutOfMemory exception. Stored in kilobytes as LruCache takes an
  // int in its constructor.
  final int maxMemory = (int) (Runtime.getRuntime().maxMemory() / 1024);

  // Use 1/8th of the available memory for this memory cache.
  final int cacheSize = maxMemory / 8;

  mMemoryCache = new LruCache&lt;String, Bitmap&gt;(cacheSize) {
    @Override
    protected int sizeOf(String key, Bitmap bitmap) {
      // The cache size will be measured in kilobytes rather than
      // number of items.
      return bitmap.getByteCount() / 1024;
    }
  };
  ...
}

public void addBitmapToMemoryCache(String key, Bitmap bitmap) {
  if (getBitmapFromMemCache(key) == null) {
    mMemoryCache.put(key, bitmap);
  }
}

public Bitmap getBitmapFromMemCache(String key) {
  return mMemoryCache.get(key);
}
```
**提示:**在本例中，app所分配内存的1/8用于缓存。在普通或者较高分辨率的设备中，缓存的大小大约为4MB (32/8)。一个在分辨率为800x480的设备上被图片覆盖，全屏显示的[GridView](http://developer.android.com/reference/android/widget/GridView.html)，将会消耗大约1.5MB
 (800*480*4 字节)内存，这样本例中的LruCache就能够缓存2.5页图片。

当加载bitmap到ImageView中时，LruCache会首先检查该bitmap是否已经缓存。如果已经找到对应对象就直接更新到ImageView中，否则就生成一个后台线程加载图片：
```java
public void loadBitmap(int resId, ImageView imageView) {
  final String imageKey = String.valueOf(resId);

  final Bitmap bitmap = getBitmapFromMemCache(imageKey);
  if (bitmap != null) {
    mImageView.setImageBitmap(bitmap);
  } else {
    mImageView.setImageResource(R.drawable.image_placeholder);
    BitmapWorkerTask task = new BitmapWorkerTask(mImageView);
    task.execute(resId);
  }
}

[BitmapWorkerTask](http://developer.android.com/training/displaying-bitmaps/process-bitmap.html#BitmapWorkerTask)同样需要被更新，加载对象到内存缓存：

class BitmapWorkerTask extends AsyncTask&lt;Integer, Void, Bitmap&gt; {
  ...
  // Decode image in background.
  @Override
  protected Bitmap doInBackground(Integer... params) {
    final Bitmap bitmap = decodeSampledBitmapFromResource(
        getResources(), params[0], 100, 100));
    addBitmapToMemoryCache(String.valueOf(params[0]), bitmap);
    return bitmap;
  }
  ...
}
```
##使用磁盘缓存

* * *

内存缓存能够大大提升访问速度，然而你不能依赖这些缓存能够一直存在。像[GridView](http://developer.android.com/reference/android/widget/GridView.html)这种拥有大量数据的组件会很快的填满内存缓存。你的App也会被被其他任务中断例如有人打电话过来，当你再次回到app时，它可能已经被杀死，同时内存缓存都被清理掉了，这些图片又需要再次被加载进来。

磁盘缓存可以用于这些情况，将加载过的bitmaps持久化到磁盘中，减少加载那些已经不在内存中存在的图片的时间。当然，由于从磁盘读取的时间不能被预测，速度比从内存读取慢上许多并且需要再后台线程中加载。

**提示:**[ContentProvider](http://developer.android.com/reference/android/content/ContentProvider.html)可能更适合存放那些被频繁访问的图片，例如在相册应用中那样。

下面使用了DiskLruCache的示例代码是从[Android
 source](https://android.googlesource.com/platform/libcore/&#43;/jb-mr2-release/luni/src/main/java/libcore/io/DiskLruCache.java)中抽取出来的，同时加入了内存缓存：
```java
private DiskLruCache mDiskLruCache;
private final Object mDiskCacheLock = new Object();
private boolean mDiskCacheStarting = true;
private static final int DISK_CACHE_SIZE = 1024 * 1024 * 10; // 10MB
private static final String DISK_CACHE_SUBDIR = &quot;thumbnails&quot;;

@Override
protected void onCreate(Bundle savedInstanceState) {
  ...
  // Initialize memory cache
  ...
  // Initialize disk cache on background thread
  File cacheDir = getDiskCacheDir(this, DISK_CACHE_SUBDIR);
  new InitDiskCacheTask().execute(cacheDir);
  ...
}

class InitDiskCacheTask extends AsyncTask&lt;File, Void, Void&gt; {
  @Override
  protected Void doInBackground(File... params) {
    synchronized (mDiskCacheLock) {
      File cacheDir = params[0];
      mDiskLruCache = DiskLruCache.open(cacheDir, DISK_CACHE_SIZE);
      mDiskCacheStarting = false; // Finished initialization
      mDiskCacheLock.notifyAll(); // Wake any waiting threads
    }
    return null;
  }
}

class BitmapWorkerTask extends AsyncTask&lt;Integer, Void, Bitmap&gt; {
  ...
  // Decode image in background.
  @Override
  protected Bitmap doInBackground(Integer... params) {
    final String imageKey = String.valueOf(params[0]);

    // Check disk cache in background thread
    Bitmap bitmap = getBitmapFromDiskCache(imageKey);

    if (bitmap == null) { // Not found in disk cache
      // Process as normal
      final Bitmap bitmap = decodeSampledBitmapFromResource(
          getResources(), params[0], 100, 100));
    }

    // Add final bitmap to caches
    addBitmapToCache(imageKey, bitmap);

    return bitmap;
  }
  ...
}

public void addBitmapToCache(String key, Bitmap bitmap) {
  // Add to memory cache as before
  if (getBitmapFromMemCache(key) == null) {
    mMemoryCache.put(key, bitmap);
  }

  // Also add to disk cache
  synchronized (mDiskCacheLock) {
    if (mDiskLruCache != null &amp;&amp; mDiskLruCache.get(key) == null) {
      mDiskLruCache.put(key, bitmap);
    }
  }
}

public Bitmap getBitmapFromDiskCache(String key) {
  synchronized (mDiskCacheLock) {
    // Wait while disk cache is started from background thread
    while (mDiskCacheStarting) {
      try {
        mDiskCacheLock.wait();
      } catch (InterruptedException e) {}
    }
    if (mDiskLruCache != null) {
      return mDiskLruCache.get(key);
    }
  }
  return null;
}

// Creates a unique subdirectory of the designated app cache directory. Tries to use external
// but if not mounted, falls back on internal storage.
public static File getDiskCacheDir(Context context, String uniqueName) {
  // Check if media is mounted or storage is built-in, if so, try and use external cache dir
  // otherwise use internal cache dir
  final String cachePath =
      Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) ||
          !isExternalStorageRemovable() ? getExternalCacheDir(context).getPath() :
              context.getCacheDir().getPath();

  return new File(cachePath &#43; File.separator &#43; uniqueName);
}
```

**提示:**初始化磁盘缓存也需要磁盘操作，同样不能在主线程中执行。然而，这就意味着会有缓存没有初始化完就被使用的情况出现。要避免这种情况，在上面的实现代码中，使用了一个锁对象保证在磁盘缓存初始化完成前不能被使用。

内存缓存在UI线程中检查，而磁盘缓存则在后台线程中检查。当一个图片被加载完成，它将被同时加入到内存和磁盘缓存，用于之后的使用。

##处理配置变化（例如横竖屏切换）

* * *

运行时配置发生配置变化，例如屏幕方向切换，导致Android系统使用新的配置重启activity。你想要做的是在发生这种情况时不要影响到缓存机制。

幸运的是，在上面“使用内存缓存”那一节中讲解了一个很棒的内存缓存示例。这个缓存可以通过[Fragment](http://developer.android.com/reference/android/app/Fragment.html)传递给新的activity中。

下面是使用Fragment保持[LruCache](http://developer.android.com/reference/android/util/LruCache.html)对象的示例代码：
```java
private LruCache&lt;String, Bitmap&gt; mMemoryCache;

@Override
protected void onCreate(Bundle savedInstanceState) {
  ...
  RetainFragment retainFragment =
      RetainFragment.findOrCreateRetainFragment(getFragmentManager());
  mMemoryCache = retainFragment.mRetainedCache;
  if (mMemoryCache == null) {
    mMemoryCache = new LruCache&lt;String, Bitmap&gt;(cacheSize) {
      ... // Initialize cache here as usual
    }
    retainFragment.mRetainedCache = mMemoryCache;
  }
  ...
}

class RetainFragment extends Fragment {
  private static final String TAG = &quot;RetainFragment&quot;;
  public LruCache&lt;String, Bitmap&gt; mRetainedCache;

  public RetainFragment() {}

  public static RetainFragment findOrCreateRetainFragment(FragmentManager fm) {
    RetainFragment fragment = (RetainFragment) fm.findFragmentByTag(TAG);
    if (fragment == null) {
      fragment = new RetainFragment();
      fm.beginTransaction().add(fragment, TAG).commit();
    }
    return fragment;
  }

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setRetainInstance(true);
  }
}
```

                作者：sweetvvck 发表于2014/10/31 23:43:14 [原文链接](http://blog.csdn.net/sweetvvck/article/details/40664009)


            阅读：373 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/40664009#comments)
