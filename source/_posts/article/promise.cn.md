---
author: riceball
date: 2015-12-06 16:44:06+08:00
updated: 2016-03-22 12:00:14+08:00
title: 异步编程与 Promise
categories:
category:
  - Learning
  - Programming
  - Asynchronous
tags:
  - programming
  - asynchronous
  - promise
---

# Promise

Promise是简化异步编程的重要概念。这篇文章介绍得不错：[Simplifying Async with Promises](http://know.cujojs.com/tutorials/async/simplifying-async-with-promises).

简单的说，Promise（又名 Future, Delayed value, Deferred value）代表一个尚不可用的值。
因为产生这个值的计算过程尚未完成。一个 Promise 是最终的成功结果或失败原因的占位符。

* promise只有三种状态，未完成，完成(fulfilled)和失败(rejected)。
* promise的状态可以由未完成转换成完成，或者未完成转换成失败。
* promise的状态转换只发生一次
* promise有一个then方法: (`promise.then(onFulfilled, onRejected)`)
  * then方法可以接受2个回调函数作为参数。
    * 对应promise的两种状态fulfilled, rejected的回调函数。回调函数的传递参数分别是resolve(value),reject(value) 函数。

    ```js
    .then(function(resolve){
            //当promise状态变成fulfilled时，调用此函数
        },function(reject){
            //当promise状态变成rejected时，调用此函数
        });
    ```

    ```coffee
    .then ((resolve)->), ((reject)->))
    ```


Promise API 标准存在多个提案，目前看来，[Promises/A+][promisesAplus] 已经正在成为事实上的标准。

Bluebird 号称速度是所有 Promise 库里最快的 [Promises/A+][promisesAplus] 实现，里面做了许多的扩展。 想知道内部实现，可以阅读这个[yaku](https://github.com/ysmood/yaku)简单的实现（coffee-script)。


### Promise.any and Promise.some

并行的 [Promise.any][promise.any] 和 [Promise.some][promise.some]

* `some`是其中一些promise成功返回，可以指定个数。返回结果为一个数组.
* `any` 是任意一个promise成功返回，是some个数固定为1的结果，另外它的返回结果是一个单值，不是数组。

注意：它们是向**所有**的promises同时发起执行请求(并行)，但是只取最先返回结果的。不是顺序执行，
直到得到成功结果的个数，就不继续了。


```coffee
Promise = require 'bluebird'

readFile = Promise.promisify (aPath, done) ->
  console.log 'readFile', aPath
  if aPath != 'c' and aPath != 'e'  then done(new Error('no such file:'+aPath)) else done(null, aPath+'ok')

files = ['a', 'b', 'c', 'd', 'e']

Promise.any files.map (file)->readFile(file)
.then (content)-> console.log 'content=',content

```
显示结果如下:

```bash
readFile a
readFile b
readFile c
readFile d
readFile e
content= x ok
```
注：这个 `x` 表示可能是 'c'或者'e'。

### 顺序执行的 `some` 和 `any`

但是，在某些特定场合，我们并不希望并发执行读文件操作，而是有次序的执行。
那么如何做到顺序执行（sequence）？

这个时候，可以用`reduce`([promise.reduce][promise.reduce])实现：

```coffee
Promise.reduce files, (content, file)->
  content = readFile(file).caught(->) unless content
  return content
, null
.then (content)->console.log 'content=', content
```

显示结果如下:

```bash
readFile a
readFile b
readFile c
content= c ok
```

更多的细节参见我写的[promise-sequence][promise-sequence]。
a simple functional abstraction for sequentially:

下面这是map-reduce的思路用在数组的所有元素求和上,不过够绕脑袋瓜的：

```coffee
Array::sum = -> @reduce ((a,b)->a+b), 0
[1,2,3].sum()
# 6
```

这是顺序执行的coffee-script 核心代码：

```coffee
seqAny = (aList, fn)->
  _genReduceFn = (fn)->
    (previous, item)->
      previous = fn(item).catch(->) unless previous
      previous

  Promise.reduce aList, _genReduceFn(fn), null

seqAny(files, readFile).then (result)->console.log 'seqAny=', result

seqSome = (aList, total, fn)->
  _genReduceFn = (fn)->
    (previous, item)->
      previous = previous.filter Boolean
      if previous.length < total
        previous = Promise.all previous.concat [fn(item).catch(->)]
      previous
  Promise.reduce aList, _genReduceFn(fn), []

seqSome(files, 2, readFile).then (result)->console.log 'seqSome=', result

sequence = (aList, fn)-> # execution all via sequence
  # Promise.all 将执行所有的Promise,即使其中一个有错误，后面也会接着执行，如果有错误则报错。
  sequentially = (fn)->
    (previous, item)->
      Promise.all previous.concat [fn(item)]

  Promise.reduce aList, sequentially(fn), []

sequence files, (i)->readFile(i).catch(->)
.then (result)->console.log result

```

这是直接构造函数执行链的思路:

```coffee
waterfall = (tasks)->
  current = Promise.cast()
  for task in tasks
    current = current.then(task)
  current

waterfall 返回所有函数的结果作为数组:

waterfall = (tasks)->
  current = Promise.cast()
  result = []
  for task in tasks
    result.push current = current.then(task)
  Promise.all result

sequence 与waterfall不同之处在于不传递结果到下一个函数:

sequence = (tasks)->
  current = Promise.cast()
  for task in tasks
    current = current.thenReturn().then(task)
  current.thenReturn()

汇集结果到数组。

sequence = (tasks)->
  current = Promise.cast()
  result = []
  for task in tasks
    result.push current = current.thenReturn().then(task)
  Promise.all result


```


[promisesAplus]:https://promisesaplus.com/
[promise.reduce]:http://bluebirdjs.com/docs/api/promise.reduce.html
[promise.some]:http://bluebirdjs.com/docs/api/promise.some.html
[promise.any]:http://bluebirdjs.com/docs/api/promise.any.html
[promise-sequence]:https://github.com/snowyu/promise-sequence.js

