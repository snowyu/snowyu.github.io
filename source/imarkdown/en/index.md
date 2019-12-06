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
  editable: true
---

## Introduction

[Interactive Markdown](http://riceball.me/imarkdown/en) is a tool for making reactive/interactive documents — using a plain text markdown source, with a special notation for adding interactive controls and variables. The logic is determined by the content of the code blocks, which is actually executed on-the-fly to update the variables.

An Example Interactive document looks like this:

### St.Ives Example

An old riddle.

> As [I]{travelers: we or I} [was]{verb} going to *St Ives*
> I met a man with [7 wives]{wives: 1..10}
> Every wife had [7 sacks]{sacks: 1..10}
> Every sack had [7 cats]{cats: 1..10}
> Every cat had [7 kits]{kits: 1..10}
> Kits, cats, sacks, wives
> How many were going to St Ives?

    total_sacks = @wives * @sacks
    total_cats  = total_sacks * @cats
    total_kits  = total_cats * @kits
    man         = 1

    if @travelers
        narrator = 2
        @verb = 'were'
    else
        narrator = 1
        @verb = 'was'

The first guess is often [2753]{first_guess}…

    @first_guess = man + @wives + total_cats + total_kits + narrator

…but the correct answer is **[1]{answer}**.

    @answer = narrator

-----

The sample raw Interactive Markdown file is:


```md
An old riddle.

> As [I]{travelers: we or I} [was]{verb} going to *St Ives*
> I met a man with [7 wives]{wives: 1..10}
> Every wife had [7 sacks]{sacks: 1..10}
> Every sack had [7 cats]{cats: 1..10}
> Every cat had [7 kits]{kits: 1..10}
> Kits, cats, sacks, wives
> How many were going to St Ives?

    total_sacks = @wives * @sacks
    total_cats  = total_sacks * @cats
    total_kits  = total_cats * @kits
    man         = 1

    if @travelers
        narrator = 2
        @verb = 'were'
    else
        narrator = 1
        @verb = 'was'

The first guess is often [2753]{first_guess}…

    @first_guess = man + @wives + total_cats + total_kits + narrator

…but the correct answer is **[1]{answer}**.

    @answer = narrator
```

* `[I]{travelers: We or I}` is a toggle switch between `We` or `I`
  * `travelers` is a variable name, It can be referenced `@travelers` in the code block.
  * the first value is `true`, the second is `false`.
* `[7]{wives: 1..10}` is a slider from `1` to `10`, defaults to `7`
  * `wives` is a variable name, It can be referenced `@wives` in the code block.

> I am thinking about whether to use the new `[]{}` to express interactive elements, or to expand on `[]()`. From the development point of view, it is simpler to use`[]{}`, so I chose it.

### A More Complex Example

**Parameters**：[X Coor:10]{rx:10..}，[Y Coor:18]{ry:10..}，[Width:100]{rw:1..}，[Height:50]{rh:1..}

Following will show howto draw a rect with Raphael animation library, Click the `play` button to begin:

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

## Notation

The notation for specifying elements is similar to the regular Markdown syntax
for links and images, generally following this format:

`[text content]{variable_name: configuration}`

More detail see 💁🏻‍♂️ [reference.html](http://riceball.me/imarkdown/en/reference.html) for a
complete reference of the elements and their configuration.

## Authors

* [Alec Perkins](http://alecperkins.net)
* [Riceball LEE](https://riceball.me) https://github.com/snowyu

## Credits

Thanks to [J Voight](https://github.com/joyrexus), [Alex Cabrera](http://alexcabrera.me/), [John Debs](http://johndebs.com/), and [Supriyo Sinha](http://supriyosinha.com) for help with the notation.

The concept and controls are heavily influenced by [Bret Victor’s](http://worrydream.com) [Tangle](http://worrydream.com/Tangle) library for creating reactive documents.

## License

MIT
