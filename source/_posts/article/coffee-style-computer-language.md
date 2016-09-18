---
author: riceball
date: 2016-08-31 06:30:06+08:00
updated: 2016-09-04 11:30:06+08:00
title: Coffee Style Computer Language
category:
  - Thinking
  - Programming
tags:
  - thinking
  - programming
  - language
  - tech
---

## Coffee Style Computer Language

I treat the coffee-script as the first coffee style computer language.

Features:

* space indents for block, the curly braces are optional.
* the brackets are optional for function revocation.
* the array, object(dict) assignment could be no comma, instead of using the block.
* the functional expression definition could be '->' or '=>'.
* Smart variable definition
  * It should be a switch.
  * The first variable assignment will be declared if no the same name variable before.

Pros:

* More Natural Readable for humans
* More Smart
* Functional

Cons:

* Ambiguity: 和人类句子一样，可能歧义。 The Human statement as possible ambiguity.

    I saw a man on a hill with a telescope.

  * It seems like a simple statement, until you begin to unpack the many alternate meanings:
    * There’s a man on a hill, and I’m watching him with my telescope.
    * There’s a man on a hill, who I’m seeing, and he has a telescope.
    * There’s a man, and he’s on a hill that also has a telescope on it.
    * I’m on a hill, and I saw a man using a telescope.
    * There’s a man on a hill, and I’m sawing him with a telescope.
* Smart man used only(Not For Stupid man)
  * the man should have a mindset always. So you have got a big trouble if you can not recognize the ambiguity of some statement.
  * the Smart variable definition should be care too.
Most languages could be transformed into a similar coffee style.

