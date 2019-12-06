---
title: Interactive Markdown Reference Manual
date: 2019-12-06 20:02:00
updated: 2019-12-06 20:02:00
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
## 扩展标记

用于指定元素控件的符号类似于常规的Markdown语法，对于链接和图像，通常遵循以下格式：

`[文本内容]{variable_name: 可选的配置}`

`文本内容`是该元素的文本表现，例如链接文本或图像替代文本，位于方括号“[]”之间。方括号后面是花括号“{}”，花括号中包含了`变量名`和`配置`(可选)，如果存在`配置`，则变量名后必须带有一个冒号“:”。 配置是决定元素类型并指定其行为的因素。 例如， 一个范围元素(*RangeElement*)可以被限制为最小值和最大值，而开关元素(*SwitchElement*)可以为`true`和`false`设置不同的标签。

### 字符串元素(StringElement)控件

`[<text>]{<var_name>}`

显示变量`<var_name>`的当前值（只读）。`<text>`是该变量的默认值。

#### 字符串元素例子

##### String, basic

[many eggs]{egg_count} - `[many eggs]{egg_count}`

| 属性                   | 值                                |
|-----------------------|-----------------------------------|
| name                  | `egg_count`                       |
| value                 | [many eggs]{egg_count}            |

### 范围元素(RangeElement)控件

`[<before> <number>.<decimal> <after>]{<var_name>: <low_bound>..<exclusive><high_bound> by <step>}`

范围元素是可以通过拖动调整的数字，类似滑块。该数字可以指定显示精度。该元素可以被限制为最小值和/或最大值，并且可能具有步进值。
在`文本内容`中的第一个数字`<number>.<decimal>`将作为`默认数字值`，其它会原样输出，从而允许在控件中包含单位和其他描述性文本。

在`配置`中必须指定范围，但在两个方向上都可以是无限的(不写值即可)。 范围的间隔是使用'..'或'...'，其中“..”包含所有内容，而“...” 不包括结尾。 即，“1..4”覆盖区间“$$1 <= n <= 4$$”，而“1 ... 4”覆盖区间“$$1 <= n <4$$”。范围必须是递增的（以保持UI的一致性 ———— 向左拖动表示负数，向右拖动表示正数）。 使用关键字“`by`”和一个数字用以指定`步长`，该关键字可以省略（默认为1），但如果指定则必须为正。

可以使用`文本内容`中的`默认数字值`来指定显示精度。 “`200.`” 将格式化为 “`0`” 小数位。 而"`200.000`"将格式化为"`3`"小数。 如果未指定，则该值是未格式化的。

数字还可以使用在[`Math`](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Math)规范约定的常量，并可以将它们与系数组合，例如“`2pi`”或“`0.5pi`”，这将被视为“`n * Math.PI`”。 这可以写在最小、最大范围或步骤值上。常量必须是`e`，`pi`，`ln2`，`ln10`，`log2e`，`log10e`，`sqrt1_2`，`sqrt2`中的一个（大写或小写）。

#### 范围元素例子

##### 指定步长

[20. calories]{calories: 10..100 by 10} - `[20. calories]{calories: 10..100 by 10}`

| 属性                   | 值                                |
|-----------------------|-----------------------------------|
| 变量名称               | `calories`                        |
| 值                    | []{calories}                      |
| 范围                  | `[10,100]`                        |
| 步长                  | `10`                              |
| 默认值                | `20`                              |
| 显示精度              | `1`                               |
| 显示格式              | `"#{value.toFixed(0)} calories"`  |

##### 小数步长，精度

[20.0 calories]{calories_2: 10..100 by 0.1} - `[20.0 calories]{calories_2: 10..100 by 0.1}`

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `calories_2`                      |
| 值                    | []{calories_2}                    |
| 范围                  | `[10,100]`                        |
| 步长                  | `0.1`                             |
| 默认值                | `20.0`                            |
| 显示精度              | `0.1`                             |
| 显示格式              | `"#{value.toFixed(1)} calories"`  |

##### 带常量

[period 0.00]{period: 0..2pi by 0.25pi} - `[period 0.00]{period: 0..2pi by 0.25pi}`

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `period`                          |
| 值                    | []{period}                        |
| 范围                   | `[0,2pi]`                         |
| 步长                  | `0.25pi`                          |
| 默认值                 | `0`                               |
| 显示精度               | `0.01`                            |
| 显示格式               | `"#{value.toFixed(2)} period"`    |

##### 没有范围

[20 calories]{calories_3: ..} - `[20 calories]{calories_3: ..}`

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `calories_3`                      |
| 值                    | []{calories_3}                    |
| 范围                  | `(−∞,∞)`                          |
| 步长                  | `1`                               |
| 默认值                | `20`                              |
| 显示精度              | `undefined`                       |
| 显示格式              | `"#{value} calories"`             |

##### 没有最大范围

[over 200 calories]{calories_4: 1..} - `[over 200 calories]{calories_4: 1.. by 2}`

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `calories_4`                      |
| 值                    | []{calories_4}                    |
| 范围                  | `[1,∞)`                           |
| 步长                  | `2`                               |
| 默认值                | `200`                             |
| 显示精度              | `undefined`                       |
| 显示格式              | `"over #{value} calories"`        |



### 开关元素(SwitchElement)控件

`[<before> <true_label or false_label or *> <after>]{<var_name>: <true_label> or <false_label>}`

一个布尔值，其值为`true`，`false`或`undefined`。 真值和假值均可在`配置`中设定标签。 如果`文字内容`中有标签，则该值将成为默认值。 否则值为 “`undefined`”。

#### 开关元素例子

##### Switch, basic

