---
title: Going to St.ives
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
