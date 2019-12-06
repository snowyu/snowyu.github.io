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

## Notation

The notation for specifying elements is similar to the regular Markdown syntax
for links and images, generally following this format:

`[text content]{variable_name: configuration}`

The text representation of the element, like the link text or image alt text,
goes between the brackets, `[]`. The brackets are followed by braces, `{}`,
which contain the variable name, and any configuration. The variable name MUST
be followed by a colon, `:`, if there is any configuration present. The
configuration is what determines the kind of element, and specifies its
behavior. For example, a *RangeElement* can be constrained to a minimum and
maximum, and a *SwitchElement* can be given different labels for `true` and
`false`.



### StringElement

A read-only output of the current value of the specified variable `<var_name>`.
The text is the default value, and used whenever the value of the variable is
`undefined`.

`[<text>]{<var_name>}`


#### StringElement Examples

##### String, basic

[many eggs]{egg_count} - `[many eggs]{egg_count}`

| property              | value                             |
|=======================|===================================|
| name                  | `egg_count`                       |
| value                 | [many eggs]{egg_count}            |



### RangeElement

A number adjustable by dragging. The number MAY have a display precision
specified. The slider MAY be constrained to a minimum and/or maximum, and MAY
have a step value. The text is parsed, and the first number in the text becomes
the output value. The remaining text is added to the template, allowing for
units and other descriptive text to be included in the control.

