---
author: riceball
date: 2013-07-14 06:05:39+00:00
title: 用 Javascript 开发桌面应用的框架工具列表
categories:
  - JavaScript
  - Framework
  - Desktop
tags:
  - desktop
  - framework
  - sdk
  - HTML5
  - javascript
  - webapp
  - 前端
---

随着近两年来nodejs的迅速走红（这个npm的功不可灭），nodejs实际上成为js服务端和工具桌面端开发事实上的标准。似乎用javascript开发桌面应用时代正在来临。各种开发桌面应用的js框架工具陈出不穷，下面主要介绍的是一些开源项目js框架工具 for Desktop Application。

<!-- more -->

# [Electron](http://electron.atom.io/)

Github开源的，用JavaScript编写桌面应用的框架。Electron为用纯JavaScript创建桌面应用提供了运行时。原理是，Electron调用你在`package.json`中定义的main文件并执行它。main文件（通常被命名为main.js）会创建一个内含渲染完的web页面的应用窗口，并添加与你操作系统的原生GUI（图形界面）交互的功能。


# [NW.js](http://nwjs.io/) (以前叫 node-webkit)

与[App.js](http://appjs.org/)类似，通过将node.js与Chromiuml联合在一起，实现本地桌面应用开发的，是App.js的后起之秀。实现原理是基于Chromium项目的Content Layer构建(Chromium Browser也同样基于Content Layer); 实现上的特点是把Node.js的消息循环(libuv)和Chromium Renderer进程的消息循环合并到一起，因为这样才能从DOM(HTML)中直接调用Node.js提供的函数；把Node.js使用的V8引擎和 Chromium的V8引擎合并，使得Node.js的Javascript和DOM里面的Javascript可以互相访问；另外因为是支持本地应用， 所以安全模型和Web程序有很大不同：node-webkit程序可以做web应用不允许做的很多事情，除了通过node.js访问本地OS以外，还可以进行跨域访问等操作。是英特尔开放源码技术中心（OTC）的软件架构师Rogerwang（王文睿）发起，在公司专职开发node-webkit(幸福啊)。

本质上它和PhoneGap一样都是属于胶水层，只不过PhoneGap是尽量以遵循W3C最新规范的形式来提供本地访问API，其它的不规范接口以各种插件形式提供；而node-webkit则是通过node.js提供本地访问的接口。与PhoneGap比较而言，如果PhoneGap要为某个平台提供新的本地API接口，必须通过开发插件的形式提供，而且各个平台的插件开发的开发语言都不一样。而node.js有node-gyp(native addon build tool) 工具统一build。而node.js的 [node-ffi](https://npmjs.org/package/node-ffi) 附加插件更使得我们可以直接在js中调用动态链接库的API：


    var ffi = require("node-ffi");

    var libm = new ffi.Library("libm", { "ceil": [ "double", [ "double" ] ] });
    libm.ceil(1.5); // 2

    // You can also access just functions in the current process by passing a null
    var current = new ffi.Library(null, { "atoi": [ "int32", [ "string" ] ] });
    current.atoi("1234"); // 1234

地址： [https://github.com/rogerwang/node-webkit](https://github.com/rogerwang/node-webkit)

如何把你的javascript 应用打包成一个可执行文件，这里已经说得很详细了：[https://github.com/rogerwang/node-webkit/wiki/How-to-package-and-distribute-your-apps](https://github.com/rogerwang/node-webkit/wiki/How-to-package-and-distribute-your-apps)


# node-x11


这个是用纯js实现了X11 Client的核心协议，包括Xrender, Damage, Composite, Big-Requests, Dpms, Screensaver, XFixes, Shape, XTest, XC-Misc, GLX and Apple-WM extensions。用来开发X-Windows GUI程序。基于 [node-x11](https://github.com/sidorares/node-x11) 有人做了进一步的封装：[ntk(desktop UI toolkit)](https://github.com/sidorares/ntk), 然后做出了一个纯js的 VNC Viewer: [node-vnc](https://github.com/sidorares/node-vnc).

Windows用户要先安装  [XMing](http://www.straightrunning.com/XmingNotes/) or [Cygwin/X](http://x.cygwin.com/)。

地址： [https://github.com/sidorares/node-x11](https://github.com/sidorares/node-x11)

X11窗口例子：

```js
    var x11 = require('../../lib');

    var PointerMotion = x11.eventMask.PointerMotion;
    x11.createClient(function(err, display) {
        var X = display.client;
        var root = display.screen[0].root;
        var white = display.screen[0].white_pixel;
        var black = display.screen[0].black_pixel;

        var wid = X.AllocID();
        X.CreateWindow(wid, root, 0, 0, 400, 300, 0, 0, 0, 0, { backgroundPixel: white, eventMask: PointerMotion });
        var gc = X.AllocID();
        X.CreateGC(gc, wid);
        X.MapWindow(wid);
    });
```

![](https://a248.e.akamai.net/camo.github.com/58410fb1ae44f04f59b79af1461d304b64b113d3/687474703a2f2f696d672d666f746b692e79616e6465782e72752f6765742f343132332f33373531313039342e33302f305f38313731325f36633265626231315f4c)
ntk 的例子:

```js
    var ntk = require('../lib');

    ntk.createClient(main);

    function main(err, app) {
      var mainwnd = app.createWindow({title: "Close me!"})
       .on('mouseout', function(ev) { console.log('Out'); })
       .on('mouseover', function(ev) { console.log('In'); })
       .on('mousedown', function(ev) {
           ev.window.unmap();
           setTimeout(function() { ev.window.map(); }, 1000);
        })
       .map();
    }
```

# node-qt


[node-qt](https://github.com/arturadib/node-qt)是基于QT的node.js封装,而[node-five](http://github.com/arturadib/node-five) 则是基于[node-qt](https://github.com/arturadib/node-qt)的封装实现了HTML5 graphics and audio。

地址：

* [https://github.com/arturadib/node-qt](https://github.com/arturadib/node-qt)
* [http://github.com/arturadib/node-five](http://github.com/arturadib/node-five)


使用 node-qt 的代码写法如下：

```js
    var qt = require('node-qt'),
        app = new qt.QApplication,
        window = new qt.QWidget;

    // Prevent objects from being GC'd
    global.app = app;
    global.window = window;

    // Quirk: the virtual method paintEvent() is mapped into a callback setter
    window.paintEvent(function() {
      var p = new qt.QPainter();
      p.begin(window);
      p.drawText(20, 30, 'hello node, hello qt');
      p.end();
    });

    window.resize(300, 150);
    window.show();

    // Join Node's event loop
    setInterval(app.processEvents, 0);
```

Node-Five的写法：

```js
    var five = require('path-to-node-five-dir'),
        window = new five.Window(300, 150),
        canvas = new five.Canvas(window),
        ctx = canvas.getContext('2d');

    ctx.fillStyle = 'black';
    ctx.fillText('hello node, hello qt', 20, 20);
```

# wxNode


[wxNode](https://github.com/joeferner/wxNode)是基于跨平台的[wxWidgets](http://www.wxwidgets.org/)的node.js封装插件包。也就是能让你用wxWidgets GUI组件开发桌面应用。

地址： [https://github.com/joeferner/wxNode](https://github.com/joeferner/wxNode)

例子：

    var wx = require("wxnode");

    var MyApp = wx.App.extend({
      onInit: function() {
        var location = new wx.Point(50, 50);
        var size = new wx.Size(450, 340);
        var frame = new MyFrame("Hello World", location, size);
        frame.show(true);
        this.setTopWindow(frame);
        return true;
      }
    });

    var MyFrame = wx.Frame.extend({
      init: function(title, pos, size) {
        this._super(null, -1, title, pos, size);

        this.EVT_CLOSE(this.onClose);
      },

      onClose: function(event) {
        process.exit();
      }
    });

    var app = new MyApp();
    app.run();

运行：

    node examples/helloWorld.js



# TideSDK


最后提下TideSDK, 就是以前的Titanium Desktop SDK，以web技术(HTML5. CSS3, JS)创建桌面应用的开源框架工具。与前面的框架相比它的特色是：它不仅仅支持用js来开发桌面应用，它还支持用C/C++, Ruby, Python, PHP来开发和写模块。而且这些语言写的模块可以彼此调用。Tide拥有一个用C++写的微内核，该微内核是支持跨平台，跨语言的绑定和调用框架。TideSDK没有加入node.js的支持是为遗憾。

地址: [http://tidesdk.org/](http://tidesdk.org/)




# 游戏应用


对于希望用js来开发游戏和动画交互强的应用，那么可能除了node-qt外，还可以考虑下下面的框架：


* [Ejecta for iOS](http://impactjs.com/ejecta): A Fast, Open Source JavaScript, Canvas & Audio Implementation for iOS
* [node-sdl](https://github.com/creationix/node-sdl): sdl的封装
* [Fast Canvas](https://github.com/phonegap/phonegap-plugin-fast-canvas)
* [node-canvas](https://github.com/learnboost/node-canvas), [node-skia](https://github.com/Shouqun/node-skia): 分别是基于[cairo](http://cairographics.org/) 和 [skia](https://code.google.com/p/skia/) 的图形库的封装。
* [node-openvg](https://github.com/luismreis/node-openvg)  : 目前似乎只支持Raspbian(RasberryPi).
* [CocoonJS](https://www.ludei.com/tech/cocoonjs)：不错的非开源


