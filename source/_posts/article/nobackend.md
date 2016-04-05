---
author: riceball
date: 2013-07-13 15:06:01+00:00
title: 无后端构建的无痛HTML应用开发[2013趋势]
categories:
  - Thinking
  - Architecture
tags:
  - Cloud
  - HTML5
  - javascript
  - nobackend
  - NoSQL
  - 云存储
  - 云计算
  - 前端
---

# 什么是无后端构建开发


无后端构建是希望通过云服务将后端从前端开发中彻底解耦。和云存储不同之处在于它不仅仅是数据存储，
它还是一套解决方案，它通过将后端任务从前端代码中剥离出来的一套SDK，让前端开发者把全部注意力放
在前端交互用户体验。而让后端开发者聚焦后端任务的解耦，统一后端数据，并使得后端更具有灵活性和
伸缩性。

这个趋势意味着互联网数据正在由人读(human-readable)时代向机读(computer-readable)过渡。虽然语义网的w3c已经提出好久(1999)，相关标准(RDF/OWL/RIF)也是许久前就制定了，但是在互联网上的实际应用中，总是雷声大，雨点小，普及率最高的RSS和FOAF(Friend Of A Friend)也只是这小众。这归结于丑陋的XML格式，虽说是机读，但是实际上描述定义这些机读格式的也是人啊，如果格式的可读性差，操作复杂，那么自然愿意使用的开发者就少。

而API则不然，这是程序开发中与外部系统交流理所当然的接口，是每个开发者都在用的，一看就懂的。当然API也有好坏之分，编写制定好的API接口比开发应用更难。这需要你具备更强的架构设计能力，从具体中提炼出通用的操作能力，以及要求可读性更强的命名能力。

自从互联网上分布式 Restful 体系架构提出后，web上的 OpenAPI 也在日益增多，但是大部分OpenAPI还是在各行其是。认证这块，虽然有统一的标准OAuth, 但是对普通开发者来说，还需要去了解OAuth的内部原理，使用上还是难用，而且各个站点对OAuth的具体实现上，又略有差异，这更增加开发者的负担。所以目前出现具体针对各大站点的OAuth认证的二次封装的开发库，降低普通开发者的使用难度。现在这些基础通用操作再次被“无后端”构建模式统一封装和组织，使得普通开发者更加容易的使用。再次降低了开发者的门槛，开发者可以完全不管后端的架构设计和组织了。那么遵循这样的普及，互联网上会有越来越多的各式各样的云服务API平台，未来的互联网架构也将从独立的web站点，变成了彼此分享协作的WebApp。

让我们具体来看一个例子。


## 例子


首先，我们从帐号管理开发谈起，在传统开发中，我们需要定义帐号的表结构，进行数据库服务器配置，
然后运行数据库服务，创建数据库和数据表，并初始化数据。那么在“无后端构建”的开发中，上述操作包
括登录，都没有必要再去做这些繁琐的操作了，你只需要再云服务后台添加一个数据库设置好访问权限，
然后在前端应用中，直接引用SDK，写代码即可，剩下的事情则交给云服务去做就好了，梦幻般的代码如下：

```js
var mydb = new iDB("https://idb.isdk.org/mydb");
var account = myDb.account;

//注册一个新用户
account.signUp('mike@example.com', 'secret', {name: "Mike John", birthday: '1988-01-01'});

//登录
account.signIn('mike@example.com', 'secret');
//使用第三方登录(Oaccount)
account.signIn(using: 'google');

//改变密码
account.changePassword('currentPassword', 'newPassword');
account.change('password', 'newPassword', {secret: 'currentPassword'});

//改变Profile的信息
account.change('nickname', 'newNickname', {secret: 'currentPassword'});

//获取profile
account.get();
account.get('name');

//彻底销毁自己的帐号
account.destroy({secret: 'currentPassword'});

//注销
account.signOut();

//忘记密码了，发送重置密码链接到指定邮箱
account.resetPassword('mike@example.com');
```

数据存储也是类似，事实上account的存储就是来自store。

```js
var store = mydb.store;
store.add(key, value);
store.update(key, value);
store.delete(key);
store.get(key);
store.listAll(key);
store.list(key, subkey_pattern, skipCount, count);
```

无后端的开发模式，实质是基于云存储之上的云服务模式。因此它不仅仅适用于HTML5应用，
其它任何计算机语言都可以用它作为开发模式的。我们通过进一步的抽象后端开发，剥离出
了帐号和存储任务，慢慢的还会有消息(通知)，在线支付/交易，评论，聊天等等各种各样的
通用的操作(任务)会以更加简易方便的形式被剥离出来。

提了这么多，那么这到底是梦幻呢，还是现在就能在互联网上可以玩到的技术呢？毋庸置疑，
这目前不仅能在互联网上玩到，而且BitTorrent, Codecademy等已经在产品中使用Firebase提供
的无后端云存储服务，下面列举一些无后端云存储服务提供者和开源项目。


# 无后端云存储服务提供者与开源项目


  *  [[Sockethub](http://sockethub.org/)]开源，数据后端为Redis, 将消息抽象出来的形成API，与应用交换.
  *  [[Hoodie](http://hood.ie/)] 开源，数据后端用CouchDB, API与设想的很接近。
  *  [[remoteStorage](http://remotestorage.io/)] 开源
  *  [[Firebase](https://www.firebase.com/)]      已经商业化
  * [[Singly](http://singly.com/)] 目前专注于针对认证、社交圈、文件分享集成以及API使用分析。
  * [[deployd](http://deployd.com/)] 开源，数据后端用MongoDB, API 难用
  *  [[Parse](https://parse.com/)] 商业化
  *  [[Kinvey](http://www.kinvey.com/)]


# 问题


优势我们大家都看到了，无论从开发的角度来说，还是说从数据复用的角度来说，这样的模式都堪称完美。当然目前从开发的角度来说还是没有完全做到前端无痛开发来着，这主要集中在权限配置上比较复杂。

那么这样的“无后端”构架的模式到底还有什么样的弊端？下面分别从用户和运营方的角度来看看，他们的顾虑会是什么？


## 用户的顾虑


用户的顾虑不仅仅是从“无后端”构架才开始，当用户的数据被放在网上，用户的担忧就开始，用户的隐私是否会被泄漏，用户的数据是否被滥用？而随着美国施洛登暴露的隐私门，更引发了全球对自己在网上的数据的担忧。那么“无后端”构架应该怎么来避免用户的顾虑呢？

首先，用户隐私数据必须加密，而加密的密钥只有用户自己才有，平台和应用开发者都没有。

其次，以前数据库在应用开发者手中，存储方法的代码也在应用开发者手中，你根本不可能知道数据是不是真的加密存放的。现在数据库在第三方平台上，那么这使得通过第三方平台直接去查看数据，或者委托他人验证，成了可能。如此一来软件再也无法对此作出虚假承诺欺骗用户。


## 运营方的顾虑


运营方可能顾虑的是我的账户数据，业务数据全在平台上了，那么这用户到底算是谁的？还有业务数据的安全怎么办？还有，如何能保证平台不利用我的业务数据？

我的回答是，不要在意用户到底算谁的，要在意的是如何为用户服好务，保证用户数据的安全，只有能满足用户的需求，让用户满意，才能留住用户，否则一切都是浮云。因此，作为运营方应该考虑的是，如果云存储服务挂掉，怎么办？