[pick one]{some_flag_1: true or false} - `[pick one]{some_flag_1: true or false}`

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `some_flag_1`                     |
| 值                    | []{some_flag_1}                   |
| 默认值                 | `undefined`                       |
| 真值标签               | `true`                            |
| 假值标签               | `false`                           |
| 显示格式               | `"#{label}"`                      |

##### Switch, with default

[true]{some_flag_2: true or false} - `[true]{some_flag_3: true or false}`

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `some_flag_2`                     |
| 值                    | []{some_flag_2}                   |
| 默认值                 | `true`                            |
| 真值标签               | `true`                            |
| 假值标签               | `false`                           |
| 显示格式               | `"#{label}"`                      |

##### Switch, default, labeled, before/after text

[on deck]{some_flag_3: on or off} - `[on deck]{some_flag_3: on or off}`

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `some_flag_3`                     |
| 值                    | []{some_flag_3}                   |
| 默认值                 | `true`                            |
| 真值标签               | `on`                              |
| 假值标签               | `off`                             |
| 显示格式               | `"#{label} deck"`                 |

### 图表元素(ChartElement)控件

`![<x_label> <delimiter> <y_label>]{<type>=<fn_name>: <bound>..<exclusive><bound> by <step>}`

散点图，折线图或条形图的嵌入式图表。 该图表由指定函数(`fn_name`)在指定范围内驱动。 *ChartElement* 表示法与*RangeElement*类似，但是增加了`type`和前导`!`。 同样，图表间隔必须是有限的。 图表必须具有在 *代码块* 中定义的函数`fn_name`。

#### 图表元素例子

##### 散点图, basic

`![y vs x]{scatter=scatterFn: -10..10}`

[Offset: 0.]{scatter_offset: 0..100}

    @scatterFn = (x) => x + Math.random() * @scatter_offset

![y vs x]{scatter=scatterFn: -10..10}

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `scatterFn`                       |
| 类型                  | `scatter`                         |
| x 标签                | `"x"`                             |
| y 标签                 | `"y"`                             |
| x的范围                | `[-10,10]`                        |
| 步长                  | `1`                               |


##### 折线图, basic

`![sin(x)]{line=lineFn: 0..2pi by 0.001}`

[Period 1.00]{period: 0.25..4 by 0.25}

    b = 2 * Math.PI / @period
    @lineFn = (x) => Math.sin(b * x)

![sin(x)]{line=lineFn: 0..2pi by 0.001}

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `lineFn`                          |
| 类型                  | `line`                            |
| x 标签               | `null`                            |
| y 标签               | `null`                            |
| x的范围              | `[0,2pi]`                         |
| 步长                  | `0.001`                           |


##### 条形图, basic

`![money by year]{bar=barFn: 1983..2013}`

[Threshold: 5.]{threshold: 1..20}

    @barFn = (x) => x % @threshold

![money by year]{bar=barFn: 1983..2013}

| property              | value                             |
|-----------------------|-----------------------------------|
| 变量名称               | `barFn`                           |
| 类型                  | `bar`                             |
| x 标签               | `"year"`                          |
| y 标签               | `"money"`                         |
| x的范围              | `[1983,2013]`                     |
| 步长                  | `1`                               |

## 交互代码块(CodeBlockElement)元素控件

交互的代码块同样遵循Markdown规范，可以是缩进4格或者三个"```"个符号（无语言指示）围绕的内容,例如：
代码的语法是使用的[CoffeeScript@v1](https://coffeescript.org/v1/)的语法。

````markdown

# 缩进4格

    # 设置交互变量初值， ||表示当存在初始值的时候不设置。
    @my_var ||= 123
    # 设置函数
    # @my_func = (x) => sin(x + @my_var)


# 使用普通没有language的代码块


```
# 设置交互变量初值， ||表示当存在初始值的时候不设置。
@my_var ||= 123
# 设置函数
@my_func = (x) => sin(x + @my_var)
```
````

如果希望只是显示代码块内容而不是执行，请使用加了语言的代码块，如:

````markdown


```coffee
# 该代码块不会执行，不是交互代码块，只会显示
@my_var ||= 123
# 设置函数
@my_func = (x) => sin(x + @my_var)
```
````

未来可能将支持指定交互语言，使用语言加后缀"/playable"的语法,例如如果希望使用js:

````md
```js/playable
// js交互代码块
```
````

如果该代码块带输出，则在语言上使用`output`，表示默认语言带输出的代码块，如果要指定语言则应该加在playable前面，并用“:”号分隔, 如，`output:playable`。

````md
```output
# 默认语言带输出的代码块
@sayln 'hi world'
```

```coffee/output:playable
# 指定语言带输出的代码块，暂未实现，指定语言没有，全部都是coffee.
@sayln 'hi world'
```
````

带输出的代码块有`@output`变量(为该块绑定的`div`元素)，`@say()`和`@sayln()`文本输出。

### Play Movie for CodeBlock

**警告：该标记因为尚未完全确定，未来可能会有改变**

可以象电影一样播放代码块的输入。在代码块中单行启用三个`~~~`或三个以上的波浪符号`~`分隔即可。
波浪分隔符号`~~~`以上的为代码，代码上方的“|”表示演示完毕后的光标位置，下方为控制输入的电影代码.

````md

```output:playable

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
````

* `tooltip` : 显示一个冒泡提示
  * `:::` 分隔后的为分类信息
* `type`: 模拟键盘输入内容
* `moveTo`: 移动光标位置


### CodeBlock Examples

#### Example: interactive code block without output

```
# this is an interactive code block without output
a = 12 + 3
```

#### Example: interactive code block with output

```output
# this is an interactive code block with output
@sayln 'hi world'
```

#### Example: Play Movie for CodeBlock

```output:playable

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
