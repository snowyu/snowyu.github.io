---
title: Interactive Markdown
date: 2019-11-23 22:22:00
updated: 2019-11-23 22:22:00
author: Riceball LEE
categories:
  - Thinking
  - Reactive
  - Document
  - Markdown
tags : [interactive, reactive, document, raphael, javascript, markdown]
reactive:
  collapsed: true
---

[Interactive Markdown](http://riceball.me/imarkdown)是使用纯文本的Markdown格式来制作响应式交互文档的工具。响应式Markdown增加了特有的交互组件和变量的标记符号。

例如: 一首童谣

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

> 我并有想好是使用新的`[]{}`表达互动元素，还是在`[]()`上扩展，从开发上看采用`[]{}`更简单，因此选用的它。

