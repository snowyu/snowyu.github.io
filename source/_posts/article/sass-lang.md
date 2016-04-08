---
author: riceball
date: 2011-02-21 10:01:21+00:00
title: CSS 开发利器 ——Sass 相关工具框架介绍
categories:
  - Learning
  - Programming
tags:
  - programming
  - computer language
  - css
  - sass
  - compass
  - html
---

![sass](http://sass-lang.com/assets/img/logos/logo-b6e1ef6e.svg)

在Web开发的过程中，使用CSS的是很普遍的，虽然CSS本身并不复杂，但在大型网站中如何去有序地组织好CSS结构却是一个相当棘手的问题。为了解决开发者的这些问题，就有了Sass的出现。Sass 的全称是 (Syntactically Awesome Stylesheets)，是一种输出CSS的meta编程语言, 可以帮助开发者写出复用性更优的CSS文件。它能将类似CSS但是更简便的书写的sass语言最终转换为CSS代码。Sass提供了基于Ruby语言开发的工具能够很容易的将sass代码转换为CSS代码.

# 它的语法特性

1. 变量: Sass中以”$”号打头的$name 都是变量。我们可以给变量赋值，然后在文件中使用它们。
2. 继承:
　A. 继承其它选择器的属性：.error {border: 1px}; .badError {@extend .error};
　B. 在选择器中属性插入”&”它就会继承父选择器：a: {color:black; &:hover {color:blue}}
3. 内嵌 ：这个功能将另外一个急需的特性加入CSS：将选择器嵌入到其他等级，而不是不得不取消在一些高级选择器定义中嵌套。Sass翻译器将这个简洁的特性扩展到了CSS。
4. 混合类型 ：允许开发者抽象出性质的共同点，然后命名并且加入到选择器中。熟悉Ruby混合类型的开发者会了解混合类型在CSS中的应用。Sass也允许将混合类型作为参数，使得混合类型的应用更加灵活。
5. 操作 ：Sass支持简单的算术操作，例如+-×/，以及函数。将这个特性和变量结合起来，会使得CSS变得更加灵活。工具需要保证操作的单位（px, pt）正确性（例如字体大小等, width: 1in + 8pt，将某颜色亮度增加10%: lighten(yellow, 10%)）。

Sass语言支持的函数列表在这里：[http://sass-lang.com/docs/yardoc/Sass/Script/Functions.html]( http://sass-lang.com/docs/yardoc/Sass/Script/Functions.html)


## SCSS

2010年5月份Sass发布了支持CSS3的新语法叫做SCSS（Sassy CSS），它是CSS3的一个超集，也就是说它100%兼容CSS3，每一个有效的CSS3文件也是有效的SCSS文件。不仅如此，它还支持我们能够找到的所有扩展，甚至包括一些非标准语法，例如微软的expression()函数和filter属性。Sass修改后的语法希望能够尽量减少和CSS语法的差异，以吸引更多的用户使用。修改语法的另一个好处是可以使得CSS工具更容易支持Sass。Sass 的旧有语法将会继续存在并且能够为旧版本用户提供良好兼容性。

# SASS的安装和使用

## **一、安装：**

因为sass的工具是基于ruby gems开发的，所以安装 ruby和gem是必须的

```bash
　　$sudo gem install haml
```

在命令行使用sass：

　　$sass input.scss output.css

直接输出压缩后的css文件：

```bash
　　$sass input.scss output.css --style compressed
```

compass是基于sass的样式创作的rails框架工具，它使得你的样式表项目更容易维护. 它内部支持的css框架库是bluepoint和compass，如果在创建项目的时候不指明框架库，则是用Compass库。

```bash
　　$sudo gem install compass
```

创建css项目：

```bash
　　$compass help create
```

## **二、Sass的使用：**

创新一个新的CSS项目：

```bash
　　$compass create newProject
```

如果不喜欢它自动创建的css等目录的名称你也可以在创建的时候自己指定：

```bash
　　$compass create newProject --using blueprint/project --sass-dir sass --css-dir css --images-dir images --javascripts-dir js --output-style compressed
```

以上使用blueprint/project CSS框架来创建项目，并设置sass目录为sass，输出css目录为css,图片目录为images，javascript目录为js, 输出的css的方式为压缩.

为已有项目添加CSS模板框架

```bash
　　$compass help install
```

在已有项目中添加一个 blueprint的按钮css框架:

```bash
　　$cd newProject
　　$compass install blueprint/buttons
```

**本文作者：李雪愚。雪愚是盛大创新院高级架构师，Geeker，热爱开源事业。**

