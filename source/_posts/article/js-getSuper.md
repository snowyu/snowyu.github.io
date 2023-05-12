---
author: riceball
date: 2023-03-24 07:25:32+08:00
title: Javascript之奇技淫巧 - 如何模拟实现 `super` 访问父类方法的功能
categories:
  - JavaScript
  - Tech
tags:
  - javascript
  - nodejs
  - tech
  - function
  - super
---

与小学三年级的ChatGPT一起学JS编程

心智为9岁的ChatGPT大约相当于我们小学3年级的学生,所以让我们与小学3年级的ChatGPT一起来深入学习编程吧.

下面是对ChatGPT的第一次提问:

你知道吗?编写一个js函数模拟实现 `super` 访问父类方法的功能有几种方法?

要求:该函数的调用方式要从语法上尽可能的接近原生`super`的调用方式,实现尽量简洁明了.
约定该函数名以及函数签名(返回值根据具体实现方式而定)为:  `getSuper(instance: Object)`
每一种方法都必须用该函数签名来实现,并具体说明,哪一种方法从语法上最接近原生`super`.

## ChatGPT的第一次回答

实现 `super` 访问父类方法的功能有以下几种方法:

1. 使用 `Object.getPrototypeOf` 和 `Object.getOwnPropertyDescriptor` 方法来获取父类的属性描述符，从而获取父类方法，并使用 `Function.prototype.call` 方法来调用该方法:

   ```javascript
   function getSuper(instance) {
     const proto = Object.getPrototypeOf(instance);
     const descriptor = Object.getOwnPropertyDescriptor(proto, arguments.callee.caller.name);
     if (descriptor) {
       const superFunc = descriptor.value;
       return function(...args) {
         return superFunc.call(instance, ...args);
       };
     }
   }
   ```

2. 使用原型链
`Object.getPrototypeOf()` 和 `Reflect.getPrototypeOf()` 都可以获取原型对象，但是 `Reflect.getPrototypeOf()` 可以在 Proxy 对象上获取正确的原型对象，因此使用 `Reflect.getPrototypeOf()` 可以增强代码的兼容性。具体实现代码如下：

    ```javascript
    function getSuper(instance) {
      const prototype = Reflect.getPrototypeOf(instance);
      return function(methodName, ...args) {
        const parentPrototype = Reflect.getPrototypeOf(prototype);
        const parentMethod = parentPrototype[methodName];
        if (typeof parentMethod === 'function') {
          return parentMethod.call(instance, ...args);
        }
      }
    }
    ```

3. 使用 ES6 的 `Proxy` 对象来代理子类实例的属性访问和方法调用。当子类实例的属性或方法不存在时，通过代理对象访问父类实例的属性或方法:

    ```javascript
    function getSuper(instance) {
      return new Proxy(instance, {
        get(target, prop) {
          if (prop in target) {
            return target[prop];
          } else if (prop in Object.getPrototypeOf(target)) {
            const superProp = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(target), prop);
            if (superProp.hasOwnProperty('value')) {
              return (...args) => superProp.value.call(target, ...args);
            } else {
              return superProp.get.call(target);
            }
          }
        }
      });
    }

    class Parent {
      constructor() {
        this.parentProperty = 'parent property';
      }
      parentMethod() {
        return 'parent method';
      }
    }

    class Child extends Parent {
      constructor() {
        super();
        this.childProperty = 'child property';
      }
      childMethod() {
        const superMethod = getSuper(this).parentMethod;
        return `child method calling parent method: ${superMethod()}`;
      }
    }

    const childInstance = new Child();
    console.log(childInstance.childMethod()); // Output: "child method calling parent method: parent method"
    ```

样例类:

```javascript
class Root {
  constructor(name) {
    this.name = name;
  }
  hi(n) {
    console.log(`hi ${n} ${this.name} from Root`);
  }
}

class A extends Root {
  hi() {
    console.log(`hi from A`)
    super.hi("here") //replace this
}

let a = new A('Mike')
a.hi('here') // print 'hi here from A' and 'hi Mike from Root'
```

## 引导提问1

你之前的回答中各个方法中都存在一点问题,思考下.

### 请说出方法一中的问题和缺陷

> 首先，该函数只能在函数内部被调用，即在子类方法中使用 `getSuper(this)(...args)` 调用父类方法。如果在函数外部调用该函数，则无法获取到正确的调用者函数名。
>
> 其次，该函数只能用于访问父类方法，而不能用于访问父类属性。如果父类属性与子类属性同名，则无法通过该函数访问父类属性。
>
> 最后，该函数使用了 `arguments.callee.caller`，这是一个非标准的特性，在严格模式下可能会被禁用。

补充:函数表达式也不存在`arguments`, 而且目前JS几乎都是在严格模式下,所以该方案基本无用.

### 那么方法二中的问题和缺陷

> 该实现方式可以实现模拟 `super` 访问父类方法的功能，但是有一些问题和限制。
>
> 首先，该实现方式使用了 `Reflect.getPrototypeOf` 方法获取实例的原型对象。这种方式可以正确地获取实例的原型对象，但在一些特殊情况下可能会出现问题，比如当实例的原型链中存在 Proxy 对象时。
>
> 其次，该实现方式只能在子类方法内部调用 `getSuper` 函数，且需要手动传入父类方法名。这样就需要手动维护父类方法名，容易出现错误。
>
> 最后，该实现方式没有考虑多层继承的情况。如果子类的父类也继承自其他类，则可能无法正确地访问到最终的父类方法。


