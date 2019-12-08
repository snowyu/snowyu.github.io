---
title: 基于Markdown的响应(交互)式文档
date: 2019-11-23 22:22:00
updated: 2019-12-08 09:31:00
author: Riceball LEE
categories:
  - Thinking
  - Reactive
  - Document
  - Markdown
tags : [interactive, reactive, document, raphael, javascript, markdown]
reactive:
  editable: true
---

## 什么是响应(交互)式文档

什么是响应(交互)式文档，简单的说就是文档内容能够实时响应读者的交互，根据交互实时变化的文档。在技术，教育领域中，为了将知识表述更清楚，常常需要✍文档能“动”起来，最极端的例子应该是🎮️“游戏”。虽然目前还不能让🎮️游戏文档直接“动”起来。不过未来就不一定了。

我们接下来通过一个简单的响应(交互)式文档例子，来直观感受一下，请看下面。

<!--more-->

### 绘制矩形(Rect)例子

**参数**：[x轴坐标:10]{rx:10..}，[y轴坐标:18]{ry:10..}，[宽度:100]{rw:1..}，[高度:50]{rh:1..}

下面演示在提供好的画布上用上述参数绘制一个矩形，点击下方的播放按钮进行演示：

```output
# 演示绘制矩形的过程
paper = @canvas

|
~~~
tooltip: 设置画布大小为200X100 ::: 初始化工作
type:paper.setSize(200,100)\n
tooltip: 清空画布
type:paper.clear()\n
tooltip: 初始化来自文档的x,y座标，宽度和高度参数变量
type:@rx ||=10\n
type:@ry ||=18\n
type:@rw ||=100\n
type:@rh ||=50\n
tooltip: 开始绘制矩形 ::: 绘制矩形
type:rect = paper.rect(@rx, @ry, @rw, @rh)\n
tooltip: 为矩形填充红色
type:rect.attr('fill', 'red')
moveTo: 8:13
tooltip: 现在你可以自己试一试了
```
----

看完演示，你可以通过将鼠标移到上方参数列表中的x,y或宽,高参数上进行拖动来直观的改变参数值，
也可以直接在上面的代码中编辑修改，自己动手试一试其他的绘图函数,比如: 圆，椭圆, 文字，图片等等。

* `circle(x, y, r)`
* `ellipse(x, y, xr, yr)`
* `image(src, x, y, width, height)`
* `text(50, 50, "Hi world\n你好世界")`


响应(交互)式文档能够更加直观的看到结果的变化，使得知识更容易理解。


## 为什么响应(交互)式文档要基于Markdown格式？

Markdown 是一种纯文本格式的轻量级标记语言，强调可读性高于一切。

* 纯文本，所以兼容性极强，速度快，易保存，数据不易丢失，可以用所有文本编辑器编辑。
* 可以专注写作而不是排版。用Word写作的时候，经常浪费大量时间去思考排版，
* Markdown 语法简单，只有少量的标记符号，可以很快学会。
* Markdown 的标记语法有极好的可读性。

使用Markdown格式可以随时随地的编写互动文档，让更多的人都能够参与进来。目前的开源编写互动文档的门槛还是比较高，如果不懂相关技术，是很难入门。

* [Jupyter Notebook](https://jupyter.org/)文档是基于 JSON 格式，主要面向开发者的。
  * 目的是可读性更高的，可直接执行的代码文档。
* [R Markdown](https://rmarkdown.rstudio.com/) 文档是基于 markdown 格式，但也是面向R语言开发者的。
  * 目的是让Markdown的代码块可以被直接执行，输出结果混合渲染成Html。

而交互式Markdown格式的目的是要让普通人也能快速上手使用。

比如，对函数图像进行教学演示的交互式markdown，只需要

1. 定义函数: `@func = (x) => Math.cos(x + @offset)`
2. 设定需要演示改变的参数: `[Offset: 0.00]{offset: -2pi..2pi by 0.0625pi}`
3. 在指定的位置显示函数图像：`![Chart]{line=func: 0..2pi by 0.001, width=600, height=300}`

绘制余弦曲线图：

    @func = (x) => Math.cos(x + @offset)

函数参数:

* [Offset: 0.00]{offset: -2pi..2pi by 0.0625pi}

![Chart]{line=func: 0..2pi by 0.001, width=600, height=300}

读者就可以将鼠标移到上方Offset参数上进行拖动来改变参数值从而改变函数图像，也可以直接将函数`cos`改为`sin`看看。


[Interactive Markdown](/imarkdown) 目前还在内部测试中，语义规范尚未固定。不过，我写了一个
玩具可以让您自己的博客使用互动文档，用的是[Hexo博客生成工具](https://hexo.io/)➕️[Theme-Next主题](https://theme-next.org/)，通过[hexo-next-imarkdown](https://github.com/snowyu/hexo-next-imarkdown)插件即可让您的博客支持互动Markdown文档格式，欢迎尝鲜。

更详尽的[Interactive Markdown](/imarkdown)语法请参阅💁🏻‍♂️ [交互式Markdown文档参考手册](http://riceball.me/imarkdown/reference.html) .

## 未来

我希望在不久的将来使用[Interactive Markdown](/imarkdown) 来编写绘本故事书，[根据文字自动产生图画](https://medium.com/ai-club-iiitb/text-to-image-synthesis-62eb44e65cd0)故事。

在更远的未来甚至可以开发游戏。
