---
title: '[译]Android学习路线（二十九）保存数据到SQLite中'
tags: []
date: 2014-09-30 23:55:32
---

<span style="">对于可复用或者结构化的数据来说，把它们存储到数据库中是理想的方式。学习本课前你需要对通常的数据库有所了解，本课在此前提下会帮助你学习如何在android系统中操作SQLite数据库。你需要使用到的APIs都可以在[<span style="">android.database.sqlite</span>](http://developer.android.com/reference/android/database/sqlite/package-summary.html)&nbsp;包中访问到。</span>

<span style="">定义一个&#26684;式和契约</span>

<span style=""></span>

<span style="">SQL数据库最主要的标准之一是其&#26684;式（Schema）：它用来声明数据库的组织。Schema可以通过你用来创建数据库的语句来表示。你会发现创建一个能够有条理地，明确指定schema布局的&quot;伙伴&quot;类(也被称为&quot;关系类&quot;)是非常有帮助的。</span>

<span style="">关系类其实就是个定义常量的容器，这些常量包含URIs,tables以及colums的名称。这个关系类允许你在同一个包下的所有类中都能够访问。这样的话，你只要在这里改变一个列名，你的所有代码都会受影响。</span>

<span style="">一个好的组织关系类的方法是，让你的关系类中对于整个数据库来说是全局可用的常量定义在关系类的顶级，然后为每个表在该类中建立内部类。</span>

<span style="">**提示:**&nbsp;通过实现&nbsp;[<span style="">BaseColumns</span>](http://developer.android.com/reference/android/provider/BaseColumns.html)&nbsp;接口，你的内部类能够继承一个名称为</span><span style="">_ID</span><span style="">的属性，它在默写类(例如cursor
 adapter)中被期望存在。它不是必须的，但是如果它的存在能够让你的数据库和Android框架相处更加和谐。</span>

<span style="">例如，下面的代码片段定义了一个表的表明和列名：</span>

<span style="">public</span><span style=""> </span><span style="">final</span><span style="">
</span><span style="">class</span><span style=""> </span><span style="">FeedReaderContract</span><span style="">
</span><span style="">{</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">// To prevent someone from accidentally instantiating the contract class,</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">// give it an empty constructor.</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span><span style="">FeedReaderContract</span><span style="">()</span><span style="">
</span><span style="">{}</span>

<span style=""></span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">/* Inner class that defines the table contents */</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span><span style="">static</span><span style="">
</span><span style="">abstract</span><span style=""> </span><span style="">class</span><span style="">
</span><span style="">FeedEntry</span><span style=""> </span><span style="">implements</span><span style="">
</span><span style="">BaseColumns</span><span style=""> </span><span style="">{</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span>
<span style="">static</span><span style=""> </span><span style="">final</span><span style="">
</span><span style="">String</span><span style=""> TABLE_NAME </span><span style="">=</span><span style="">
</span><span style="">&quot;entry&quot;</span><span style="">;</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span>
<span style="">static</span><span style=""> </span><span style="">final</span><span style="">
</span><span style="">String</span><span style=""> COLUMN_NAME_ENTRY_ID </span><span style="">=</span><span style="">
</span><span style="">&quot;entryid&quot;</span><span style="">;</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span>
<span style="">static</span><span style=""> </span><span style="">final</span><span style="">
</span><span style="">String</span><span style=""> COLUMN_NAME_TITLE </span><span style="">=</span><span style="">
</span><span style="">&quot;title&quot;</span><span style="">;</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span>
<span style="">static</span><span style=""> </span><span style="">final</span><span style="">
</span><span style="">String</span><span style=""> COLUMN_NAME_SUBTITLE </span><span style="">=</span><span style="">
</span><span style="">&quot;subtitle&quot;</span><span style="">;</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">...</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">}</span>

<span style="">}</span>

<span style="">通过SQL Helper创建一个数据库</span>

<span style=""></span>

<span style="">一旦你定义了你的数据库的样子，你就需要实现一些方法来创建和保持数据库和表。下面是创建和删除一个表的典型的语句：</span>

<span style="">private</span><span style=""> </span><span style="">static</span><span style="">
</span><span style="">final</span><span style=""> </span><span style="">String</span><span style=""> TEXT_TYPE
</span><span style="">=</span><span style=""> </span><span style="">&quot; TEXT&quot;</span><span style="">;</span>

<span style="">private</span><span style=""> </span><span style="">static</span><span style="">
</span><span style="">final</span><span style=""> </span><span style="">String</span><span style=""> COMMA_SEP
</span><span style="">=</span><span style=""> </span><span style="">&quot;,&quot;</span><span style="">;</span>

<span style="">private</span><span style=""> </span><span style="">static</span><span style="">
</span><span style="">final</span><span style=""> </span><span style="">String</span><span style=""> SQL_CREATE_ENTRIES
</span><span style="">=</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">&quot;CREATE TABLE &quot;</span><span style=""> </span>
<span style="">&#43;</span><span style=""> </span><span style="">FeedEntry</span><span style="">.</span><span style="">TABLE_NAME
</span><span style="">&#43;</span><span style=""> </span><span style="">&quot; (&quot;</span><span style="">
</span><span style="">&#43;</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">_ID
</span><span style="">&#43;</span><span style=""> </span><span style="">&quot; INTEGER PRIMARY KEY,&quot;</span><span style="">
</span><span style="">&#43;</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_ENTRY_ID
</span><span style="">&#43;</span><span style=""> TEXT_TYPE </span><span style="">&#43;</span><span style=""> COMMA_SEP
</span><span style="">&#43;</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_TITLE
</span><span style="">&#43;</span><span style=""> TEXT_TYPE </span><span style="">&#43;</span><span style=""> COMMA_SEP
</span><span style="">&#43;</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">...</span><span style=""> </span><span style="">// Any other options for the CREATE command</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">&quot; )&quot;</span><span style="">;</span>

<span style=""></span>

<span style="">private</span><span style=""> </span><span style="">static</span><span style="">
</span><span style="">final</span><span style=""> </span><span style="">String</span><span style=""> SQL_DELETE_ENTRIES
</span><span style="">=</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">&quot;DROP TABLE IF EXISTS &quot;</span><span style="">
</span><span style="">&#43;</span><span style=""> </span><span style="">FeedEntry</span><span style="">.</span><span style="">TABLE_NAME</span><span style="">;</span>

<span style="">就像是你保存在内部存储中的文件一样，Android将你的数据库存储在和应用关联的私有空间内。你的数据是安全的，因为默认这个区域不能被其他的app访问。</span>

<span style="">在&nbsp;[<span style="">SQLiteOpenHelper</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html)&nbsp;类中能够找到很多有用的API。当你使用这个类来获得数据库的引用时，系统只会在需要的时候才会去做这种可能长时间的创建/更新数据酷的操作，而不会在app启动时这样做。你所需要做的只有调用&nbsp;[<span style="">getWritableDatabase()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#getWritableDatabase())&nbsp;或者[<span style="">getReadableDatabase()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#getReadableDatabase())。</span>

<span style="">**提示:**&nbsp;由于这可能会很长时间，确保要在后台线程中调用&nbsp;[<span style="">getWritableDatabase()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#getWritableDatabase())&nbsp;或者[<span style="">getReadableDatabase()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#getReadableDatabase())&nbsp;方法，例如在&nbsp;[<span style="">AsyncTask</span>](http://developer.android.com/reference/android/os/AsyncTask.html)&nbsp;或者&nbsp;[<span style="">IntentService</span>](http://developer.android.com/reference/android/app/IntentService.html)中。</span>

<span style="">在使用[<span style="">SQLiteOpenHelper</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html)时，创建一个它的子类，实现&nbsp;[<span style="">onCreate()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#onCreate(android.database.sqlite.SQLiteDatabase))</span><span style="">，</span><span style="">&nbsp;[<span style="">onUpgrade()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#onUpgrade(android.database.sqlite.SQLiteDatabase,%20int,%20int))&nbsp;和[<span style="">onOpen()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#onOpen(android.database.sqlite.SQLiteDatabase))&nbsp;回调方法。你可能还想实现[<span style="">onDowngrade()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#onDowngrade(android.database.sqlite.SQLiteDatabase,%20int,%20int))方法，但是它并不是必须的。</span>

<span style="">例如，下面展示了如何实现&nbsp;[<span style="">SQLiteOpenHelper</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html)&nbsp;类，使用上面的一些命令：</span>

<span style="">public</span><span style=""> </span><span style="">class</span><span style="">
</span><span style="">FeedReaderDbHelper</span><span style=""> </span><span style="">extends</span><span style="">
</span><span style="">SQLiteOpenHelper</span><span style=""> </span><span style="">{</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">// If you change the database schema, you must increment the database version.</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span><span style="">static</span><span style="">
</span><span style="">final</span><span style=""> </span><span style="">int</span><span style=""> DATABASE_VERSION
</span><span style="">=</span><span style=""> </span><span style="">1</span><span style="">;</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span><span style="">static</span><span style="">
</span><span style="">final</span><span style=""> </span><span style="">String</span><span style=""> DATABASE_NAME
</span><span style="">=</span><span style=""> </span><span style="">&quot;FeedReader.db&quot;</span><span style="">;</span>

<span style=""></span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span><span style="">FeedReaderDbHelper</span><span style="">(</span><span style="">Context</span><span style=""> context</span><span style="">)</span><span style="">
</span><span style="">{</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">super</span><span style="">(</span><span style="">context</span><span style="">,</span><span style=""> DATABASE_NAME</span><span style="">,</span><span style="">
</span><span style="">null</span><span style="">,</span><span style=""> DATABASE_VERSION</span><span style="">);</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">}</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span><span style="">void</span><span style=""> onCreate</span><span style="">(</span><span style="">SQLiteDatabase</span><span style=""> db</span><span style="">)</span><span style="">
</span><span style="">{</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; db</span><span style="">.</span><span style="">execSQL</span><span style="">(</span><span style="">SQL_CREATE_ENTRIES</span><span style="">);</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">}</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span><span style="">void</span><span style=""> onUpgrade</span><span style="">(</span><span style="">SQLiteDatabase</span><span style=""> db</span><span style="">,</span><span style="">
</span><span style="">int</span><span style=""> oldVersion</span><span style="">,</span><span style="">
</span><span style="">int</span><span style=""> newVersion</span><span style="">)</span><span style="">
</span><span style="">{</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">// This database is only a cache for online data, so its upgrade policy is</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">// to simply to discard the data and start over</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; db</span><span style="">.</span><span style="">execSQL</span><span style="">(</span><span style="">SQL_DELETE_ENTRIES</span><span style="">);</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; onCreate</span><span style="">(</span><span style="">db</span><span style="">);</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">}</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">public</span><span style=""> </span><span style="">void</span><span style=""> onDowngrade</span><span style="">(</span><span style="">SQLiteDatabase</span><span style=""> db</span><span style="">,</span><span style="">
</span><span style="">int</span><span style=""> oldVersion</span><span style="">,</span><span style="">
</span><span style="">int</span><span style=""> newVersion</span><span style="">)</span><span style="">
</span><span style="">{</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; onUpgrade</span><span style="">(</span><span style="">db</span><span style="">,</span><span style=""> oldVersion</span><span style="">,</span><span style=""> newVersion</span><span style="">);</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">}</span>

<span style="">}</span>

<span style="">要访问你的数据库，实例化你所创建的[<span style="">SQLiteOpenHelper</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html)的子类：</span>

<span style="">FeedReaderDbHelper</span><span style=""> mDbHelper </span><span style="">=</span><span style="">
</span><span style="">new</span><span style=""> </span><span style="">FeedReaderDbHelper</span><span style="">(</span><span style="">getContext</span><span style="">());</span>

<span style="">向数据库中插入数据</span>

<span style=""></span>

<span style="">通过将&nbsp;[<span style="">ContentValues</span>](http://developer.android.com/reference/android/content/ContentValues.html)&nbsp;对象传给[<span style="">insert()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#insert(java.lang.String,%20java.lang.String,%20android.content.ContentValues))&nbsp;方法来向数据库中插入数据：</span>

<span style="">// Gets the data repository in write mode</span>

<span style="">SQLiteDatabase</span><span style=""> db </span><span style="">=</span><span style=""> mDbHelper</span><span style="">.</span><span style="">getWritableDatabase</span><span style="">();</span>

<span style=""></span>

<span style="">// Create a new map of values, where column names are the keys</span>

<span style="">ContentValues</span><span style=""> values </span><span style="">=</span><span style="">
</span><span style="">new</span><span style=""> </span><span style="">ContentValues</span><span style="">();</span>

<span style="">values</span><span style="">.</span><span style="">put</span><span style="">(</span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_ENTRY_ID</span><span style="">,</span><span style=""> id</span><span style="">);</span>

<span style="">values</span><span style="">.</span><span style="">put</span><span style="">(</span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_TITLE</span><span style="">,</span><span style=""> title</span><span style="">);</span>

<span style="">values</span><span style="">.</span><span style="">put</span><span style="">(</span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_CONTENT</span><span style="">,</span><span style=""> content</span><span style="">);</span>

<span style=""></span>

<span style="">// Insert the new row, returning the primary key value of the new row</span>

<span style="">long</span><span style=""> newRowId</span><span style="">;</span>

<span style="">newRowId </span><span style="">=</span><span style=""> db</span><span style="">.</span><span style="">insert</span><span style="">(</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">TABLE_NAME</span><span style="">,</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_NULLABLE</span><span style="">,</span>

<span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; values</span><span style="">);</span>

<span style="">[insert()](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#insert(java.lang.String,%20java.lang.String,%20android.content.ContentValues))</span><span style="">&nbsp;方法的第一个参数是“表名”。第二个参数将提供一些列名，当[<span style="">ContentValues</span>](http://developer.android.com/reference/android/content/ContentValues.html)&nbsp;为空时，framework会给这些列插入NULL（如果你给这个参数传null，当没有&#20540;时，framework将不会插入）。</span>

<span style="">从数据库中读取数据</span>

<span style=""></span>

<span style="">要从数据库中读取数据，使用&nbsp;[<span style="">query()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#query(boolean,%20java.lang.String,%20java.lang.String%5B%5D,%20java.lang.String,%20java.lang.String%5B%5D,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String))&nbsp;方法，向它传入插叙条件以及需要返回的列。查询的结果将会通过Cursor对象返回：</span>

<span style="">SQLiteDatabase</span><span style=""> db </span><span style="">=</span><span style=""> mDbHelper</span><span style="">.</span><span style="">getReadableDatabase</span><span style="">();</span>

<span style=""></span>

<span style="">// Define a _projection_ that specifies which columns from the database</span>

<span style="">// you will actually use after this query.</span>

<span style="">String</span><span style="">[]</span><span style=""> projection </span>
<span style="">=</span><span style=""> </span><span style="">{</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">_ID</span><span style="">,</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_TITLE</span><span style="">,</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_UPDATED</span><span style="">,</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">...</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">};</span>

<span style=""></span>

<span style="">// How you want the results sorted in the resulting Cursor</span>

<span style="">String</span><span style=""> sortOrder </span><span style="">=</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_UPDATED
</span><span style="">&#43;</span><span style=""> </span><span style="">&quot; DESC&quot;</span><span style="">;</span>

<span style=""></span>

<span style="">Cursor</span><span style=""> c </span><span style="">=</span><span style=""> db</span><span style="">.</span><span style="">query</span><span style="">(</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedEntry</span><span style="">.</span><span style="">TABLE_NAME</span><span style="">,</span><span style="">&nbsp;
</span><span style="">// The table to query</span>

<span style="">&nbsp;&nbsp;&nbsp; projection</span><span style="">,</span><span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span><span style="">// The columns to return</span>

<span style="">&nbsp;&nbsp;&nbsp; selection</span><span style="">,</span><span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span><span style="">// The columns for the WHERE clause</span>

<span style="">&nbsp;&nbsp;&nbsp; selectionArgs</span><span style="">,</span><span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span><span style="">// The values for the WHERE clause</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">null</span><span style="">,</span><span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span><span style="">// don't group the rows</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">null</span><span style="">,</span><span style="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span><span style="">// don't filter by row groups</span>

<span style="">&nbsp;&nbsp;&nbsp; sortOrder&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="">// The sort order</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">);</span>

<span style="">要查看cursor中的数据，你每一次读取前都需要使用cursor的一个方法。一般来说，你需要在开始时调用&nbsp;[<span style="">moveToFirst()</span>](http://developer.android.com/reference/android/database/Cursor.html#moveToFirst())方法，它会将游标指向 结果集中的第一项。Cursor中的每一行（row）数据你都可以调用Cursor中的一种get方法，例如&nbsp;[<span style="">getString()</span>](http://developer.android.com/reference/android/database/Cursor.html#getString(int))&nbsp;或者&nbsp;[<span style="">getLong()</span>](http://developer.android.com/reference/android/database/Cursor.html#getLong(int))。每个get方法都需要传递一个当前列的索引，你可以通过调用&nbsp;[<span style="">getColumnIndex()</span>](http://developer.android.com/reference/android/database/Cursor.html#getColumnIndex(java.lang.String))&nbsp;或者&nbsp;[<span style="">getColumnIndexOrThrow()</span>](http://developer.android.com/reference/android/database/Cursor.html#getColumnIndexOrThrow(java.lang.String))方法来获得索引。例如：</span>

<span style="">cursor</span><span style="">.</span><span style="">moveToFirst</span><span style="">();</span>

<span style="">long</span><span style=""> itemId </span><span style="">=</span><span style=""> cursor</span><span style="">.</span><span style="">getLong</span><span style="">(</span>

<span style="">&nbsp;&nbsp;&nbsp; cursor</span><span style="">.</span><span style="">getColumnIndexOrThrow</span><span style="">(</span><span style="">FeedEntry</span><span style="">.</span><span style="">_ID</span><span style="">)</span>

<span style="">);</span>

<span style="">删除数据库中的数据</span>

<span style=""></span>

<span style="">要从表中删除一行数据，你需要提供能够定位到这一行的查询条件。数据库的API提供了一种能够阻止SQL注入的创建查询条件的机制。 这个机制将查询条件以及查询参数分离。（The mechanism divides the selection specification into a selection clause and selection arguments. The clause defines the columns to look at, and also allows you
 to combine column tests. The arguments are values to test against that are bound into the clause.） 由于这种机制产生的结果不是常规的SQL语句，它有效地防止了SQL注入。</span>

<span style="">// Define 'where' part of query.</span>

<span style="">String</span><span style=""> selection </span><span style="">=</span><span style="">
</span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_ENTRY_ID
</span><span style="">&#43;</span><span style=""> </span><span style="">&quot; LIKE ?&quot;</span><span style="">;</span>

<span style="">// Specify arguments in placeholder order.</span>

<span style="">String</span><span style="">[]</span><span style=""> selectionArgs
</span><span style="">=</span><span style=""> </span><span style="">{</span><span style="">
</span><span style="">String</span><span style="">.</span><span style="">valueOf</span><span style="">(</span><span style="">rowId</span><span style="">)</span><span style="">
</span><span style="">};</span>

<span style="">// Issue SQL statement.</span>

<span style="">db</span><span style="">.</span><span style="">delete</span><span style="">(</span><span style="">table_name</span><span style="">,</span><span style=""> selection</span><span style="">,</span><span style=""> selectionArgs</span><span style="">);</span>

<span style="">更新数据库</span>

<span style=""></span>

<span style="">当你需要修改数据库中的数据时，使用&nbsp;[<span style="">update()</span>](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#update(java.lang.String,%20android.content.ContentValues,%20java.lang.String,%20java.lang.String%5B%5D))&nbsp;方法。</span>

<span style="">SQLiteDatabase</span><span style=""> db </span><span style="">=</span><span style=""> mDbHelper</span><span style="">.</span><span style="">getReadableDatabase</span><span style="">();</span>

<span style=""></span>

<span style="">// New value for one column</span>

<span style="">ContentValues</span><span style=""> values </span><span style="">=</span><span style="">
</span><span style="">new</span><span style=""> </span><span style="">ContentValues</span><span style="">();</span>

<span style="">values</span><span style="">.</span><span style="">put</span><span style="">(</span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_TITLE</span><span style="">,</span><span style=""> title</span><span style="">);</span>

<span style=""></span>

<span style="">// Which row to update, based on the ID</span>

<span style="">String</span><span style=""> selection </span><span style="">=</span><span style="">
</span><span style="">FeedEntry</span><span style="">.</span><span style="">COLUMN_NAME_ENTRY_ID
</span><span style="">&#43;</span><span style=""> </span><span style="">&quot; LIKE ?&quot;</span><span style="">;</span>

<span style="">String</span><span style="">[]</span><span style=""> selectionArgs
</span><span style="">=</span><span style=""> </span><span style="">{</span><span style="">
</span><span style="">String</span><span style="">.</span><span style="">valueOf</span><span style="">(</span><span style="">rowId</span><span style="">)</span><span style="">
</span><span style="">};</span>

<span style=""></span>

<span style="">int</span><span style=""> count </span><span style="">=</span><span style=""> db</span><span style="">.</span><span style="">update</span><span style="">(</span>

<span style="">&nbsp;&nbsp;&nbsp; </span><span style="">FeedReaderDbHelper</span><span style="">.</span><span style="">FeedEntry</span><span style="">.</span><span style="">TABLE_NAME</span><span style="">,</span>

<span style="">&nbsp;&nbsp;&nbsp; values</span><span style="">,</span>

<span style="">&nbsp;&nbsp;&nbsp; selection</span><span style="">,</span>

<span style="">&nbsp;&nbsp;&nbsp; selectionArgs</span><span style="">);</span>

            <div>
                作者：sweetvvck 发表于2014/9/30 23:55:32 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38645119)
            </div>
            <div>
            阅读：575 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38645119#comments)
            </div>