---
title: Interactive Markdown
date: 2019-11-23 22:22:00
updated: 2019-12-07 09:35:00
author: Riceball LEE
categories:
  - Thinking
  - Reactive
  - Document
  - Markdown
tags : [interactive, reactive, document, javascript, markdown]
reactive:
  editable: true
---

# 介绍

[Interactive Markdown](http://riceball.me/imarkdown)是使用纯文本的Markdown格式来制作响应式交互文档的工具。响应式Markdown增加了特有的交互组件和变量的标记符号。

具体请参阅💁🏻‍♂️ [交互式Markdown文档参考手册](http://riceball.me/imarkdown/reference.html) .

Status: Alpha Test

<!--more-->

## 一个简单交互文档例子

一首童谣

> [我]{travelers: 我们 或 我} 要去 *圣伊芙*
> 我碰到一个有 [7 个老婆]{wives: 1..10}  的男人
> 每个老婆有 [7 个口袋]{sacks: 1..10}
> 每个口袋有 [7 只🐈️猫咪]{cats: 1..10}
> 每只🐈️猫有 [7 套🛠️工具]{kits: 1..10}
> 🛠️工具, 🐈️猫咪, 口袋, 老婆
> 问：有多少要去*圣伊芙*？

    total_sacks = @wives * @sacks
    total_cats  = total_sacks * @cats
    total_kits  = total_cats * @kits
    man         = 1

    if @travelers
        narrator = 2
    else
        narrator = 1

这常常会首先猜测是 [2753]{first_guess}…

    @first_guess = man + @wives + total_cats + total_kits + narrator

…但实际正确答案是 **[1]{answer}**.

    @answer = narrator

-----

上面的这个互动例子的Markdown代码如下：

```md
> [我]{travelers: 我们 or 我} 要去 *圣伊芙*
> 我碰到一个有 [7 个老婆]{wives: 1..10}  的男人
> 每个老婆有 [7 个口袋]{sacks: 1..10}
> 每个口袋有 [7 只🐈️猫咪]{cats: 1..10}
> 每只🐈️猫有 [7 套🛠️工具]{kits: 1..10}
> 🛠️工具, 🐈️猫咪, 口袋, 老婆
> 问：有多少要去*圣伊芙*？

    total_sacks = @wives * @sacks
    total_cats  = total_sacks * @cats
    total_kits  = total_cats * @kits
    man         = 1

    if @travelers
        narrator = 2
    else
        narrator = 1

这常常会首先猜测是 [2753]{first_guess}…

    @first_guess = man + @wives + total_cats + total_kits + narrator

…但实际正确答案是 **[1]{answer}**

    @answer = narrator
```

* `[我]{travelers: 我们 or 我}` 是一个设置指定变量真假值的单选组件，
  * `travelers` 是变量名称，可以在代码块中用 `@travelers` 来使用该变量。
  * 第一个值为真值，第二个值为假值。
* `[7 个老婆]{wives: 1..10}` 是一个滑块组件，值可以在指定范围内变化，这里是1-10之间，
  * `wives`是变量名称，可以在代码块中用 `@wives` 来使用该变量。

### 一个更复杂的交互文档例子

**参数**：[X 坐标:10]{rx:10..}，[Y 坐标:18]{ry:10..}，[宽:100]{rw:1..}，[高:50]{rh:1..}

接下来的例子演示如何使用Raphael动画库绘制一个方形，点击下方的`play`按钮开始

```output
# demo how to draw a rect.
paper = @canvas

|
~~~
tooltip: set the canvas size:200X100 ::: Init
type:paper.setSize(200,100)\n
tooltip: clear canvas
type:paper.clear()\n
tooltip: init x/y coor, width/height parameters coming from document
type:@rx ||=10\n
type:@ry ||=18\n
type:@rw ||=100\n
type:@rh ||=50\n
tooltip: drawing rect nowing ::: Draw rect
type:rect = paper.rect(@rx, @ry, @rw, @rh)\n
tooltip: fill red for the rect
type:rect.attr('fill', 'red')
moveTo: 8:13
tooltip: you can try it by youself now
```
----

## 标记

交互元素的标记符号和`markdown`的链接和图像标记符号类似:

`[text content]{variable_name: configuration}`

具体请参阅💁🏻‍♂️ [交互式Markdown文档参考手册](http://riceball.me/imarkdown/reference.html) .

## 作者

* [Alec Perkins](http://alecperkins.net)
* [Riceball LEE](https://riceball.me) https://github.com/snowyu

## Credits

Thanks to [J Voight](https://github.com/joyrexus), [Alex Cabrera](http://alexcabrera.me/), [John Debs](http://johndebs.com/), and [Supriyo Sinha](http://supriyosinha.com) for help with the notation.

The concept and controls are heavily influenced by [Bret Victor’s](http://worrydream.com) [Tangle](http://worrydream.com/Tangle) library for creating reactive documents.

## License

MIT
