---
title: '[译]Android学习路线（二十九）保存数据到SQLite中'
tags: []
date: 2014-09-30 23:55:32
---

对于可复用或者结构化的数据来说，把它们存储到数据库中是理想的方式。学习本课前你需要对通常的数据库有所了解，本课在此前提下会帮助你学习如何在android系统中操作SQLite数据库。你需要使用到的APIs都可以在[android.database.sqlite](http://developer.android.com/reference/android/database/sqlite/package-summary.html) 包中访问到。

定义一个&#26684;式和契约


<!--more-->
SQL数据库最主要的标准之一是其&#26684;式（Schema）：它用来声明数据库的组织。Schema可以通过你用来创建数据库的语句来表示。你会发现创建一个能够有条理地，明确指定schema布局的 "伙伴 "类(也被称为 "关系类 ")是非常有帮助的。

关系类其实就是个定义常量的容器，这些常量包含URIs,tables以及colums的名称。这个关系类允许你在同一个包下的所有类中都能够访问。这样的话，你只要在这里改变一个列名，你的所有代码都会受影响。

一个好的组织关系类的方法是，让你的关系类中对于整个数据库来说是全局可用的常量定义在关系类的顶级，然后为每个表在该类中建立内部类。

**提示:** 通过实现 [BaseColumns](http://developer.android.com/reference/android/provider/BaseColumns.html) 接口，你的内部类能够继承一个名称为_ID的属性，它在默写类(例如cursor
 adapter)中被期望存在。它不是必须的，但是如果它的存在能够让你的数据库和Android框架相处更加和谐。

例如，下面的代码片段定义了一个表的表明和列名：
```java
public final class FeedReaderContract {

    // To prevent someone from accidentally instantiating the contract class,

    // give it an empty constructor.

    public FeedReaderContract() {}



    /* Inner class that defines the table contents */

    public static abstract class FeedEntry implements BaseColumns {

        public static final String TABLE_NAME = "entry ";

        public static final String COLUMN_NAME_ENTRY_ID = "entryid ";

        public static final String COLUMN_NAME_TITLE = "title ";

        public static final String COLUMN_NAME_SUBTITLE = "subtitle ";

        ...

    }

}

通过SQL Helper创建一个数据库



一旦你定义了你的数据库的样子，你就需要实现一些方法来创建和保持数据库和表。下面是创建和删除一个表的典型的语句：

private static
final String TEXT_TYPE = "TEXT";

private static final String COMMA_SEP = ",";

private static final String SQL_CREATE_ENTRIES =  
	"CREATE TABLE"
	+ FeedEntry.TABLE_NAME
	+ " ( "
	+ FeedEntry._ID
	+ "INTEGER PRIMARY KEY,"
	+ FeedEntry.COLUMN_NAME_ENTRY_ID
	+ "TEXT_TYPE  ; COMMA_SEP"
	+ FeedEntry.COLUMN_NAME_TITLE
	+ "TEXT_TYPE  ; COMMA_SEP"

    ... // Any other options for the CREATE command

     " ) ";



private static
final String SQL_DELETE_ENTRIES
= "DROP TABLE IF EXISTS " + FeedEntry.TABLE_NAME;

 ```
就像是你保存在内部存储中的文件一样，Android将你的数据库存储在和应用关联的私有空间内。你的数据是安全的，因为默认这个区域不能被其他的app访问。

在 [SQLiteOpenHelper](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html) 类中能够找到很多有用的API。当你使用这个类来获得数据库的引用时，系统只会在需要的时候才会去做这种可能长时间的创建/更新数据酷的操作，而不会在app启动时这样做。你所需要做的只有调用 [getWritableDatabase()](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#getWritableDatabase()) 或者[getReadableDatabase()](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#getReadableDatabase())。

**提示:** 由于这可能会很长时间，确保要在后台线程中调用 [getWritableDatabase()](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#getWritableDatabase()) 或者[getReadableDatabase()](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#getReadableDatabase()) 方法，例如在 [AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html) 或者 [IntentService](http://developer.android.com/reference/android/app/IntentService.html)中。

在使用[SQLiteOpenHelper](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html)时，创建一个它的子类，实现 [onCreate()](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#onCreate(android.database.sqlite.SQLiteDatabase))， [onUpgrade()](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#onUpgrade(android.database.sqlite.SQLiteDatabase,%20int,%20int)) 和[onOpen()](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#onOpen(android.database.sqlite.SQLiteDatabase)) 回调方法。你可能还想实现[onDowngrade()](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html#onDowngrade(android.database.sqlite.SQLiteDatabase,%20int,%20int))方法，但是它并不是必须的。

例如，下面展示了如何实现 [SQLiteOpenHelper](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html) 类，使用上面的一些命令：
```java
public class
FeedReaderDbHelper extends
SQLiteOpenHelper {

    // If you change the database schema, you must increment the database version.

    public static
final int DATABASE_VERSION
= 1;

    public static
final String DATABASE_NAME
=  "FeedReader.db ";



    public FeedReaderDbHelper(Context context)
{

        super(context, DATABASE_NAME,
null, DATABASE_VERSION);

    }

    public void onCreate(SQLiteDatabase db)
{

        db.execSQL(SQL_CREATE_ENTRIES);

    }

    public void onUpgrade(SQLiteDatabase db,
int oldVersion,
int newVersion)
{

        // This database is only a cache for online data, so its upgrade policy is

        // to simply to discard the data and start over

        db.execSQL(SQL_DELETE_ENTRIES);

        onCreate(db);

    }

    public void onDowngrade(SQLiteDatabase db,
int oldVersion,
int newVersion)
{

        onUpgrade(db, oldVersion, newVersion);

    }

}
```

要访问你的数据库，实例化你所创建的[SQLiteOpenHelper](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html)的子类：

FeedReaderDbHelper mDbHelper =
new FeedReaderDbHelper(getContext());

向数据库中插入数据



通过将 [ContentValues](http://developer.android.com/reference/android/content/ContentValues.html) 对象传给[insert()](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#insert(java.lang.String,%20java.lang.String,%20android.content.ContentValues)) 方法来向数据库中插入数据：
```java
// Gets the data repository in write mode

SQLiteDatabase db = mDbHelper.getWritableDatabase();



// Create a new map of values, where column names are the keys

ContentValues values =
new ContentValues();

values.put(FeedEntry.COLUMN_NAME_ENTRY_ID, id);

values.put(FeedEntry.COLUMN_NAME_TITLE, title);

values.put(FeedEntry.COLUMN_NAME_CONTENT, content);



// Insert the new row, returning the primary key value of the new row

long newRowId;

newRowId = db.insert(

         FeedEntry.TABLE_NAME,

         FeedEntry.COLUMN_NAME_NULLABLE,

         values);
```
[insert()](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#insert(java.lang.String,%20java.lang.String,%20android.content.ContentValues)) 方法的第一个参数是“表名”。第二个参数将提供一些列名，当[ContentValues](http://developer.android.com/reference/android/content/ContentValues.html) 为空时，framework会给这些列插入NULL（如果你给这个参数传null，当没有&#20540;时，framework将不会插入）。

从数据库中读取数据



要从数据库中读取数据，使用 [query()](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#query(boolean,%20java.lang.String,%20java.lang.String%5B%5D,%20java.lang.String,%20java.lang.String%5B%5D,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String)) 方法，向它传入插叙条件以及需要返回的列。查询的结果将会通过Cursor对象返回：
```java
SQLiteDatabase db = mDbHelper.getReadableDatabase();



// Define a _projection_ that specifies which columns from the database

// you will actually use after this query.

String[] projection
= {

    FeedEntry._ID,

    FeedEntry.COLUMN_NAME_TITLE,

    FeedEntry.COLUMN_NAME_UPDATED,

    ...

    };



// How you want the results sorted in the resulting Cursor

String sortOrder =

    FeedEntry.COLUMN_NAME_UPDATED
 ;  " DESC ";



Cursor c = db.query(

    FeedEntry.TABLE_NAME,
// The table to query

    projection,                              
// The columns to return

    selection,                               
// The columns for the WHERE clause

    selectionArgs,                           
// The values for the WHERE clause

    null,                                    
// don't group the rows

    null,                                    
// don't filter by row groups

    sortOrder                                 // The sort order

    );
```
要查看cursor中的数据，你每一次读取前都需要使用cursor的一个方法。一般来说，你需要在开始时调用 [moveToFirst()](http://developer.android.com/reference/android/database/Cursor.html#moveToFirst())方法，它会将游标指向 结果集中的第一项。Cursor中的每一行（row）数据你都可以调用Cursor中的一种get方法，例如 [getString()](http://developer.android.com/reference/android/database/Cursor.html#getString(int)) 或者 [getLong()](http://developer.android.com/reference/android/database/Cursor.html#getLong(int))。每个get方法都需要传递一个当前列的索引，你可以通过调用 [getColumnIndex()](http://developer.android.com/reference/android/database/Cursor.html#getColumnIndex(java.lang.String)) 或者 [getColumnIndexOrThrow()](http://developer.android.com/reference/android/database/Cursor.html#getColumnIndexOrThrow(java.lang.String))方法来获得索引。例如：

cursor.moveToFirst();

long itemId = cursor.getLong(

    cursor.getColumnIndexOrThrow(FeedEntry._ID)

);

删除数据库中的数据



要从表中删除一行数据，你需要提供能够定位到这一行的查询条件。数据库的API提供了一种能够阻止SQL注入的创建查询条件的机制。 这个机制将查询条件以及查询参数分离。（The mechanism divides the selection specification into a selection clause and selection arguments. The clause defines the columns to look at, and also allows you
 to combine column tests. The arguments are values to test against that are bound into the clause.） 由于这种机制产生的结果不是常规的SQL语句，它有效地防止了SQL注入。

// Define 'where' part of query.

String selection =
FeedEntry.COLUMN_NAME_ENTRY_ID
 ;  " LIKE ? ";

// Specify arguments in placeholder order.

String[] selectionArgs
= {
String.valueOf(rowId)
};

// Issue SQL statement.

db.delete(table_name, selection, selectionArgs);

更新数据库



当你需要修改数据库中的数据时，使用 [update()](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#update(java.lang.String,%20android.content.ContentValues,%20java.lang.String,%20java.lang.String%5B%5D)) 方法。

```java
SQLiteDatabase db = mDbHelper.getReadableDatabase();



// New value for one column

ContentValues values =
new ContentValues();

values.put(FeedEntry.COLUMN_NAME_TITLE, title);



// Which row to update, based on the ID

String selection =
FeedEntry.COLUMN_NAME_ENTRY_ID
 ;  " LIKE ? ";

String[] selectionArgs
= {
String.valueOf(rowId)
};



int count = db.update(

    FeedReaderDbHelper.FeedEntry.TABLE_NAME,

    values,

    selection,

    selectionArgs);
```

                作者：sweetvvck 发表于2014/9/30 23:55:32 [原文链接](http://blog.csdn.net/sweetvvck/article/details/38645119)


            阅读：575 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/38645119#comments)
