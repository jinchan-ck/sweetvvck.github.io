---
title: '[译]Aws Dynamodb数据导出到S3'
tags: [Aws, Dynamodb, S3]
date: 2014-12-19 11:55:21
---

本节将描述如何从一个或多个DynamoDB的表导出数据到S3的bucket中。在执行导出之前你需要提前创建好S3的bucket。
**注意**
如果你还没有使用过AWS Data Pipeline，在执行下面的流程前你需要先去创建两个IAM roles。更多信息，请移步
[
Creating IAM Roles for AWS Data Pipeline](http://docs.aws.amazon.com/zh_cn/amazondynamodb/latest/developerguide/DataPipelineExportImport.Prereqs.html#DataPipelineExportImport.Prereqs.IAMRoles "Creating IAM Roles for AWS Data Pipeline")。
**从DynamoDB中导出数据到S3**

1.  登陆到AWS管理员控制台，打开DynamoDB console。&nbsp;[https://console.aws.amazon.com/dynamodb/](https://console.aws.amazon.com/dynamodb/).
2.  在&nbsp;Amazon DynamoDB Tables&nbsp;页面, 点击&nbsp;Export/Import.
3.  在 Export/Import 页面, 选择你想导出的表，然后点击
Export from DynamoDB.
4.  在&nbsp;Create Export Table Data Pipeline(s)&nbsp;页面，按下面流程操作：
5.  1.  在&nbsp;S3 Output Folder&nbsp;文本框中填写 Amazon S3 URI，导出文件将存放在S3中相应的文件夹下。例如：
`s3://mybucket/exports`

这个URI的规则应该是这样&nbsp;`s3://bucketname`/`folder`
 :
    2.  *   `bucketname`&nbsp;是S3中bucket的名称
        *   `folder`&nbsp;表示此bucket下文件夹的名称。如果这个文件夹不存在，它将被自动创建。如果你不指定这个名称，它将被自动授予一个名字，名字的规则是：
`s3://bucketname`/`region`/`tablename`.

        3.  在 S3 Log Folder&nbsp;文本框中输入一个S3 URI，导出过程的日志将被存储在相应的folder中。例如：`s3://mybucket/logs/`

S3 Log Folder&nbsp;URI的&#26684;式和
S3 Output Folder的&#26684;式相同。
    4.  在&nbsp;Throughput Rate&nbsp;文本框中可选择一个百分比。这个比率表示在导出过程中会消耗读吞吐量的上限。例如，假设你要导出的表的读吞吐量是20，同时你设置的百分比是40%。那么导出时所消耗的吞吐量将不会超过8.

如果你在导出多个表，这个 Throughput Rate&nbsp;将会被应用到每个表中。
    5.  Execution Timeout&nbsp;文本框，输入导出任务的超时时长。如果导出任务在这个时长内还没执行完成，此任务会失败。
    6.  Send notifications to&nbsp;文本框，输入一个email地址。在 pipeline被创建后，你将会收到一封email邀请订阅Amazon SNS；如果你接受了此邀请，在每次执行导出操作时你都将会收到email通知。
    7.  &nbsp;Schedule&nbsp;选项，选择下面其中一项：
    8.  *   One-time Export&nbsp;—导出任务将在pipeline被创建后立即执行。
        *   Daily Export&nbsp;— 导出任务将会在你所指定的时刻执行，同时会在每天的那个时刻重复。

        9.  Data Pipeline Role, 选择&nbsp;DataPipelineDefaultRole.
    10.  Resource Role, 选择&nbsp;DataPipelineDefaultResourceRole

6.  确认好以上设置然后点击&nbsp;Create Export Pipeline.
你的 pipeline 现在将被创建；这个过程可能会花费几分钟完成。要查看当前状态，移步&nbsp;[Managing
 Export and Import Pipelines](http://docs.aws.amazon.com/zh_cn/amazondynamodb/latest/developerguide/DataPipelineExportImport.ManagingPipelines.html "Managing Export and Import Pipelines").
如果你选择的Schedule是 one-time export，导出任务将在pipeline 创建成功后立即执行。如果你选择的是daily export，导出任务将会在指定时刻执行，同时会在每天的那个时刻执行导出任务。
当导出任务结束，你可以到 [
Amazon S3 console](http://console.aws.amazon.com/s3)&nbsp;来查看导出文件。这个文件将会在以你的表名命名的文件夹中，而文件名将会是这种&#26684;式：&nbsp;`[YYYY-MM-DD_HH.MM](http://YYYY-MM-DD_HH.MM)。文件内部结构会在`[Verify
 Data Export File](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-importexport-ddb-pipelinejson-verifydata2.html)&nbsp;中描述。



                作者：sweetvvck 发表于2014/12/19 11:55:21 [原文链接](http://blog.csdn.net/sweetvvck/article/details/42026517)


            阅读：1174 评论：1 [查看评论](http://blog.csdn.net/sweetvvck/article/details/42026517#comments)
