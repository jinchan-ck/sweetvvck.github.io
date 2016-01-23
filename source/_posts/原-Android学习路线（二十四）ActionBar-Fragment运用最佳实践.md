---
title: '[原]Android学习路线（二十四）ActionBar Fragment运用最佳实践'
tags: []
date: 2014-08-21 03:03:52
---

<span style="font-size:14px">转载请注明出处：[http://blog.csdn.net/sweetvvck/article/details/38645297](http://blog.csdn.net/sweetvvck/article/details/38645297)</span>

<span style="font-size:14px">通过前面的几篇博客，大家看到了Google是如何解释action bar和fragment以及推荐的用法。俗话说没有demo的博客不是好博客，下面我会介绍一下action bar和fragment在实战中的应用，以及相关demo源码，希望和大家相互交流。</span>

<span style="font-size:14px">了解过fragment的同学们应该都知道，fragment是android 3.0版本才出现的的，因此如果要在支持android 3.0一下版本的工程中使用fragment的话是需要添加Support Library的。具体如何添加我就不再赘述，可以看我前面的博客</span><span style="font-size:14px">[Android学习路线（二十一）运用Fragment构建动态UI——创建一个Fragment](http://blog.csdn.net/sweetvvck/article/details/38566871)，下面的项目支持到API
 Level最低为8，所以项目中也会使用到Support Library。</span>

<span style="font-size:14px">作为一个有上进心的Android开发者，我们是希望项目的设计符合**Android Design**的。Android Design是Google官方推荐的应用设计原则，<span style="font-size:14px">不了解Android Design的同学可以去了解下，我这里有[官方翻译文档](http://download.csdn.net/detail/sweetvvck/7835793)。</span></span>

<span style="font-size:14px">我发现“知乎”的App设计是符合Android Design的，那么我们的项目就来模仿知乎的主界面。首先看下效果图：</span>

<span style="font-size:14px">![](http://img.blog.csdn.net/20140818082016785?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)&nbsp;
 &nbsp; &nbsp; &nbsp;![](http://img.blog.csdn.net/20140818082105582?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

</span>

<span style="font-size:14px">我们来分析一下这样的界面应该怎么实现，从上图可以看出“知乎”android端使用了action bar和drawerlayout，同时drawer中item切换主界面应该是fragment。</span>

<span style="font-size:14px">新建一个工程FakeZhihu：</span>

<span style="font-size:14px">![](http://img.blog.csdn.net/20140818083926546?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)&nbsp;&nbsp;![](http://img.blog.csdn.net/20140821010348778?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

</span>

<span style="font-size:14px">&nbsp; &nbsp; &nbsp; 从上图可以看到，使用最新的adt插件创建android项目时，如果选择的Minimum Required SDK为8，而Target SDK大于它的话，系统会自动在项目中导入Support v4包；在创建项目向导最后一步可以选择Navigation Type，如果选择了Navigation Drawer，adt工具会在创建项目时自动生成DrawerLayout相关示例代码。但由于DrawerLayout是在高版本的API中出现的，因此adt工具会帮助导入Support
 v7 appcompat包，这样DrawerLayout就可以兼容到Android2.2了。</span><span style="font-size:14px">没有使用最新版的adt工具也没有关系，我提供的demo里有Support v4包和Support v7包，大家可以直接使用。</span>

<span style="font-size:14px">

</span>

<span style="font-size:14px">&nbsp; &nbsp; &nbsp; 下面来看看代码如何实现，android默认的holo主题只提供两种色调，和官方的action bar比较可以看出“知乎”的action bar的颜色以及action bar上action item的颜色以及title的字体大小都是自定义的，那么我们来模仿它自定义一下action bar。</span>

<span style="font-size:14px">

</span>

<span style="font-size:14px">&nbsp; &nbsp; &nbsp; 首先我们打开res目录下的style文件，自定义一个主题和action bar的style，然后在自定义主题中引用自定义的action bar的style：</span>

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_1_8330842"  code_snippet_id="455217" snippet_file_name="blog_20140821_1_8330842" class="html" name="code">&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;
&lt;resources&gt;
    &lt;!-- the theme applied to the application or activity --&gt;
    &lt;style name=&quot;CustomActionBarTheme&quot;
           parent=&quot;@style/Theme.AppCompat.Light.DarkActionBar&quot;&gt;
        &lt;item name=&quot;android:actionBarStyle&quot;&gt;@style/MyActionBar&lt;/item&gt;

        &lt;!-- Support library compatibility --&gt;
        &lt;item name=&quot;actionBarStyle&quot;&gt;@style/MyActionBar&lt;/item&gt;
    &lt;/style&gt;

    &lt;!-- ActionBar styles --&gt;
    &lt;style name=&quot;MyActionBar&quot;
           parent=&quot;@style/Widget.AppCompat.Light.ActionBar.Solid.Inverse&quot;&gt;
        &lt;item name=&quot;android:background&quot;&gt;@drawable/actionbar_background&lt;/item&gt;
        &lt;item name=&quot;android:titleTextStyle&quot;&gt;@style/MyTitleStyle&lt;/item&gt;

        &lt;!-- Support library compatibility --&gt;
        &lt;item name=&quot;background&quot;&gt;@drawable/actionbar_background&lt;/item&gt;
        &lt;item name=&quot;titleTextStyle&quot;&gt;@style/MyTitleStyle&lt;/item&gt;
    &lt;/style&gt;
    &lt;style name=&quot;MyTitleStyle&quot;
           parent=&quot;@android:style/TextAppearance.Holo.Widget.ActionBar.Title.Inverse&quot;&gt;
        &lt;item name=&quot;android:textSize&quot;&gt;20dp&lt;/item&gt;
    &lt;/style&gt;
&lt;/resources&gt;</pre>这里要注意的是<span style="color:#ff0000">**无论是在自定义主题还是自定义style时，要根据情况加上parent属性，如果没有加上相应的parent属性的话就不能使用父style中没有被覆盖的样式**</span>。具体如何设置action bar的style可以参考[
 Android学习路线（九）为Action Bar添加Style](http://blog.csdn.net/sweetvvck/article/details/38409785)。

<span style="font-size:14px">完成自定义主题和style后要记得在manifest文件中应用：</span>

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_2_6630166"  code_snippet_id="455217" snippet_file_name="blog_20140821_2_6630166" class="html" name="code">&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;
&lt;manifest xmlns:android=&quot;http://schemas.android.com/apk/res/android&quot;
    package=&quot;com.sweetvvck.fakezhihu&quot;
    android:versionCode=&quot;1&quot;
    android:versionName=&quot;1.0&quot; &gt;

    &lt;uses-sdk
        android:minSdkVersion=&quot;8&quot;
        android:targetSdkVersion=&quot;19&quot; /&gt;

    &lt;application
        android:allowBackup=&quot;true&quot;
        android:icon=&quot;@drawable/ic_launcher&quot;
        android:label=&quot;@string/app_name&quot;
        android:theme=&quot;@style/CustomActionBarTheme&quot; &gt;
        &lt;activity
            android:name=&quot;com.sweetvvck.fakezhihu.MainActivity&quot;
            android:label=&quot;@string/app_name&quot; &gt;
            &lt;intent-filter&gt;
                &lt;action android:name=&quot;android.intent.action.MAIN&quot; /&gt;

                &lt;category android:name=&quot;android.intent.category.LAUNCHER&quot; /&gt;
            &lt;/intent-filter&gt;
        &lt;/activity&gt;
    &lt;/application&gt;

&lt;/manifest&gt;
</pre>这里可以让整个应用都使用自定义的主题，也可以指定单个activity使用，使用android:theme属性来指定。

<span style="font-size:14px">接下来要给app添加DrawerLayout了，修改MainActivity的布局文件，添加一个DrawerLayout，内容非常简单，其中包含一个Drawer和内容布局的Container：</span>

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_3_8026388"  code_snippet_id="455217" snippet_file_name="blog_20140821_3_8026388" class="html" name="code">&lt;android.support.v4.widget.DrawerLayout xmlns:android=&quot;http://schemas.android.com/apk/res/android&quot;
    xmlns:tools=&quot;http://schemas.android.com/tools&quot;
    android:id=&quot;@+id/drawer_layout&quot;
    android:layout_width=&quot;match_parent&quot;
    android:layout_height=&quot;match_parent&quot;
    tools:context=&quot;com.sweetvvck.fakezhihu.MainActivity&quot; &gt;

    &lt;FrameLayout
        android:id=&quot;@+id/container&quot;
        android:layout_width=&quot;match_parent&quot;
        android:layout_height=&quot;match_parent&quot; /&gt;

    &lt;fragment
        android:id=&quot;@+id/navigation_drawer&quot;
        android:name=&quot;com.sweetvvck.fakezhihu.NavigationDrawerFragment&quot;
        android:layout_width=&quot;@dimen/navigation_drawer_width&quot;
        android:layout_height=&quot;match_parent&quot;
        android:layout_gravity=&quot;start&quot; /&gt;

&lt;/android.support.v4.widget.DrawerLayout&gt;
</pre>注意，下面那个fragment就是app的Drawer，**其中的属性android:layout_gravity在这里表示Drawer从哪一侧划出，start代表左侧，end代表右侧；还可以定义两个fragment，然后一个左侧划出一个右侧划出**，DrawerLayout在之后会详细讲解，这里先简单了解如何使用。

<span style="font-size:14px">创建完DrawerLayout布局后，我们来为Drawer定义一个fragment，我们可以看到知乎的Drawer中只是包含了一个ListView。这个ListView的第一项和其它项的布局不一样，我们可以想到用ListView加上headerView来实现，知道这些后，我们来创建一个NavigationDrawerFragment继承自Fragment，这个fragment的布局包含一个ListView：</span>

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_4_4754766"  code_snippet_id="455217" snippet_file_name="blog_20140821_4_4754766" class="html" name="code">&lt;ListView xmlns:android=&quot;http://schemas.android.com/apk/res/android&quot;
    xmlns:tools=&quot;http://schemas.android.com/tools&quot;
    android:layout_width=&quot;match_parent&quot;
    android:layout_height=&quot;match_parent&quot;
    android:background=&quot;#fff&quot;
    android:choiceMode=&quot;singleChoice&quot;
    android:divider=&quot;#c3c3c3&quot;
    android:dividerHeight=&quot;0.5dp&quot;
    tools:context=&quot;com.sweetvvck.fakezhihu.NavigationDrawerFragment&quot; /&gt;
</pre>使用一个ArrayList来存放ListView的数据，定义一个DrawerListItem对象来存放每个Item的title和icon的资源ID：

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_5_8135855"  code_snippet_id="455217" snippet_file_name="blog_20140821_5_8135855" class="html" style="font-size: 14px;" name="code">&lt;string-array name=&quot;item_title&quot;&gt;
    &lt;item&gt;首页&lt;/item&gt;
    &lt;item&gt;发现&lt;/item&gt;
    &lt;item&gt;关注&lt;/item&gt;
    &lt;item&gt;收藏&lt;/item&gt;
    &lt;item&gt;草稿&lt;/item&gt;
    &lt;item&gt;搜索&lt;/item&gt;
    &lt;item&gt;提问&lt;/item&gt;
    &lt;item&gt;设置&lt;/item&gt;
&lt;/string-array&gt;</pre><pre code_snippet_id="455217" snippet_file_name="blog_20140821_6_2879366"  code_snippet_id="455217" snippet_file_name="blog_20140821_6_2879366" class="java" name="code">String[] itemTitle = getResources().getStringArray(R.array.item_title);
int[] itemIconRes = {
  R.drawable.ic_drawer_home,
  R.drawable.ic_drawer_explore,
  R.drawable.ic_drawer_follow,
  R.drawable.ic_drawer_collect,
  R.drawable.ic_drawer_draft,
  R.drawable.ic_drawer_search,
  R.drawable.ic_drawer_question,
  R.drawable.ic_drawer_setting};

for (int i = 0; i &lt; itemTitle.length; i++) {
    DrawerListItem item = new DrawerListItem(getResources().getDrawable(itemIconRes[i]), itemTitle[i]);
    mData.add(item);

}</pre>准备好数据后为该ListView设置Adapter，我们发现这个ListView是Single Choice模式的，并且每个Item被选中后会高亮。那么如何来实现这个功能呢？

<span style="font-size:14px">实现这样的效果有两个步骤：</span>

<span style="font-size:14px">&nbsp; &nbsp; &nbsp; 第一：在ListView中指定android:choiceMode=&quot;singleChoice&quot;；</span>

<span style="font-size:14px">&nbsp; &nbsp; &nbsp; 第二：给ListView的Item的布局设置一个特殊的背景drawable，这个drawable包含当状态为activated时的背景和常态下的背景；同时这个item布局中的图片src和文字颜色也要坐相应的设置；</span>

<span style="font-size:14px">item的背景：</span>

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_7_8179283"  code_snippet_id="455217" snippet_file_name="blog_20140821_7_8179283" class="html" name="code">&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;
&lt;selector xmlns:android=&quot;http://schemas.android.com/apk/res/android&quot;&gt;
    &lt;item android:state_activated=&quot;true&quot; android:drawable=&quot;@drawable/activated_background_color&quot; /&gt;
    &lt;item android:drawable=&quot;@android:color/transparent&quot; /&gt;
&lt;/selector&gt;</pre>图片的src，这里以home为例：

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_8_1003966"  code_snippet_id="455217" snippet_file_name="blog_20140821_8_1003966" class="html" name="code">&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;
&lt;selector xmlns:android=&quot;http://schemas.android.com/apk/res/android&quot;&gt;
    &lt;item android:state_activated=&quot;true&quot; android:drawable=&quot;@drawable/ic_drawer_home_pressed&quot; /&gt;
    &lt;item android:drawable=&quot;@drawable/ic_drawer_home_normal&quot; /&gt;
&lt;/selector&gt;</pre>文字的颜色：

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_9_6336903"  code_snippet_id="455217" snippet_file_name="blog_20140821_9_6336903" class="html" name="code">&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;
&lt;!-- Copyright (C) 2011 Google Inc. All Rights Reserved. --&gt;
&lt;selector xmlns:android=&quot;http://schemas.android.com/apk/res/android&quot;&gt;
    &lt;item android:state_enabled=&quot;false&quot;
        android:color=&quot;#ff999999&quot;/&gt;
    &lt;item android:state_activated=&quot;true&quot;
        android:color=&quot;@android:color/white&quot; /&gt;
    &lt;item
        android:color=&quot;#636363&quot; /&gt;
&lt;/selector&gt;
</pre>这样就能实现ListView点击Item高亮的效果了。

<span style="font-size:14px">

</span>

<span style="font-size:14px">考虑到用户在第一次使用app的时候可能不知道有Drawer的存在，我们可以在app第一次被启动时让Drawer处于打开状态，之后再默认隐藏，**这是实际项目中常用的手段**，这里我们用sharedpreference来实现：</span>

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_10_764769"  code_snippet_id="455217" snippet_file_name="blog_20140821_10_764769" class="java" name="code">// 通过这个flag判断用户是否已经知道drawer了，第一次启动应用显示出drawer（抽屉），之后启动应用默认将其</pre><pre code_snippet_id="455217" snippet_file_name="blog_20140821_11_1401"  code_snippet_id="455217" snippet_file_name="blog_20140821_11_1401" class="java" name="code">SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(getActivity());
mUserLearnedDrawer = sp.getBoolean(PREF_USER_LEARNED_DRAWER, false);</pre>接下来，要实现Drawer的fragment和宿主activity之间的通讯，需要定义一个回调接口，并且在宿主activity中实现：

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_12_2269675"  code_snippet_id="455217" snippet_file_name="blog_20140821_12_2269675" class="java" name="code">/**
* 宿主activity要实现的回调接口</pre><pre code_snippet_id="455217" snippet_file_name="blog_20140821_13_7570375"  code_snippet_id="455217" snippet_file_name="blog_20140821_13_7570375" class="java" name="code">* 用于activity与该fragment之间通讯
*/
public static interface NavigationDrawerCallbacks {
    /**
     * 当drawer中的某个item被选择是调用该方法
    */
    void onNavigationDrawerItemSelected(String title);
}</pre><pre code_snippet_id="455217" snippet_file_name="blog_20140821_14_8203230"  code_snippet_id="455217" snippet_file_name="blog_20140821_14_8203230" class="java" name="code">@Override
public void onNavigationDrawerItemSelected(String title) {
	FragmentManager fragmentManager = getSupportFragmentManager();
	FragmentTransaction ft = fragmentManager.beginTransaction();
	currentFragment = fragmentManager.findFragmentByTag(title);
	if(currentFragment == null) {
		currentFragment = ContentFragment.newInstance(title);
		ft.add(R.id.container, currentFragment, title);
	}
	if(lastFragment != null) {
		ft.hide(lastFragment);
	}
	if(currentFragment.isDetached()){
		ft.attach(currentFragment);
	}
	ft.show(currentFragment);
	lastFragment = currentFragment;
	ft.commit();
	onSectionAttached(title);
}</pre>具体如何来创建一个fragment以及如何实现fragment和activity之间的通讯，可以参考：[Android学习路线（二十一）运用Fragment构建动态UI——创建一个Fragment](http://blog.csdn.net/sweetvvck/article/details/38566871)&nbsp;和&nbsp;[Android学习路线（二十三）运用Fragment构建动态UI——Fragment间通讯](http://blog.csdn.net/sweetvvck/article/details/38569351)&nbsp;；完整的<span style="font-size:14px">NavigationDrawerFragment代码如下：</span>

<span style="font-size:14px"></span>

<pre code_snippet_id="455217" snippet_file_name="blog_20140821_15_7832736"  code_snippet_id="455217" snippet_file_name="blog_20140821_15_7832736" class="java" name="code">package com.sweetvvck.fakezhihu;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.app.Fragment;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;

/**
 * 用于管理交互和展示抽屉导航的Fragment。
 * 参考&lt;a href=&quot;https://developer.android.com/design/patterns/navigation-drawer.html#Interaction&quot;&gt;
 * 设计向导&lt;/a&gt; 
 */
public class NavigationDrawerFragment extends Fragment {

    /**
     * 存放选中item的位置
     */
    private static final String STATE_SELECTED_POSITION = &quot;selected_navigation_drawer_position&quot;;

    /**
     * 存放用户是否需要默认开启drawer的key
     */
    private static final String PREF_USER_LEARNED_DRAWER = &quot;navigation_drawer_learned&quot;;

    /**
     * 宿主activity实现的回调接口的引用
     */
    private NavigationDrawerCallbacks mCallbacks;

    /**
     * 将action bar和drawerlayout绑定的组件
     */
    private ActionBarDrawerToggle mDrawerToggle;

    private DrawerLayout mDrawerLayout;
    private ListView mDrawerListView;
    private View mFragmentContainerView;

    private int mCurrentSelectedPosition = 0;
    private boolean mFromSavedInstanceState;
    private boolean mUserLearnedDrawer;
    private List&lt;DrawerListItem&gt; mData = new ArrayList&lt;DrawerListItem&gt;();

    public NavigationDrawerFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 通过这个flag判断用户是否已经知道drawer了，第一次启动应用显示出drawer（抽屉），之后启动应用默认将其隐藏
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(getActivity());
        mUserLearnedDrawer = sp.getBoolean(PREF_USER_LEARNED_DRAWER, false);

        if (savedInstanceState != null) {
            mCurrentSelectedPosition = savedInstanceState.getInt(STATE_SELECTED_POSITION);
            mFromSavedInstanceState = true;
        }

    }

    @Override
    public void onActivityCreated (Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        // 设置该fragment拥有自己的actionbar action item
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        mDrawerListView = (ListView) inflater.inflate(R.layout.fragment_navigation_drawer, container, false);
        View headerView = inflater.inflate(R.layout.list_header, null);
        mDrawerListView.addHeaderView(headerView);
        mDrawerListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView&lt;?&gt; parent, View view, int position, long id) {
                selectItem(position);
            }
        });
        String[] itemTitle = getResources().getStringArray(R.array.item_title);
        int[] itemIconRes = {
    		R.drawable.ic_drawer_home,
    		R.drawable.ic_drawer_explore,
    		R.drawable.ic_drawer_follow,
    		R.drawable.ic_drawer_collect,
	        R.drawable.ic_drawer_draft,
	        R.drawable.ic_drawer_search,
	        R.drawable.ic_drawer_question,
	        R.drawable.ic_drawer_setting};

        for (int i = 0; i &lt; itemTitle.length; i++) {
			DrawerListItem item = new DrawerListItem(getResources().getDrawable(itemIconRes[i]), itemTitle[i]);
			mData.add(item);

		}
        selectItem(mCurrentSelectedPosition);
        DrawerListAdapter adapter = new DrawerListAdapter(this.getActivity(), mData);
        mDrawerListView.setAdapter(adapter);
        mDrawerListView.setItemChecked(mCurrentSelectedPosition, true);
        return mDrawerListView;
    }

    public boolean isDrawerOpen() {
        return mDrawerLayout != null &amp;&amp; mDrawerLayout.isDrawerOpen(mFragmentContainerView);
    }

    /**
     * 设置导航drawer
     *
     * @param fragmentId   fragmentent的id
     * @param drawerLayout fragment的容器
     */
    public void setUp(int fragmentId, DrawerLayout drawerLayout) {
        mFragmentContainerView = getActivity().findViewById(fragmentId);
        mDrawerLayout = drawerLayout;

        mDrawerLayout.setDrawerShadow(R.drawable.drawer_shadow, GravityCompat.START);

        ActionBar actionBar = getActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setHomeButtonEnabled(true);
        //隐藏Action bar上的app icon
        actionBar.setDisplayShowHomeEnabled(false);

        mDrawerToggle = new ActionBarDrawerToggle(
                getActivity(),                    /* 宿主 */
                mDrawerLayout,                    /* DrawerLayout 对象 */
                R.drawable.ic_drawer,             /* 替换actionbar上的&#39;Up&#39;图标 */
                R.string.navigation_drawer_open,  
                R.string.navigation_drawer_close
        ) {
            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                if (!isAdded()) {
                    return;
                }

                getActivity().supportInvalidateOptionsMenu(); // 调用 onPrepareOptionsMenu()
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                if (!isAdded()) {
                    return;
                }

                if (!mUserLearnedDrawer) {
                    mUserLearnedDrawer = true;
                    SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(getActivity());
                    sp.edit().putBoolean(PREF_USER_LEARNED_DRAWER, true).commit();
                }

                getActivity().supportInvalidateOptionsMenu(); // 调用 onPrepareOptionsMenu()
            }
        };

        // 如果是第一次进入应用，显示抽屉
        if (!mUserLearnedDrawer &amp;&amp; !mFromSavedInstanceState) {
            mDrawerLayout.openDrawer(mFragmentContainerView);
        }

        mDrawerLayout.post(new Runnable() {
            @Override
            public void run() {
                mDrawerToggle.syncState();
            }
        });

        mDrawerLayout.setDrawerListener(mDrawerToggle);
    }

    private void selectItem(int position) {
        mCurrentSelectedPosition = position;
        if (mDrawerListView != null) {
            mDrawerListView.setItemChecked(position, true);
        }
        if (mDrawerLayout != null) {
            mDrawerLayout.closeDrawer(mFragmentContainerView);
        }
        if (mCallbacks != null) {
        	if(mCurrentSelectedPosition == 0) {
        		mCallbacks.onNavigationDrawerItemSelected(getString(R.string.app_name));
        		return;
        	}
            mCallbacks.onNavigationDrawerItemSelected(mData.get(position - 1).getTitle());
        }
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            mCallbacks = (NavigationDrawerCallbacks) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(&quot;Activity must implement NavigationDrawerCallbacks.&quot;);
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(STATE_SELECTED_POSITION, mCurrentSelectedPosition);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        // 当系统配置改变时调用DrawerToggle的改变配置方法（例如横竖屏切换会回调此方法）
        mDrawerToggle.onConfigurationChanged(newConfig);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        //当抽屉打开时显示应用全局的actionbar设置
        if (mDrawerLayout != null &amp;&amp; isDrawerOpen()) {
            inflater.inflate(R.menu.global, menu);
            showGlobalContextActionBar();
        }
        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (mDrawerToggle.onOptionsItemSelected(item)) {
            return true;
        }

        if (item.getItemId() == R.id.action_example) {
            Toast.makeText(getActivity(), &quot;Example action.&quot;, Toast.LENGTH_SHORT).show();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * 当抽屉打开时显示应用全局的actionbar设置
     */
    private void showGlobalContextActionBar() {
        ActionBar actionBar = getActionBar();
        actionBar.setDisplayShowTitleEnabled(true);
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
        actionBar.setTitle(R.string.app_name);
    }

    private ActionBar getActionBar() {
        return ((ActionBarActivity) getActivity()).getSupportActionBar();
    }

    /**
     * 宿主activity要实现的回调接口
     * 用于activity与该fragment之间通讯
     */
    public static interface NavigationDrawerCallbacks {
        /**
         * 当drawer中的某个item被选择是调用该方法
         */
        void onNavigationDrawerItemSelected(String title);
    }

}
</pre>

<span style="font-size:14px">

</span>

这样就完成模仿“知乎”主界面的demo的开发啦，来看看效果如何：

<span style="font-size:14px">

</span>

<span style="font-size:14px"></span>

<div style="text-align:center">![](http://img.blog.csdn.net/20140821024716201?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)&nbsp;&nbsp;![](http://img.blog.csdn.net/20140821024753703?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)&nbsp;&nbsp;![](http://img.blog.csdn.net/20140821024813359?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3dlZXR2dmNr/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)</div>

<span style="font-size:14px">怎么样，很像吧，Drawer是不是简直可以以假乱真了，哈哈。</span>

<span style="font-size:14px">demo地址：[http://download.csdn.net/detail/sweetvvck/7794083](http://download.csdn.net/detail/sweetvvck/7794083)</span>

<span style="font-size:14px">其实demo中还有写知识点没有讲到，比如drawer划开时和关闭时action bar上的action item其实是不一样的，这时如何实现的呢？怎么设置action bar不现实logo/icon？选择Drawer中listview的item切换fragment可以每选择一次都replace一次fragment，但是这样每次都得重新创建一个fragment，如果fragment初始化较复杂就更占资源，此时可以配合使用add，hide，show来实现切换同时将以加载过的fragment缓存起来......由于篇幅原因，这些问题都会在之后的博客中详细讲到的~</span>

<div style="top:0px">&#65279;&#65279;</div>

            <div>
                作者：sweetvvck 发表于2014/8/21 3:03:52 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38645297)
            </div>
            <div>
            阅读：6955 评论：20 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38645297#comments)
            </div>