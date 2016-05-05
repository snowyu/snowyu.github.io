---
author: riceball
date: 2016-04-10 12:53:56+08:00
updated: 2016-05-05 10:40:14+08:00
title: The Loopback Open API Framework
category:
  - JavaScript
  - Framework
  - API
tags:
  - nodejs
  - javascript
  - api
  - framework
  - creation
---

# Loopback Framework

尽管我不怎么欣赏它的内部实现，但是不得不说这是Open API开发框架的又一次创新，使得开发API的过程更为简单和易用。
[LoopBack][loopback] 是一个基于[Express][express]的开源 Node.js API框架，用于快速构建自己的OpenAPI平台，提供API接口给mobile, web和其他设备。它能够同时连接多种不同的数据源，非常简单的暴露model为标准的RESTful API，用nodejs 开发API，提供JS, iOS 和 Android SDKs.

[StrongLoop][strongloop]在2015年[被IBM收购了](https://developer.ibm.com/bluemix/2015/09/10/getting-started-node-js-loopback-framework-ibm-cloudant/).


## Features

* 快速创建动态 end-to-end REST APIs.
* 连接设备/浏览器到数据和服务。
* 使用 Android, iOS, and AngularJS SDKs 轻松创建客户端应用.
* 提供 push, 文件管理, 第三方登录, 以及 geolocation 的附加组件.
* 使用 `StrongLoop Arc` IDE 可视化的编辑，部署和监视 LoopBack API服务.
* StrongLoop API网关充当API消费者与API提供者之间的中介，进行外部化的安全管理API。
* 可以部署运行在内部或者云端


## [Install](https://docs.strongloop.com/display/SL/Installing+StrongLoop)

安装前提：use the latest LTS (long-term support) release of Node.js(v4.x).

```bash
npm install -g strongloop
```

## 创建 loopback 应用

```
$ slc loopback
[?] What's the name of your application? hello-world
  create hello-world/
  info change the working directory to hello-world
  I'm all done. Running npm install for you to install
  the required dependencies.
$ slc loopback:model
[?] Enter the model name: person
[?] Select the data-source to attach person to: db (memory)
[?] Select model`s base class (PersistedModel)
[?] Expose person via the REST API? Yes
[?] Custom plural form (used to build REST URL): people
[?] Common model or server only? common
Let's add some person properties now.
```

参阅官方的入门指南： [Getting Started](http://loopback.io/getting-started/).

在本地运行 `StrongLoop Arc` IDE：

```bash
PORT=4000 HOST=0.0.0.0 slc arc
```

在IDE上只需要简单的设置数据源和model，就可以将指定的数据作为Restful API提供出去了。

注意IDE要求在 Strongloop 上注册方可使用。

![](./strongloop-arc.png)

skip the online login:

`%HOME%/AppData/Roaming/npm/node_modules/strongloop/node_modules/strong-arc/clinet/www/scripts/modules/arc-user/arc-user.service.js`:

```js
    svc.getCurrentUserId = function () {
      //return $cookieStore.get('currentUserId');
      return 12;
    };
```

当你在IDE上设置添加并暴露出数据 model 后，就可以在IDE上直接运行。
你可以在这个地址: http://localhost:3000/explorer/ 上查看产生的API的联机互动文档：

![](./loopback-explorer.png)


## 内建的 models

参阅：[这里](https://github.com/strongloop/loopback/blob/master/lib/builtin-models.js)

the built-in models attach to the 'db' datasource automatically:

```js
 var dataSourceTypes = {
    DB: 'db',
    MAIL: 'mail'
  };

  registry.Email.autoAttach = dataSourceTypes.MAIL;
  registry.getModel('PersistedModel').autoAttach = dataSourceTypes.DB;
  registry.User.autoAttach = dataSourceTypes.DB;
  registry.AccessToken.autoAttach = dataSourceTypes.DB;
  registry.Role.autoAttach = dataSourceTypes.DB;
  registry.RoleMapping.autoAttach = dataSourceTypes.DB;
  registry.ACL.autoAttach = dataSourceTypes.DB;
  registry.Scope.autoAttach = dataSourceTypes.DB;
  registry.Application.autoAttach = dataSourceTypes.DB;
```


### [User](https://apidocs.strongloop.com/loopback/#user)

Default User ACLs.

* DENY EVERYONE *
* ALLOW EVERYONE create
* ALLOW OWNER deleteById
* ALLOW EVERYONE login
* ALLOW EVERYONE logout
* ALLOW OWNER findById
* ALLOW OWNER updateAttributes

### [ACL(Access Control List)](https://docs.strongloop.com/display/public/LB/Authentication%2C+authorization%2C+and+permissions)


#### 访问控制概念

* Principal: An entity that can be identified or authenticated.
  * Represents identities of a request to protected resources.
  * eg:
    * A user
    * An application
    * A role (please note a role is also a principal)
* Role: A group of principals with the same permissions.
  * eg:
    * Dynamic role:
      * $everyone (for all users)
      * $unauthenticated (unauthenticated users)
      * $owner (the principal is owner of the model instance)
    * Static role: admin (a defined role for administrators)
* RoleMapping: Assign principals to roles
  * Statically assigns principals to roles.
  * eg:
    * Assign user with id 1 to role 1
    * Assign role 'admin' to role 1


#### 常规处理步骤

* **指定用户角色**.  定义需要的用户角色。例如：匿名用户，认证用户和管理者。
* **定义每一个角色或者Model的访问权限D**.  例如：匿名用户只可以读银行列表，但是不允许其它操作.
  LoopBack 的models 有一套内置的方法，每一个方法被映射为 `READ` 或者 `WRITE` 访问权限.  In essence, this step amounts to specifying whether access is allowed for each role and each Model + access type, as illustrated in the example below.
* **实现认证**: 添加代码区创建(注册)用户，登录用户（获取并使用认证token），并注销用户。

#### 如何暴露隐藏 models, 方法 和 API

通过 REST API 暴露一个 model 非常简单，只需要设置 `/server/model-config.json` 文件的 `public` 属性为 `true` 即可:

```json
  "Role": {
    "dataSource": "db",
    "public": false
  }
```

##### 隐藏方法和REST API

如果你不想暴露特定的 create, retrieve, update, delete 操作, 那么你可以通过调用Model的 `disableRemoteMethod()` 方法来实现。
在你的model文件(`common/models/`目录下)中加入以下的代码，隐藏预定义的API方法:

```js
var isStatic = true;
//hide the predefined remote methods
MyModel.disableRemoteMethod('deleteById', isStatic);
```

如果你想隐藏的方法是在prototype上的`实例方法`,那么你需要设置 `isStatic` 为 `false`:

```js
var isStatic = false;
//hide the methods on the prototype
MyModel.disableRemoteMethod('updateAttributes', isStatic);
```

#### 定义使用Role

LoopBack 支持静态或动态的角色。静态角色保存在数据库中并映射到用户。作为对比，动态角色并不
事先和用户绑定，它是在访问时才被确定。

##### Static roles

创建静态 Role 记录:

```coffee
Role.create name: 'admin', (err, role)->
  return cb(err) if err
  # add a user to the role.
  role.principals.create principalType: RoleMapping.USER, principalId: aUser.id, (err, principal)->
    cb(err)
```

但是更普通的用法应该是：

```coffee
Role.create name: 'project.del', (err, role)->
  return cb(err) if err
  # assign admin to the project.del role.
  role.principals.create principalType: RoleMapping.ROLE, principalId: 'admin', (err, principal)->
    cb(err)
```

这样会在权限角色上挂大量的用户自定义角色，太糟糕了，所以只能通过编写动态角色来做。

##### Dynamic roles

大多数时候，静态角色的灵活性并不够，因此 Loopback提供了在运行时刻确定权限的动态角色。

并且 LoopBack 提供下列内置的动态角色：

| Role 对象属性        | 字符串值         | 说明 |
| Role.OWNER           | $owner           | Owner of the object |
| Role.AUTHENTICATED   | $authenticated   | authenticated user |
| Role.UNAUTHENTICATED | $unauthenticated | Unauthenticated user |
| Role.EVERYONE        | $everyone        | Everyone |


如何定义`动态角色`? 只需要在启动(boot)脚本中使用 `Role.registerResolver(name, fnRoleHandler)` 配置自己的
定制角色处理器即可。该函数有两个参数:

1. 该动态角色的名称
2. 角色处理器异步函数，确定一个 principal 是否在该动态角色里。该函数传入的参数为 `function(role, context, callback)`
  * role: 来自的role
  * content: 当前期望访问的内容principal.
  * callback: 返回结果回调函数。`function(error, result)`
    * error: 如果有错误则把error对象传入该参数，否则应该是`null`
    * result: *(boolean)* ，`true` 表示允许，`false` 表示拒绝。

例如：

```js
// /server/boot/script.js
module.exports = function(app) {
  var Role = app.models.Role;
  Role.registerResolver('teamMember', function(role, context, cb) {
    function reject(err) {
      if(err) {
        return cb(err);
      }
      cb(null, false);
    }
    if (context.modelName !== 'project') {
      // the target model is not project
      return reject();
    }
    var userId = context.accessToken.userId;
    if (!userId) {
      return reject(); // do not allow anonymous users
    }
    // check if userId is in team table for the given project id
    context.model.findById(context.modelId, function(err, project) {
      if(err || !project) {
        reject(err);
      }
      var Team = app.models.Team;
      Team.count({
        ownerId: project.ownerId,
        memberId: userId
      }, function(err, count) {
        if (err) {
          return reject(err);
        }
        cb(null, count > 0); // true = is a team member
      });
    });
  });
};
```

接下来就可以在model中使用该动态角色`teamMember`:

```js
// /common/models/model.json
{
  "accessType": "READ",
  "principalType": "ROLE",
  "principalId": "teamMember",
  "permission": "ALLOW",
  "property": "findById"
}
```

[loopback]:http://loopback.io
[strongloop]:https://strongloop.com
[express]:http://expressjs.com/

