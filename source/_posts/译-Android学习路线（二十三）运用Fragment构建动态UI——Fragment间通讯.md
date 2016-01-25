---
title: '[译]Android学习路线（二十三）运用Fragment构建动态UI——Fragment间通讯'
tags: [Android, Fragment]
date: 2014-08-15 00:07:26
---

为了要重用Fragment的UI组件，你应该为它们每一个都构建一个完整独立的，模块化的组件来定义他自身的布局和行为。一旦你定义了这些可重用的Fragments，你可以通过activity关联它们同时通过应用逻辑连接它们来实现所有复杂的UI。

你通常都希望一个fragment能够和其他的fragment进行交互，例如基于用户的操作改变内容。所有的fragment之间的交流的完成都通过activity的关联。两个fragment之间一定不要直接交流。

##定义一个接口

* * *

要允许一个fragment和它的activity通讯，你可以在fragment类中定义一个接口，然后再activity中实现它。Fragment在onAttach()方法中获取这个接口的实现，这样之后就能够调用这些接口来达到和activity通讯的目的。

下面是一个fragment和activity通讯的例子：

```java
public class HeadlinesFragment extends ListFragment {
    OnHeadlineSelectedListener mCallback;

    // Container Activity must implement this interface
    public interface OnHeadlineSelectedListener {
        public void onArticleSelected(int position);
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        // This makes sure that the container activity has implemented
        // the callback interface. If not, it throws an exception
        try {
            mCallback = (OnHeadlineSelectedListener) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString()
                    &#43; &quot; must implement OnHeadlineSelectedListener&quot;);
        }
    }

    ...
}
```
现在这个fragment可以通过使用onHeadlineSelectedListener接口的实例mCallback来调用`onArticleSelected()` 方法（或者这个接口中的其它方法）来向activity传递消息了。

例如，当用户点击fragment中列表的item时，下面的方法将会被调用。这个fragment会使用这个回调接口来将事件传递给它的父activity。

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        // Send the event to the host activity
        mCallback.onArticleSelected(position);
    }

##实现这个接口

* * *

为了接收fragment的回调事件，包含这个fragment的activity就必须实现定义在fragment的接口。

例如，下面的这个activity就实现了上面例子中的接口：
```java
public static class MainActivity extends Activity
        implements HeadlinesFragment.OnHeadlineSelectedListener{
    ...

    public void onArticleSelected(int position) {
        // The user selected the headline of an article from the HeadlinesFragment
        // Do something here to display that article
    }
}
```
##向Fragment传递消息

* * *

宿主activity可以通过使用`[findFragmentById()](http://developer.android.com/reference/android/support/v4/app/FragmentManager.html#findFragmentById(int))`获取的fragment实例来向fragment传递消息，然后直接调用这些fragment的public方法。

例如，设想上面的那个activity包含另一个fragment，这个fragment是用来展示通过前面的回调方法返回的数据指定的item。在这个案例中，这个activity可以这个activity可以将接收的这些信息传递给其它的fragment用来显示这个item：
```java
public static class MainActivity extends Activity
        implements HeadlinesFragment.OnHeadlineSelectedListener{
    ...

    public void onArticleSelected(int position) {
        // The user selected the headline of an article from the HeadlinesFragment
        // Do something here to display that article

        ArticleFragment articleFrag = (ArticleFragment)
                getSupportFragmentManager().findFragmentById(R.id.article_fragment);

        if (articleFrag != null) {
            // If article frag is available, we're in two-pane layout...

            // Call a method in the ArticleFragment to update its content
            articleFrag.updateArticleView(position);
        } else {
            // Otherwise, we're in the one-pane layout and must swap frags...

            // Create fragment and give it an argument for the selected article
            ArticleFragment newFragment = new ArticleFragment();
            Bundle args = new Bundle();
            args.putInt(ArticleFragment.ARG_POSITION, position);
            newFragment.setArguments(args);

            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();

            // Replace whatever is in the fragment_container view with this fragment,
            // and add the transaction to the back stack so the user can navigate back
            transaction.replace(R.id.fragment_container, newFragment);
            transaction.addToBackStack(null);

            // Commit the transaction
            transaction.commit();
        }
    }
}
```

                作者：sweetvvck 发表于2014/8/15 0:07:26 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38569351)


            阅读：1416 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38569351#comments)
