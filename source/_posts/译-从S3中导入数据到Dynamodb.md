---
title: '[译]从S3中导入数据到Dynamodb'
tags: [Aws]
date: 2014-12-19 19:04:20
---

<div><span style="font-size:13px"><span style="font-family:verdana,arial,sans-serif">本节假设你已经从Dynamodb中导出过数据，并且导出的文件以及被存入S3。</span>`文件内部结构会在`[Verify
 Data Export File](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-importexport-ddb-pipelinejson-verifydata2.html)&nbsp;中描述。</span></div>
<div style="font-family:verdana,arial,sans-serif"><span style="font-size:13px">我们称之前导出数据的原始表为_source table_，数据将要被导入的表为_destination table_。你可以将S3中的导出文件导入到dynamodb的表中，但是要先确保满足下面条件：</span></div>

*   <span style="font-size:13px"><span style="font-family:verdana,arial,sans-serif">The destination table 已经存在。 (导入任务不会为你创建表)</span></span>
*   <span style="font-size:13px">The destination table 与 source table 有相同的名称。</span>
*   <span style="font-size:13px">The destination table 与 source table 有相同的结构。</span>
<div><span style="font-size:13px"><span style="font-family:verdana,arial,sans-serif">Destination table不一定要是空的。然而，导入进程会替换掉表中有相同主键的数据。例如，你有一个_Customer_&nbsp;表，它的主键是_CustomerId_，并且只有三个items (_CustomerId_&nbsp;1, 2, and 3)。如果要导入的文件中同样包含_CustomerID_&nbsp;为1,
 2, and 3的items，这些在destination table中的items将会被导入文件中的数据替换。如果文件中还包含CustomerId为4的item，那么这个item会被加入到</span>destination table中。</span></div>
<div style="font-family:verdana,arial,sans-serif"><span style="font-size:13px">Destination table 可以在不同的AWS region。例如，假设你有个一个&nbsp;_Customer_&nbsp;table在US West (Oregon) region，然后将它的数据导出到了Amazon S3中。你可以将它导入到在&nbsp;EU (Ireland) region中有相同表明，相同主键的表中。这种做法被称为
_cross-region_&nbsp;导出和导入。</span></div>
<div style="font-family:verdana,arial,sans-serif"><span style="font-size:13px">注意到AWS管理控制台允许你一次导出多个表的数据。但是，不同的是，你一次只能导入一个表。</span></div>
<div style="font-family:verdana,arial,sans-serif"><span style="font-size:13px">

</span></div>
<div style="font-family:verdana,arial,sans-serif"><span style="font-size:13px">**从S3导入数据到DynamoDB**</span></div>

1.  <span style="font-size:13px"><span style="font-family:verdana,arial,sans-serif">登陆AWS管理控制台，然后打开dynamodb控制台：&nbsp;[https://console.aws.amazon.com/dynamodb/](https://console.aws.amazon.com/dynamodb/).</span></span>
2.  <span style="font-size:13px">(可选) 如果你想做块区域导入，点击右上角的<span style="font-weight:bold">Select a Region</span>&nbsp;然后选择要导入的表的区域。控制台会显示该区域下的所有表。如果destination table不存在的话，你需要先创建它。</span>
3.  <span style="font-size:13px">在&nbsp;<span style="font-weight:bold">Amazon DynamoDB Tables</span>&nbsp;页面, 点击&nbsp;<span style="font-weight:bold">Export/Import</span>.</span>
4.  <span style="font-size:13px">在&nbsp;<span style="font-weight:bold">Export/Import</span>&nbsp;页面，选择一个你要导入的表，然后点击&nbsp;<span style="font-weight:bold">Import into DynamoDB</span>.</span>
5.  <span style="font-size:13px">在&nbsp;<span style="font-weight:bold">Create Import Table Data Pipeline</span>&nbsp;页面，按下面步骤操作：</span>
6.  1.  <span style="font-size:13px"><span style="font-weight:bold">S3 Input Folder</span>&nbsp;文本框中输入导入文件对应的 Amazon S3 URI。例如:&nbsp;`s3://mybucket/exports`这个URI的规则应该是这样&nbsp;`s3://<span style="color:rgb(255,0,0)"><code style="font-family:'Courier New',Courier,mono">bucketname`</span>/<span style="color:rgb(255,0,0)">`folder`</span></code>
 :</span>
    2.  *   <span style="font-size:13px">`bucketname`&nbsp;是S3中bucket的名称</span>
        *   <span style="font-size:13px">`folder`&nbsp;表示存放要导入的文件的名称</span>

        3.  <span style="font-size:13px">导入任务会通过指定的S3位置找到对应的文件。`文件内部结构会在`[Verify
 Data Export File](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-importexport-ddb-pipelinejson-verifydata2.html)&nbsp;中描述。</span>
    4.  <span style="font-size:13px">在 <span style="font-weight:bold">S3 Log Folder</span>&nbsp;文本框中输入一个S3 URI，导出过程的日志将被存储在相应的folder中。例如：`s3://mybucket/logs/`

<span style="font-weight:bold">S3 Log Folder</span>&nbsp;URI的&#26684;式和 <span style="font-weight:bold">
S3 Output Folder</span>的&#26684;式相同。</span>
    5.  <span style="font-size:13px">在&nbsp;<span style="font-weight:bold">Throughput Rate</span>&nbsp;文本框中可选择一个百分比。这个比率表示在导出过程中会消耗读吞吐量的上限。例如，假设你要导出的表的读吞吐量是20，同时你设置的百分比是40%。那么导出时所消耗的吞吐量将不会超过8.

如果你在导出多个表，这个 <span style="font-weight:bold">Throughput Rate</span>&nbsp;将会被应用到每个表中。</span>
    6.  <span style="font-size:13px"><span style="font-weight:bold">Execution Timeout</span>&nbsp;文本框，输入导出任务的超时时长。如果导出任务在这个时长内还没执行完成，此任务会失败。</span>
    7.  <span style="font-size:13px"><span style="font-weight:bold">Send notifications to</span>&nbsp;文本框，输入一个email地址。在 pipeline被创建后，你将会收到一封email邀请订阅Amazon SNS；如果你接受了此邀请，在每次执行导出操作时你都将会收到email通知。</span>
    8.  <span style="font-size:13px"><span style="font-weight:bold">Data Pipeline Role</span>, 选择&nbsp;<span style="font-weight:bold">DataPipelineDefaultRole</span>.</span>
    9.  <span style="font-size:13px"><span style="font-weight:bold">Resource Role</span>, 选择&nbsp;<span style="font-weight:bold">DataPipelineDefaultResourceRole</span></span>

7.  <span style="font-size:13px">确认好以上设置然后点击 <span style="font-weight:bold">Create Export Pipeline</span>.</span>
<div><span style="font-size:13px">你的 pipeline 现在将被创建；这个过程可能会花费几分钟完成。要查看当前状态，移步&nbsp;[Managing
 Export and Import Pipelines](http://docs.aws.amazon.com/zh_cn/amazondynamodb/latest/developerguide/DataPipelineExportImport.ManagingPipelines.html "Managing Export and Import Pipelines").</span></div>
<div style="font-family:verdana,arial,sans-serif"><span style="font-size:13px">导入任务会在你的pipeline创建好后立即执行。</span></div>
<div></div>

            <div>
                作者：sweetvvck 发表于2014/12/19 19:04:20 [原文链接](http://blog.csdn.net/sweetvvck/article/details/42030729)
            </div>
            <div>
            阅读：1037 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/42030729#comments)
            </div>