### 那么方法三呢


> 该实现方式可以实现模拟 `super` 访问父类方法的功能，但是也有一些问题和限制。
>
> 首先，该实现方式使用了 Proxy 对象来代理实例对象，以拦截属性的访问。这种方式可能会带来性能上的损失，特别是在大规模的应用中。
>
> 其次，该实现方式只能用于访问父类属性或方法，而不能用于访问父类的私有属性或方法。
>
> 最后，该实现方式可能会存在多层继承的情况。如果子类的父类也继承自其他类，则可能无法正确地访问到最终的父类方法。

补充: 当子类重载了该方法,那么该实现无法访问到父类方法,需要修改,总体来说ChatGPT想得过于复杂

### 最后,什么是多层继承的情况

多层继承是指一个子类从另一个子类继承，而这个子类又从其它父类继承。举例说明:

```javascript
class A {
  m() {console.log('A')}
}
class B extends A {
  m() {console.log('B'); getSuper(this).m()}
}
class C extends B {
  m() {console.log('C'); getSuper(this).m()}
}
```

显然,在深入JS中,ChatGPT的智商明显不够用了,原因在于JS的本质是函数式编程,面向对象的类概念是通过原型链模拟出来的,而原型链本身如果理解不清与面向对象的概念搅在一块,那么就会非常容易混淆.

## 引导提问2

要准确回答这个问题,首先,我们要先猜测分析原生`super`是怎样访问父类方法的,实现了怎样的功能?
你可以通过构造不同的例子来测试它的功能极限.再根据它的功能来开发函数模拟实现 `super`.

## 总结

显然,在深入JS中,ChatGPT的智商明显不够用了,原因在于JS的本质是函数式编程,面向对象的类概念是通过原型链模拟出来的,而原型链本身如果理解不清与面向对象的概念搅在一块,那么就会非常容易混淆.抛开已被废弃掉的非严格模式下的`arguments.callee.caller`方案,它的可用的两个方案都没能实现对多层继承的支持(在多层继承中会引发无限循环).

从本质上来说获得父类方法都必须通过原型链(`Object.getPrototypeOf`/`Reflect.getPrototypeOf`)获得;而从具体形式来看,大概有以下几种实现办法:

1. 以高阶函数方式实现
2. 以对象方式实现
3. 以代理方式实现

因为代理方案能够以简单的方式实现多层继承以及支持动态继承特性,所以最后选择了代理方案.

### 以高阶函数方式实现

这种实现方式与原生`getSuper`关键字调用方式不太一样.

```javascript
// getSuper(this)('hi', n)
function getSuper(instance) {
  const proto = Object.getPrototypeOf(instance);
  const parentProto = Object.getPrototypeOf(proto);
  // 这里稍微变化即可实现其它调用形式,如: `getSuper(this)("hi")(n)`
  return function(methodName, ...args) {
    const parentMethod = parentProto[methodName]
    if (typeof parentMethod === 'function') {
      return parentMethod.call(instance, ...args);
    }
  };
}

class Root {
  hi(n) {console.log('hi from Root')}
}
class A extends Root {
  hi(n) {
    console.log('hi from A')
    getSuper(this)('hi', n)
    getSuper(this)("hi")(n) //or this
    getSuper(this, 'hi')(n) //or this
  }
}
```

注意:

* 在多层继承的场景下会出错,引发无限循环

### 以对象方式实现

比较接近原生`getSuper`关键字调用方式.

```javascript
function getSuper(instance) {
  const proto = Object.getPrototypeOf(instance);
  const parentProto = Object.getPrototypeOf(proto);
  return Object.getOwnPropertyNames(parentProto)
    .filter(n => typeof parentProto[n] === 'function')
    .map( n => parentProto[n].bind(instance);
}

class A extends Root {
  hi(n) {
    console.log('hi from A')
    getSuper(this).hi(n)
  }
}
```

注意:

* 在多层继承的场景下会出错,引发无限循环
* 该实现无法用于动态继承的场景.

### 以代理方式实现

比较接近原生`getSuper`关键字调用方式. 并且能支持多层继承以及可以用于动态继承的场景.因此这也是最终选择的方案.

不妨想想这里是如何通过`getPrototypeOf()`来支持多层继承的?

完整的实际实现请自行阅读: [inherits-ex 动态继承库](https://github.com/snowyu/inherits-ex.js)中的相关代码: https://github.com/snowyu/inherits-ex.js/blob/v2/src/getSuper.js

```javascript
function getSuper(instance) {
    const proto = Object.getPrototypeOf(Object.getPrototypeOf(instance));
    const proxy = new Proxy(instance, {
      get(_, prop) {return proto[prop]},
      getPrototypeOf() {return proto},
    });
    return proxy;
}
class A extends Root {
  hi(n) {
    console.log('hi from A')
    getSuper(this).hi(n)
  }
}
```

