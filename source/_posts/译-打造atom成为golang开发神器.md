---
title: '[译]打造atom成为golang开发神器'
tags: []
date: 2015-12-29 00:37:30
---

在我在Windows系统上开发的日子里，我使用IDE开发数年之久，例如Visual Basic IDE, Borland Delphi IDE, Visual C&#43;&#43; 和最后的Visual Studio；但当我在大约10年前转到Mac OS X下开发后，我放弃了上述所有的IDE。

<span style="color:rgb(81,81,81); font-family:Raleway,sans-serif; font-size:20px; line-height:30px"></span>

我刚进入Mac编程世界的时候使用的是当时表现极好的Textmate编辑器。它是一个开发代码飞快的编辑器，拥有很好的语法高亮，拓展模块以及代码片段(code snippets)，让我再次感觉非常高产。经过几年的衰退期，由于它没有继续更新了，很多人转向了Sublime Text和传统的VIM编辑器了。

Atom刚出来的时候我尝试使用了一下，但当时它并没有准备好。而最近几天它正式发布官方1.0版本后我决定再次试用一下，我很高兴我又试用了下atom。

[https://atom.io/](https://atom.io/)

## 
安装主题

你一天将要花大部分时间看着代码，注视着你的编辑器，因此你总是必须要找到一个颜色搭配自然的主题，并且要能够让你的&#30524;睛觉得舒服。我认为这个因人而异，你需要找一个你最喜欢的。

我现在一直使用的主题是<span style="color:rgb(81,81,81); font-family:Raleway,sans-serif; font-size:20px; line-height:30px">One Dark UI Theme和<span style="color:rgb(81,81,81); font-family:Raleway,sans-serif; font-size:20px; line-height:30px">Monokai-Seti Syntax theme(译者注：atom的主题分为UI主题和语法主题)，我很享受使用这样的主题搭配。</span></span>

![atom-theme](http://marcio.io/img/atom-theme.png)

下图是这样的主题搭配在我的电脑上的效果:

![atom-editor](http://marcio.io/img/atom-editor.png)

#### 
monokai-seti

*   [https://atom.io/packages/monokai-seti](https://atom.io/packages/monokai-seti)

## 
安装开发专用字体

我第一次打开atom想做的第一件事情是：安装一个我更喜欢的开发专用字体，我使用免费字体“Inconsolata”有一阵子了。

你可以通过这个链接查看和下载这个字体：[http://www.levien.com/type/myfonts/inconsolata.html](http://www.levien.com/type/myfonts/inconsolata.html)

你可以使用标准的编辑器设置很便捷的切换正在使用的字体。

## 
安装开发语言包

Atom自带的标准包里涵盖了大部分开发语言。我做Go开发还差两个语言包，分别是Dockerfile语法和Google Protobuf语法，这两个在我的项目中大量被使用到。

*   language-docker:&nbsp;[https://atom.io/packages/language-docker](https://atom.io/packages/language-docker)
*   language-protobuf:&nbsp;[https://atom.io/packages/language-protobuf](https://atom.io/packages/language-protobuf)

## 
安装插件

#### 
go-plus

*   [https://atom.io/packages/go-plus](https://atom.io/packages/go-plus)

这个插件提供了Atom中几乎所有go语言开发的支持，包括<span style="color:rgb(81,81,81); font-family:Raleway,sans-serif; font-size:20px; line-height:30px">&nbsp;tools, build flows, linters, vet 和 coverage tools。它还包含很多代码片段和一些其它特性。</span>

在你的命令行中输入下面的命令来确保你安装了所有go tools：

<pre name="code" class="plain">go get -u golang.org/x/tools/cmd/...
go get -u github.com/golang/lint/golint</pre>

go-plus有非常多的特性，但我在开发时最喜欢的是它能够实时的给我反馈语法错误和编译错误。每当我保存一个文件，go-plus就会在后台运行你提前配置好的要执行的go tools，例如：go vet, go oracle, go build等等，然后将错误和警告在编辑器底部显示出来。这个功能非常赞，而且大大提升了开发速度。

![atom-go-plus-linter](http://marcio.io/img/atom-go-plus-linter.png)

它同样能够在编辑器的对应行上显示该行的编译错误提示和错误信息，这样你就能很快的定位哪一行有错。错误和警告分别用红色和淡黄色做区分。

![atom-go-plus-gutter-errors](http://marcio.io/img/atom-go-plus-gutter-errors.png)

#### 
go-rename

*   [https://atom.io/packages/go-rename](https://atom.io/packages/go-rename)

<span style="color:rgb(81,81,81); font-family:Raleway,sans-serif; font-size:20px">这个插件通过食用Go rename tool，提供非常智能和安全的 变量，方法和结构体重命名功能。当你选中一个目标时，你能够通过快捷键&nbsp;<span style="color:rgb(191,97,106); font-family:Menlo,Monaco,'Courier New',monospace; font-size:17px; line-height:30px; background-color:rgb(249,249,249)">ALT-R</span>&nbsp;很方便的初始化重命名对话框。</span>

<span style="color:rgb(49,49,49); font-size:1.5rem; line-height:1.25">让Atom更像VIM</span>

你可能想问我“那为什么不直接使用VIM呢？”情况是这样的，我确实有使用VIM一年多，但是我想尝试使用Atom，我很享受atom的体验，特别是我能够在atom上使用所有的VIM命令。

*   vim-mode:&nbsp;[https://atom.io/packages/vim-mode](https://atom.io/packages/vim-mode)
*   vim-surround:&nbsp;[https://atom.io/packages/vim-surround](https://atom.io/packages/vim-surround)
*   last-cursor-position:&nbsp;[https://atom.io/packages/last-cursor-position](https://atom.io/packages/last-cursor-position)

##### 
在 Keymap 文件中定义一些快捷键：

<div>

</div>
<div><pre name="code" class="plain">&#39;atom-text-editor:not(mini).autocomplete-active&#39;:
  &#39;ctrl-p&#39;: &#39;core:move-up&#39;
  &#39;ctrl-n&#39;: &#39;core:move-down&#39;

&#39;.vim-mode.command-mode:not(.mini)&#39;:
  &#39;ctrl-f&#39;: &#39;core:page-down&#39;
  &#39;/&#39;: &#39;find-and-replace:show&#39;</pre>

</div>
<div>

</div>

还有一个VIM模块Easy-Motion上面没有说到，这是因为它和Atom 1.0不兼容，但是我相信很快就会有人来更新它或者在创建一个新版本。

## 
自定义atom的TreeView

#### 
file-icons

*   [https://atom.io/packages/file-icons](https://atom.io/packages/file-icons)

我刚开始想这个插件能够让我的tree view色彩丰富，它提针对不同后缀的文件，文件夹供了大量的icon显示。然后我使用了一下它，发现它确实很酷。并且它能够让我很快的一扫就能找到我要找的文件。它还有些配置，可以让你选择显示哪些文件的icon等。

下面你可以看到如果你安装了file-icons插件后你的tree view会变成什么样。试试吧，我确定你会喜欢它的。

![file-icons](http://marcio.io/img/file-icons.png)

#### 
应用一些自定义CSS

默认的TreeView行距有些过高，所以我想要修改css减少行间的padding。还有一个要修改的地方是，treeview的字体也要修改成我在编辑框中使用的字体，来保持样式的一致性。我通常使用<span style="color:rgb(191,97,106); font-family:Menlo,Monaco,'Courier New',monospace; font-size:17px; line-height:30px; background-color:rgb(249,249,249)">Inconsolata</span>
 。

<pre name="code" class="plain">// style the background color of the tree view
.tree-view {
    font-family: &quot;Inconsolata&quot;;
    font-size: 12px;
}

.list-group li:not(.list-nested-item),
.list-tree li:not(.list-nested-item),
.list-group li.list-nested-item &gt; .list-item,
.list-tree li.list-nested-item &gt; .list-item {
    line-height:18px;
}

.list-group .selected:before,
.list-tree .selected:before {
    height:18px;
}

.list-tree.has-collapsable-children .list-nested-item &gt; .list-tree &gt; li,
.list-tree.has-collapsable-children .list-nested-item &gt; .list-group &gt; li {
    padding-left:12px;
}</pre>

### 
代码片段(Code Snippets)

大部分流行的编辑器和IDE都会使用code-completion针对不同语言的特定关键字自动补全代码。这样通常能够包含最常用的代码，但是离真正的补全还差一截。

但是Atom允许你在<span style="color:rgb(191,97,106); font-family:Menlo,Monaco,'Courier New',monospace; font-size:17px; line-height:30px; background-color:rgb(249,249,249)">snippets.cson</span>文件中创建自己的代码片段仓库。在Atom的菜单栏可以打开这个文件，然后你就可以创建自己的代码片段库了。

你需要使用<span style="color:rgb(191,97,106); font-family:Menlo,Monaco,'Courier New',monospace; font-size:17px; line-height:30px; background-color:rgb(249,249,249)">.source.go</span>&nbsp;作为scope，这样这个片段就只会在你编辑go文件时提示你了。

下面是我最近添加的一些代码片段：

<pre name="code" class="plain">&#39;.source.go&#39;:
    &#39;return nil and error&#39;:
      &#39;prefix&#39;: &#39;rne&#39;
      &#39;body&#39;: &#39;return nil, err&#39;

    &#39;return false and error&#39;:
      &#39;prefix&#39;: &#39;rfe&#39;
      &#39;body&#39;: &#39;return false, err&#39;

    &#39;Return True and Nil&#39;:
      &#39;prefix&#39;: &#39;rte&#39;
      &#39;body&#39;: &#39;return true, nil&#39;

    &#39;Import logrus&#39;:
      &#39;prefix&#39;: &#39;logrus&#39;
      &#39;body&#39;: &#39;log &quot;github.com/Sirupsen/logrus&quot;&#39;</pre>

一旦你创建好代码片段，你立马就能在编辑器中使用。我非常喜欢这个功能，他能让我编码速度飞快。

![atom-complete-snippets](http://marcio.io/img/atom-complete-snippets.png)

### 
Dash

Dash是一个Mac OS X下的非常棒的商业软件，它能够让你在离线模式下实时访问150&#43;的API 文档。我在做Ruby开发时使用了几年时间，现在做go开发同样适用它。

了解Dash：&nbsp;[https://kapeli.com/dash](https://kapeli.com/dash)

![atom-dash](http://marcio.io/img/atom-dash.png)

有一个Atom插件能够让你通过快捷键`CTRL-H`&nbsp;直接跳转动dash，这样查询选中方法的方法定义文档就非常方便了。

#### 
dash

[https://atom.io/packages/dash](https://atom.io/packages/dash)

## 
自定义编辑器样式

Atom有一个相比其它编辑器非常大的优点是，它能够通过食用css完全的自定义编辑器UI。如果你对atom不满意，几乎atom所有方面都能够被你自己修改和提高。

<span style="color:rgb(49,49,49); font-size:1.25rem; line-height:1.25">改变 Symbol View 的样式</span>

atom有一个让我很困扰的区域是原声的Symbols-View对话框，它的行太高了，并且不能很好的在查看窗口适应很多行显示。我更喜欢Sublime的显示方式，所以我把atom的symbol view的样式改成和sublime一样。

<pre name="code" class="css">.symbols-view {
  &amp;.select-list ol.list-group li .primary-line,
  &amp;.select-list ol.list-group li .secondary-line {

    font-family: Inconsolata;
    font-size: 14px;

    // let lines wrap
    text-overflow: initial;
    white-space: initial;
    overflow: initial;

    // reduce line-height
    line-height: 1.0em;
    padding-top: .1em;
    padding-bottom: .0em;

    // make sure wrapped lines get padding
    // padding-left: 21px;
    &amp;.icon:before {
      margin-left: -21px;
    }

    .character-match {
        color: rgb(200, 200, 10) !important;
    }
  }
}

.symbols-view {
  &amp;.select-list ol.list-group li .secondary-line {
      float: right;
      margin-top: -12px;
      padding-top: 0em;
      padding-bottom: 0em;
      font-size: 12px;
      color: rgba(200, 200, 10, 0.8) !important;
  }
}</pre>

这是一个更精简的Symbol View，可以看到行高减少了，行数提示放在了右侧：

![atom-symbol-view-styles](http://marcio.io/img/atom-symbol-view-styles.png)

### 
自定义行选中效果

有个很有趣的插件叫 Hightlight-Line:

[https://atom.io/packages/highlight-line](https://atom.io/packages/highlight-line)

这个插件允许你修改选中行的样式。在我的例子中，我在选中行上下侧加上了黄色的虚线。我喜欢这样的样式，它能够让我很好的识别我所选中的区域。

![atom-highlight-selected](http://marcio.io/img/atom-highlight-selected.png)

你可以将‘solid’替换为 ‘dashed’ 或者 ‘dotted’。

<pre name="code" class="css">atom-text-editor::shadow {

    .line.highlight-line {
        background: rgba(255, 255, 255, 0.05) !important;
    }

    .line.highlight-line-multi-line-dashed-bottom {
        border-bottom-color: yellow !important;
    }

    .line.highlight-line-multi-line-dashed-top {
        border-top-color: yellow !important;
    }
}</pre>

## 
为Go代码生成 Ctags

自动补全在开发中是一个非常重要的功能，同时也让开发这非常困扰。它的提示必须非常好不然的话经常出现的不对的提示信息会非常的讨厌。当需要提示的时候却没有提示时更是烦上加烦。

有一个非常棒的插件叫&nbsp;`gotags`&nbsp;，它能够兼容ctags并且专为go设计。它将AST工具化，并且会解析Go的标准库，非常的智能。它比标准的ctags工具生成的ctags好太多。

*   gotags:&nbsp;[https://github.com/jstemmer/gotags](https://github.com/jstemmer/gotags)

通过下面命令安装gotags

<pre name="code" class="css">go get -u github.com/jstemmer/gotags</pre>

在你的源码目录下执行下面命令声称ctags：

<pre name="code" class="plain">gotags -tag-relative=true -R=true -sort=true -f=&quot;tags&quot; -fields=+l .</pre>

这将会在你的项目根目录下生成新的tags文件，让你的代码提示更加智能。

![atom-go-tags](http://marcio.io/img/atom-go-tags.png)

## 
总结

无论你是Sublime Text爱好者还是VIM粉丝，你都应该尝试使用一下1.0版本的atom。

特别是它还是一个在Github.com上的开源项目，项目非常活跃，并且社区增长的也非常快。

快试试吧！！

            <div>
                作者：sweetvvck 发表于2015/12/29 0:37:30 [原文链接](http://blog.csdn.net/sweetvvck/article/details/50333327)
            </div>
            <div>
            阅读：237 评论：0 [查看评论](http://blog.csdn.net/sweetvvck/article/details/50333327#comments)
            </div>