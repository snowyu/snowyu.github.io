---
author: riceball
date: 2011-03-05 08:01:29+00:00
title: Phonegap：快速开发跨平台HTML5应用的胶水层
categories:
  - HTML5
tags:
  - HTML5
  - 移动开发
  - phonegap
  - cordova
  - hybrid
  - mobile
  - application
---

在开发移动应用的过程当中，如果你的应用只定位在一种平台上，这可不是一个好主意，但是为许多不同的平台Building应用又是一件非常麻烦和非常不爽的事情，因为你会发现每一种手机平台都有自己的SDK，它们需要使用不同语言来进行开发，你可能不得不需要5、6个代码仓库来管理不同设备上的代码，而且需要不同设备的开发人员来开发维护这些仓库，你还不得不装上各个设备的sdk，设置好路径和各种配置信息，来编译不同设备上的应用包。
那么移动网站模式是不是一个可以接受的替代方案呢？幸运的是移动应用和移动网站并不是对立的两端，通过Phonegap我们可以采用html5的网站形式来开发移动应用。也许开源Phonegap 会成为 WebApp 上设备端开发的事实上标准，ShowMuch本期就为你推荐移动开发利器：PhoneGap。
我们先来看看PhoneGap的特性：



* 支持6种移动设备平台：iOS, Android, BlackBerry, WebOS, Symbian WRT, Windows Mobile(内部测试)，以及桌面环境（内部测试）
* HTML5 + CSS3 + JavaScript  利用标准的Web技术开发应用
* [Phonegap Build](https://build.phonegap.com/): write once, compile on cloud, run anywhere. 提供在线Builder平台：只写一次，云端编译，运行在任何地方
* 目前已经有上千基于[Phonegap的应用](http://www.phonegap.com/apps)在AppStore上

## 开始玩![](data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBggGBQkIBwgKCQkKDRYODQwMDRoTFBAWHxwhIB8cHh4jJzIqIyUvJR4eKzssLzM1ODg4ISo9QTw2QTI3ODUBCQoKDQsNGQ4OGTUkHiQ1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU0NTU1NTU1NSk1NTUtNf/AABEIACAAIAMBIgACEQEDEQH/xAAXAAEBAQEAAAAAAAAAAAAAAAAGBwUD/8QALRAAAgIABQMBBgcAAAAAAAAAAQIDBAAFERIhBiIxB0FRYZKhwRMUQkNxgZH/xAAWAQEBAQAAAAAAAAAAAAAAAAADBAH/xAAdEQACAgMBAQEAAAAAAAAAAAABAgADERIhQfAE/9oADAMBAAIRAxEAPwC44N9a5maVWCAlkin3GVlPJUaDb/ZYf5p4OEmBXqM6LNlKv4eRh9UH3wlS7uFEO1tULTV6YzCpds2Vo7tkccYkXaQA/dz/ACRp8owgwe6Kiljyu20qbFe5IYju13KAF1+HKkafDCHGOMMRNrOyAzjbtwUasli1IsUMY1Zm9mCfVFiXN46jQUysMU4b8wy7pF5P7eh7GGh11B400GMj1ezWzlk+VNar2TkQEj2Z68ZcRS6oqF+O0dzAd3JY8doxhVOv8qlKMud1Gj/V+Ixjbx7mAw9dQKbhujyR3fp0tFTISp9xzsoOX5y+W1gk1JzTWRgJ49d3LaljGQCF5Pgk8eMI0dZY1eNg6MNVZTqCPeMRqz6hZUJBXr5ibc0zBIoKqtK7seAFCjyT4w79OY84TJLDZtUko13sF6NaZVEqRMoYl9p4JcsdpG5Trr7ABYDGc9lKkqwUDmPhP//Z)


首先自然是需要下载 phonegap： [http://www.phonegap.com/](http://www.phonegap.com/)

然后你还需要相应设备的SDK

### **针对iPhone:**


1. 从 [Apple Developer Portal](http://developer.apple.com/) 下载安装 XCode.
2. 解开下载好的phonegap压缩包，进入iphone目录安装好phonegap
3. 打开XCode，在文件菜单选择 New Project.... 菜单
4. 点开“User Templates”栏，选择Phonegap，然后选中右边的“**PhoneGap-based Application**”，点击“Choose...”按钮，命名你的项目，选择项目文件的位置.

### **针对Android:**

1. ![](data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBhIPDxUTEBIWEBASFBIRFBgVFBMdGRQbHxUcFhgXFxIYJyYeIyUoGhgeHzsgIzMpMTAtFx4xNTwqNScrLCkBCQoKDQsNGQ4OGTUkHiQ1NTU1NDQ1NTU2LjU1NSw1NSw1NDUyNDU1NDY1LjQ1NSw1NDQsNTYpNDQtLDUpLC81LP/AABEIAE8ATwMBIgACEQEDEQH/xAAbAAABBQEBAAAAAAAAAAAAAAAAAQMEBQYCB//EADgQAAIBAwIDBQQJAwUAAAAAAAECAwAEEQUhEhMxBiJRYXEyQYGRFEJSobGys+HwJENyFiM0NYL/xAAZAQADAQEBAAAAAAAAAAAAAAAAAgMEAQX/xAAoEQACAgEDAQcFAAAAAAAAAAAAAQIRAxIhMRMEQWFxgbHBFFGRofD/2gAMAwEAAhEDEQA/APcKKKKACiikJoAWq++v+XJCvXmuyH0EbNn5qB8aNX1qK1jLytgdAB7THwUVQ2NyTKLu8PKyClvFuWUHqeEblj5DpU5Tp6VyXx4m1rfHua0UtM2s3GMlSmfc2M/EDp6U9VEQ4CiiigAooooAK5alJqLdanFEQJHVWPRSe83og3PwoOMyul230m/uZrjvG2bgiQ9F6kEDzAB9T5Cu+xEi3LS3Ep4rjjK4P9tMbBR7h1G3XG9XMtjiYXEPtMAsq4xzFzscH6w92eoyPCqnTNEMOpyPDtCUy/hxsc8A/N5ZHjWXQ4td56nVhkhNN1sq9OV6mtWuqhXmpJAvE/FwgEkqjNgDqTwg09Z3iTIHjYOjDKspyDWqjy7H6KKKDoUUUUAIax+v6Nb2jNdBrmOSRwrmFifaO5biDYUfGtTfX8cKF5XWNB1LEAfzyqHJePNC/wBHBRyp5byxkLk9O6cN91NFtOxJU9jNJrNoR/3EnoWhH4pmkTV7EsB9NubgkgYV5yPjyVXanDdaimA+nQTsBjiWSPfzw3zqZpl3qLSDjtILeLPe/wB3vY8RwZ+RrQ0qv5RJXx8Fld3y26BIUaSQgcuNMkt5sx9keLNXPZHR2tLVY3ILlnkfHsgseIqvkOlWk0yxqWchVAySfdjxNdxyBhkbg7j8azXtRat7OxRRRXBgoNFIaAIGr6PDdoEnQSKDxDORg+II3Bqok7Kcof081wgH1RdNgegkDipXbOZksZWRirDgwVJBHfUbEU3DrZighHJmndoY3JRcj2RklycZ8qXraHpfBX6dzgpryIZ0y7H927PpNZ/iUrltMuz1N03+V3Av6aZqZ/rOLkNNwSYjdY5FKjijJ+0M4qdqGupBysgtz2VE4QPfjBPlvTLOubQr7LNOmv5FRD2enLZIiQ/akee4cenMKrn51pLO2MaYLtIdyWcjJPwwB6Daqe97ViIvm3nZIyQziPujB3IJOSKs7DUBOgdAeBgGVtu8P2rnUU3QPDOEdTWxNFFIKWuiBSGlpDQBn+3H/Al/8fqLVOmsuZIbfni0jFrDIXIQlzwDYF9h+xq87TaTJdqsSuEhLZl2PEQOgX3fwVOk0iF1QPEjiMBV4lBwBsMVnlCTna8DdjzY4YlGSvd/BjtBtBcpfxh+bxsArnHf7pKtgbdd/CmuzM7Xk9srbizjYvn7WeFPuwfhW9itETJRQpbGcADOBtnHlXMFlHGSURULHJIAGfUilWBqt/P3Hl23Up7c8eG1P9GIn1trmK4aS6FuEMkSwgJlsDYMzZbJ6bVpOxQ/oIf8T+c1PbSYTJx8pOYfrcC5+dSbeFUXhQBVHQAYA+FPDG1LU2SzdohLH04qt0+77fkdFFAoq5jP/9k=)下载安装 JDK 1.5
2. 下载安装 [Android SDK](http://developer.android.com/sdk/index.html)
3. 下载安装 [Apache ANT](http://ant.apache.org/ivy/download.cgi)
4. 下载安装 Ruby (命令行方式开发需要)
5. 解压已经下载好的 PhoneGap, 进入android 目录，my god，最新的0.9.4ZIP包中没有命令行创建项目的方式，好吧，你需要从最新的仓库中把代码取出来： git clone https://github.com/phonegap/phonegap-android.git
6. 命令行方式(Droidgap)脚本的开发者没有修改路径以配合新的0.9.4版本，这是这次在发布中被拿掉的原因吧。需要自己改改，蛮简单的，就不多说。
7. 将 android下的bin目录 加入你的搜索 path:
UNIX/LINUX的机子: export PATH=$PATH:~/phonegap-android/bin
在windows下将phonegap-android/bin 路径加到Path中就不用多说了。
8. ok，在命令行下输入 "droidgap gen demo",即可创建phonegap支撑的html5应用项目。
9. cd demo;ant debug install 即可安装到设备或模拟器
10. adb logcat 在控制台查看设备的输出日志


### **使用PhoneGap来创建移动App应用：**

打开项目的www目录（android是在项目的assets/www目录下），编辑index.html，在body中键入<h1>hello world</h1>（你也可以加上js和css文件在这个目录下面），保存，然后你就可以首先部署到模拟器上看看。

也许你会说，哈，这不就是网页嘛！是的，这就是网页，不过通过phonegap，这样的网页应用就有能力访问设备的所有功能：文件系统，GPS，相机，重力加速度计，电话簿等，当然不同的设备支持的功能会有所不同（目前phonegap还不能支持完所有的功能，具体看各个设备支持的特性列表）。另外要想呈现和移动应用一样的外观，你还需要选择一种HTML5 Mobile UI Framework库，这样的Framework库已经很多了: Sencha Touch, JQTouch, JMobile, XUI, The-M-Project,Dojo Mobile, dhtmlxTouch, wink, jo, webapp.net...


## [Phonegap Build](https://build.phonegap.com/)


除了在本地编译应用之外，您还可以使用Phonegap提供的云端Build工具进行应用编译。那就是：Phonegap Build，通过它，您只需要将用HTML5写好的应用上传到Phonegap的云端服务器，它即可以帮你编译不同平台平的应用。

![](https://build.phonegap.com/images/marketing/build-diagram.png)

[Phonegap Build](https://build.phonegap.com/) 当前[Phonegap Build](https://build.phonegap.com/)依然处于beta状态，你需要申请，等到通过方可使用。另外推荐一个Chrome的插件，[Ripple Emulator](http://ripple.tinyhippos.com/) 可以在Chrome浏览器上测试你的应用，支持phonegap。

（文章作者：李雪愚，盛大创新院高级架构师，雪愚对于使用Phonegap有着丰富的经验，曾用Phonegap开发基于Android和iOS的应用。编辑BY：Handaoliang）
