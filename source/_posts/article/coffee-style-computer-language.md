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

## Coffee Style Smart Computer Language

I treat the coffee-script and `Literate CoffeeScript` as the first `coffee style` smart computer language concept.
This should be the basics of the next generation Smart Computer Language.

Features:

* Space indents for block, the curly braces are optional.
* The brackets are optional for function revocation.
* The array, object(dict) assignment could be no comma, instead of using the block.
* The functional expression definition could be '->' or '=>'.
* Smart variable definition
  * It should be a compiler switcher.
  * The first variable assignment will be declared if no the same name variable before.
* RTL(run-time library) replace-able.
  * you can write your own `extends`, `for in` etc rtl functions.

Pros:

* More Natural Readable for humans
* More humane intelligence
* Functional

Cons:

* Ambiguity: The Human statement as possible ambiguity. eg,

    I saw a man on a hill with a telescope.

  * It seems like a simple statement, until you begin to unpack the many alternate meanings:
    * There’s a man on a hill, and I’m watching him with my telescope.
    * There’s a man on a hill, who I’m seeing, and he has a telescope.
    * There’s a man, and he’s on a hill that also has a telescope on it.
    * I’m on a hill, and I saw a man using a telescope.
    * There’s a man on a hill, and I’m sawing him with a telescope.
* Smart man used only(the stupid is difficult to use)
  * the man should have a mindset always. So you have got a big trouble if you can not recognize the ambiguity of some statement.
  * the smart variable definition should be care too.

Most languages could be transformed into a similar coffee style.

The previous generation computer language is very mechanical and rigid.
It's strictly limited, even missing a semicolon would raise an error.


## Language Reference

### Functions


```coffee
square = (x) -> x * x
cube   :integer = (x: integer) -> square(x) * x
fill   :string  = (container: string, liquid: string = "coffee") ->
  "Filling the #{container} with #{liquid}..."
```

The return and argument type should be optional for the types could be inferred.

The following is the C language transform:

```c
int square(int x) {return x*x;}
int cube(int x)   {return square(x)*x;}
char* fill(const char* container, const char* liquid) {
  if (!liquid) liquid = "coffee";
  const char* fmt = "Filling the %s with %s...";
  int sz = snprintf(NULL, 0, fmt, container, liquid);
  char* result = malloc(sz+1);
  snprintf(result, sz+1, fmt, container, liquid);
  return result;
}
```
