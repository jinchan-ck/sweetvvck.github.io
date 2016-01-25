---
title: '[原]Gitflow实践'
tags: [Git, Gitflow]
category: [Git, 项目管理]
date: 2015-12-16 01:14:03
---

转载请注明出处：[Gitflow实践](http://blog.csdn.net/sweetvvck/article/details/50245147)

# Gitflow实践

这两周在和别的团队的两个小伙伴开发新项目，他们团队刚刚成立不久，各种规范还没跟上，于是我便各种安利我们团队的工作流，其中代码管理方面我就推荐他们使用gitflow。在给他们讲gitflow的过程中我发现他们不是很理解这种工作方式，或者说不太明白为什么要这样做，为了加深自己对gitflow的理解我觉得有必要记录一下，也让正在学习使用gitflow的同学们有个初步的了解。

* * *

## Git工作流

现在越来越多的项目开始使用git做为版本控制工具，我对版本控制工具的最初印象是：能把代码提交到远端让大家一起协作，能开分支，能回滚代码，能看到每次提交的修改等。不过git命令具体如何使用不是本文的重点(熟悉git可以参考[ GIT基本概念和用法总结](http://blog.csdn.net/sweetvvck/article/details/38414713) 和[ git - 简易指南](http://blog.csdn.net/sweetvvck/article/details/38548985))，本文的重点是在项目中如何使用git来高效清晰的处理开发协作，版本控制。Git的工作流其实就是对git在项目上的一个完整的使用方式归纳总结，比较流行的git工作流有：Gitflow Workflow, Centralized Workflow, Feature Branch Workflow, Forking Workflow。

值得注意的是，这些workflow只是作为如何更好的使用git的指导方针，而非`"铁律"`，我们也可以根据具体项目来组合使用不同的workflow。本文重点讲解Gitflow Workflow，有想了解其他git工作流的可以参考这篇文章：[Comparing Workflows](https://www.atlassian.com/git/tutorials/comparing-workflows)。

## Gitflow workflow

Gitflow从功能开发到正式发布再到热修复等都有相应的策略管理，可以说是非常的完善，对于大型的项目也能够很好的管理。

### Gitflow 分支

Gitflow使用不同的分支表达了它在工作流中的不同概念：

*   **Master分支存放所有正式发布的版本，可以作为项目历史版本记录分支**
*   **Develop分支为主开发分支**
*   **Feature/xx分支为新功能分支，feature分支都是基于develop创建的，开发完成后会合并到develop分支上**
*   **Release分支基于最新develop分支创建，当新功能足够发布一个新版本(或者接近新版本发布的截止日期)，从develop分支创建一个release分支作为新版本的起点，开发完成后合并到master并打上版本号，同时也合并到develop，更新最新开发分支**
*   **Hotfix分支基于Master分支创建，对线上版本的bug进行修复，完成后直接合并到master分支和develop分支**

![Gitflow分支](https://www.atlassian.com/git/images/tutorials/collaborating/comparing-workflows/gitflow-workflow/05.svg)

### Gitflow具体流程

上文提到，从项目启动到发布版本都能够使用gitflow管理，具体如何管理，下 main这张图表达的很清楚：

![这里写图片描述](http://nvie.com/img/git-model@2x.png)

从上图可以看到，随着时间的推移：

1.  项目启动时只有master分支(图最右侧，蓝色)，开发到0.1版本时给它打上tag:0.1；
2.  接着创建了develop分支(黄色)开始接下来的开发；
3.  在开发的过程中发现0.1版本有bug，基于master分支0.1版本创建hotfix分支修复bug，修复完成后同时合并到develop分支和master分支，并在master分支上打上版本号；
4.  团队成员创建不同的feature分支(红色)开发下个版本的新功能，完成后合并到develop分支上；
5.  当feature完成情况按照项目计划能够发布新版本1.0时，创建release分支，对该分支进行测试修复，通过测试后release分支将被同时合并到develop分支和master分支，同时master分支打上相应版本号；
6.  继续上面的流程

⚠️注意：feature与其它分支互不影响，不必要在发布新版本前完成所有feature，发布版本时也可以有feature开发同时进行。

### 使用

Gitflow workflow是由[Vincent Driessen](http://nvie.com/) 提出来的，要实现上述的工作流程需要使用到他创建的命令行工具[git-flow](https://github.com/nvie/gitflow) 具体如何使用请参考[git-flow 备忘清单](http://danielkummer.github.io/git-flow-cheatsheet/index.zh_CN.html)。

另外，有一款git客户端软件[sourcetree](https://www.sourcetreeapp.com/) 集成了gitflow命令，提供了非常便捷的方式使用gitflow流程。

## 总结

熟练掌握和Gitflow workflow能够团队内项目协作开发流程更加规范化，更加清晰化，但是不必过于拘泥于其定义的流程，这类workflow只是使用git的指导方针，目的都是高效的使用git协作。

## 参考资料

1.  [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/)
2.  [Comparing Workflows](https://www.atlassian.com/git/tutorials/comparing-workflows)
3.  [git-flow 备忘清单](http://danielkummer.github.io/git-flow-cheatsheet/index.zh_CN.html)

                作者：sweetvvck 发表于2015/12/16 1:14:03 [原文链接](http://blog.csdn.net/sweetvvck/article/details/50245147)


            阅读：508 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/50245147#comments)
