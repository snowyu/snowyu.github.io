---
title: Raphael 矢量图形和动画javascript库
date: 2019-11-22 15:53:00
updated: 2019-11-26 13:00:00
draft: true
categories:
  - Library
  - Graphic
tags : [graphic, animation, vector, raphael, javascript, tut]
reactive:
  editable: true
---

raphael 是一套创建的矢量图形和动画的javascript库，它使用SVG W3C推荐标准和VML作为创建图形的基础。

# 创建图形对象

raphael支持圆形，矩形，椭圆矢量图形对象的直接创建，下面以最简单的矩形绘制进行讲解。

## 矩形(Rect)

参数：[x轴坐标:10]{rx:10..}，[y轴坐标:18]{ry:10..}，[宽度:100]{rw:1..}，[高度:50]{rh:1..}


下面演示在提供好的画布上用上述参数绘制一个矩形，点击下面的播放按钮进行演示：

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
--------
看完演示，你可以这上面的代码中自己动手试一试了,比如: 圆，椭圆, 文字，图片等等。

* circle(x, y, r)
* ellipse(x, y, xr, yr)
* image(src, x, y, width, height)
* text(50, 50, "Hi world\n你好世界")

所有这些绘制后都会返回一个图形对象，你可以对它进行各种操作，比如show/hide,改变属性attr。

## Path(路径)

更复杂的对象也可以通过path来实现描述。路径是矢量绘图里最强大的工具，同时也比较复杂。

```output
paper = @canvas
paper.setSize(200,100)
paper.clear()
paper.path('M100,0 L200,100 L10,100 Z').attr({'fill': 'blue', 'stroke': 'black'})
```

路径的参数是一组字符串，由“命令字母+坐标数字”的组合构成。数字表示坐标点，字母负责表示如何连接这些坐标点。
比如x的示例中，M表示起点，L表示直线连接，所以上述的path的信息可以这样解读：

* M100,0      ->    以（100，0）坐标点为起点
* L200,100    ->    从（100，0）向（200，100）画一条直线
* L10,100     ->    从（200，100）向（10，100）画一条直线
* Z           ->    闭合路径,将路径的开始和结束点用直线连接


在path中，一共有10个命令可以使用，下面5个命令是基础，比较简单。

* M: moveTo(x,y)   移动到 x,y 坐标
* Z:closepath()    闭合路径, 将路径的开始和结束点用直线连接
* L:lineTo(x,y)    直线    当前节点到指定(x,y)节点，直线连接
* H: Horz(x)       水平直线 保持当前点的y坐标不变，x轴移动到x，形成水平线
* V: Vert(y)       垂直直线 保持当前点的x坐标不变，y轴移动到y，形成垂直线

## 动画

在raphael中绘制的每一个元素都可以轻易的制作动画，只要我们设定它的起始和结束属性即可。
假如我们对前面的矩形进行动画，设定它的结束属性为：

* [x轴坐标:100]{rex:0..}，[y轴坐标:40]{rey:0..}
* [宽度:100]{rew:1..}，[高度:100]{reh:1..}
* 填充颜色为黄色
* 旋转120度
* 透明度设为 0.3

然后设定当对矩形点击的时候开始动画。


```output
paper = @canvas
paper.setSize(300,160)
paper.clear()
@rx ||=0
@ry ||=0
@rw ||=100
@rh ||=50
# 获取结束时候的矩形参数
@rex ||=100
@rey ||=40
@rew ||=100
@reh ||=100

rect = paper.rect(@rx, @ry, @rw, @rh).attr({'fill': 'red', 'opacity': 1})

elAttrs = []
elAttrs.push(_.clone(rect.attr()))

elAttrs.push(
    {
      x: @rex, y: @rey, transform: "r120"
      width: @rew, height: @reh
      fill: 'yellow'
      opacity: .3
    }
)

reverse = 0
rect.mousedown(  () ->
    rect.stop().animate(elAttrs[+(reverse = !reverse)], 1000)
)

```

现在你可以在矩形上点击看看动画效果。