A range MUST be specified, but MAY be infinite in both directions. The range’s
interval is specified using the [CoffeeScript-style range
dots](http://coffeescript.org/#loops), where `..` is inclusive and `...`
excludes the end. ie, `1..4` covers the interval `1 <= n <= 4`, while `1...4`
covers `1 <= n < 4`. The range MUST be ascending (to preserve consistency in
the UI — drag left for negative, drag right for positive). The range’s step is
specified using the `by` keyword and a number. The step MAY be omitted
(defaulting to `1`), but if specified MUST be positive.

The text content MAY include a number to use as the default value. Any
surrounding text will be used as a template, allowing units or qualifiers to
be included in the element’s presentation.

Specifying a display precision MAY be done using the default number value in
the text. `200.` formats to `0` decimal places. `200.000` formats to `3`
decimals. If not specified, the value is unformatted.

Numbers MAY use the constants in [`Math`](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Math)
and combine them with a coefficient, eg `2pi` or `0.5pi`, which is treated as
`n * Math.PI`. This can be done in the range min or max, or in the step. The
constants MUST be one of `e`, `pi`, `ln2`, `ln10`, `log2e`, `log10e`, `sqrt1_2`,
`sqrt2`, (uppercase or lowercase).

`[<before> <number>.<decimal> <after>]{<var_name>: <bound>..<exclusive><bound> by <step>}`

#### RangeElement Examples

##### Specifying step

[20. calories]{calories: 10..100 by 10} - `[20. calories]{calories: 10..100 by 10}`

| property              | value                             |
|=======================|===================================|
| name                  | `calories`                        |
| value                 | []{calories}                      |
| interval              | `[10,100]`                        |
| step                  | `10`                              |
| default               | `20`                              |
| display precision     | `1`                               |
| display format        | `"#{value.toFixed(0)} calories"`  |

##### Fractional step, precision

[20.0 calories]{calories_2: 10..100 by 0.1} - `[20.0 calories]{calories_2: 10..100 by 0.1}`

| property              | value                             |
|=======================|===================================|
| name                  | `calories_2`                      |
| value                 | []{calories_2}                    |
| interval              | `[10,100]`                        |
| step                  | `0.1`                             |
| default               | `20.0`                            |
| display precision     | `0.1`                             |
| display format        | `"#{value.toFixed(1)} calories"`  |

##### With constants

[period 0.00]{period: 0..2pi by 0.25pi} - `[period 0.00]{period: 0..2pi by 0.25pi}`

| property              | value                             |
|=======================|===================================|
| name                  | `period`                          |
| value                 | []{period}                        |
| interval              | `[0,2pi]`                         |
| step                  | `0.25pi`                          |
| default               | `0`                               |
| display precision     | `0.01`                            |
| display format        | `"#{value.toFixed(2)} period"`    |

##### Unbounded

[20 calories]{calories_3: ..} - `[20 calories]{calories_3: ..}`

| property              | value                             |
|=======================|===================================|
| name                  | `calories_3`                      |
| value                 | []{calories_3}                    |
| interval              | `(−∞,∞)`                          |
| step                  | `1`                               |
| default               | `20`                              |
| display precision     | `undefined`                       |
| display format        | `"#{value} calories"`             |

##### Unbounded right, before text

[over 200 calories]{calories_4: 1..} - `[over 200 calories]{calories_4: 1.. by 2}`

| property              | value                             |
|=======================|===================================|
| name                  | `calories_4`                      |
| value                 | []{calories_4}                    |
| interval              | `[1,∞)`                           |
| step                  | `2`                               |
| default               | `200`                             |
| display precision     | `undefined`                       |
| display format        | `"over #{value} calories"`        |



### SwitchElement

A boolean flag that has a value of `true`, `false`, or `undefined`. The true
and false values can be labeled. If the label is present in the text, that value
becomes the default value. Otherwise, the value is `undefined`.

`[<before> <true_label or false_label or *> <after>]{<var_name>: <true_label> or <false_label>}`

#### SwitchElement Examples

##### Switch, basic

[pick one]{some_flag_1: true or false} - `[pick one]{some_flag_1: true or false}`

| property              | value                             |
|=======================|===================================|
| name                  | `some_flag_1`                     |
| value                 | []{some_flag_1}                   |
| default               | `undefined`                       |
| true label            | `true`                            |
| false label           | `false`                           |
| display format        | `"#{label}"`                      |

##### Switch, with default

[true]{some_flag_2: true or false} - `[true]{some_flag_3: true or false}`

| property              | value                             |
|=======================|===================================|
| name                  | `some_flag_2`                     |
| value                 | []{some_flag_2}                   |
| default               | `true`                            |
| true label            | `true`                            |
| false label           | `false`                           |
| display format        | `"#{label}"`                      |

##### Switch, default, labeled, before/after text

[on deck]{some_flag_3: on or off} - `[on deck]{some_flag_3: on or off}`

| property              | value                             |
|=======================|===================================|
| name                  | `some_flag_3`                     |
| value                 | []{some_flag_3}                   |
| default               | `true`                            |
| true label            | `on`                              |
| false label           | `off`                             |
| display format        | `"#{label} deck"`                 |

### ChartElement

An embedded chart, of type scatter, line, or bar. The chart is driven by the
specified function over the specified range. The *ChartElement* notation is
similar to the *RangeElement*, but with the addition of the `type`, and the
leading `!`. Also, the chart interval MUST be finite. Charts MUST have a
function defined in an *ActiveCodeBlock*.

`![<x_label> <delimiter> <y_label>]{<type>=<fn_name>: <bound>..<exclusive><bound> by <step>}`

#### ChartElement Examples

##### Scatter, basic

`![y vs x]{scatter=scatterFn: -10..10}`

[Offset: 0.]{scatter_offset: 0..100}

    @scatterFn = (x) =>
        return x + Math.random() * @scatter_offset

![y vs x]{scatter=scatterFn: -10..10}

| property              | value                             |
|=======================|===================================|
| name                  | `scatterFn`                       |
| type                  | `scatter`                         |
| x label               | `"x"`                             |
| y label               | `"y"`                             |
| interval              | `[-10,10]`                        |
| step                  | `1`                               |


##### Line, basic

`![sin(x)]{line=lineFn: 0..2pi by 0.001}`

[Period 1.00]{period: 0.25..4 by 0.25}

    b = 2 * Math.PI / @period
    @lineFn = (x) =>
        return Math.sin(b * x)

![sin(x)]{line=lineFn: 0..2pi by 0.001}

| property              | value                             |
|=======================|===================================|
| name                  | `lineFn`                          |
| type                  | `line`                            |
| x label               | `null`                            |
| y label               | `null`                            |
| interval              | `[0,2pi]`                         |
| step                  | `0.001`                           |


##### Bar, basic

`![money by year]{bar=barFn: 1983..2013}`

[Threshold: 5.]{threshold: 1..20}

    @barFn = (x) =>
        return x % @threshold

![money by year]{bar=barFn: 1983..2013}

| property              | value                             |
|=======================|===================================|
| name                  | `barFn`                           |
| type                  | `bar`                             |
| x label               | `"year"`                          |
| y label               | `"money"`                         |
| interval              | `[1983,2013]`                     |
| step                  | `1`                               |

## CodeBlockElement

The interactive code block also follows the Markdown specification. It can be indented by 4 spaces or three "`" symbols (without language instructions) around it. The code language is [CoffeeScript@v1](https://coffeescript.org/v1/)

````markdown

# Indented by 4 spaces

    # initilizate the my_var variable， || means only init when no default value.
    @my_var ||= 123
    # set my_func function.
    @my_func = (x) => sin(x + @my_var)

# Three "`" symbols (without language instructions) around it

```
# initilizate the my_var variable， || means only init when no default value.
@my_var ||= 123
# set my_func function.
@my_func = (x) => sin(x + @my_var)
```
````

Three "`" symbols (with language instructions) around it will dispay the code block only.

````markdown
```coffee
## This code will not be executed, just display it.
@my_var ||= 123
@my_func = (x) => sin(x + @my_var)
```
````

The Simple Code Block has not any output. You can do some logical work in it.

You should use the `output` as the language if you wanna with output on it. If you want to specify a language, you should put it in front of `playable` and separate it with a ":" sign, for example, `output:playable`.

````md
```output
# the code block with output
@sayln 'hi world'
```

```coffee/output:playable
# the code block with output and specified language(NOT IMPL YET, All are coffeescript)
@sayln 'hi world'
```
````

The CodeBlock with output has a `@output` variable(it's the binding `div` element for this block),  a `@say()` and `@sayln()` method to print text.

### Play Movie for CodeBlock

**WARNING：UNSTABLE IT WILL BE CHANGED**

The input of the code block can be played like a movie. You can enable it through three(`~~~`) or more than three tilde symbols `~` in a single line on the code block. Above the line is the common source code. The "|" above the code indicates the cursor position after the presentation is completed, and the lower part is the control input movie code.


````md

```output:playable

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
````

* `tooltip` : show a tooltip
  * `:::` Classified information after separation
* `type`: simulate keyboard input
* `moveTo`: move the cursor to x:y

### CodeBlock Examples

#### Examples: interactive code block without output

```
# this is an interactive code block without output
a = 12 + 3
```

#### Examples: interactive code block with output

```
# this is an interactive code block with output
@sayln 'hi world'
```

#### Examples: Play Movie for CodeBlock

```output:playable

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
