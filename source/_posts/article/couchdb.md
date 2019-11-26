---
author: riceball
date: 2018-10-10 13:30:59+08:00
updated: 2019-11-26 11:30:00+08:00
title: CouchDB
categories:
  - Database
  - NoSQL
  - CouchDB
tags:
  - nosql
  - couchdb
  - database
---

CouchDB 是一个面向文档的`NoSQL`数据库。CouchDB还可以把整个H5网站直接放到数据库中，这称为`CouchApp`，详见后述。

<!--more-->

## Source Build

```bash
sudo apt-get --no-install-recommends -y install \
    build-essential pkg-config erlang erlang-reltool \
    libicu-dev libcurl4-openssl-dev
sudo apt-get install devscripts libnspr4-dev pkg-kde-tools
git clone https://github.com/apache/couchdb
git clone https://github.com/apache/couchdb-pkg
cd couchdb-pkg
make couch-js-debs PLATFORM=bionic # howto use it? still cannot find jsapi.h
sudo dpkg -i js/couch-libmozjs185-*.deb

# build dpkg needed:
sudo apt install dh-exec dh-systemd nodejs python-sphinx

make build-couch $(lsb_release -cs) PLATFORM=$(lsb_release -cs)
```

## 概念

### 数据库(database)

概念比较:

| MongoDB    | CouchDB        |
| -------    | --------       |
| Collection | Database       |
| Key/Value  | _id/Document   |

在MongoDB中称 `database` 为 `Collection`。 一个`K/V键值对`在`CouchDB`称为 `Document`.

可以查询、创建和删除数据库，数据库的名称只能是小写字母、数字以及特殊字符_$()+-/。

* `GET /_all_dbs`: 查询 CouchDB 中所有的数据库名称。该请求返回的是一个 JSON 数组
  ```js
  ["_global_changes","_replicator","_users"]
  ```
* `GET /[database-name]`: 查询名为databasename的数据库的具体信息.
  ```js
  {"db_name":"_users","update_seq":"1-g1AAAA","sizes":{"file":38054,"external":5024,"active":2197},"purge_seq":0,"other":{"data_size":5024},"doc_del_count":0,"doc_count":1,"disk_size":38054,"disk_format_version":6,"data_size":2197,"compact_running":false,"instance_start_time":"0"}
  ```
* `PUT /[database-name]`: 创建名为databasename的数据库。如果数据库创建成功的话，返回 HTTP 状态代码 201 ；如果已有一个同名数据库的话，返回 HTTP 状态代码 412 。
* `DELETE /[database-name]`: 删除名为databasename的数据库。如果数据库删除成功的话，返回 HTTP 状态代码 200 ；如果数据库不存在，返回 HTTP 状态代码 404 。


#### 内部数据库

内部数据库以"_"打头。

* `_users` 为用户数据库(authentication)，默认匿名用户可以创建用户。可以在`_design/_auth`中添加限制，参考后面的代码样例。
* `_session`: 服务器端的用户会话管理。
* `_config` 为系统配置数据库，管理员配置也在其中。


##### 安全与认证(_users)

http://docs.couchdb.org/en/2.1.1/intro/security.html

* `_id` (string): Document ID. Contains user’s login with special prefix Why the `org.couchdb.user`: prefix?
* `derived_key` (string): PBKDF2 key
* `name` (string): User’s name aka login. Immutable e.g. you cannot rename an existing user - you have to create new one
* `roles` (array of string): List of user roles. CouchDB doesn’t provide any built-in roles, so you’re free to define your own depending on your needs. However, you cannot set system roles like _admin there. Also, only administrators may assign roles to users - by default all users have no roles. 你可以自己定义role，然后在`validate_doc_update`中去检测角色。
* `password_sha` (string): Hashed password with salt. Used for simple password_scheme
* `password_scheme` (string): Password hashing scheme. May be simple or pbkdf2
* `salt` (string): Hash salt. Used for simple password_scheme
* `type` (string): Document type. Constantly has the value user

Why the `org.couchdb.user`: prefix?

The reason there is a special prefix before a user’s login name is to have namespaces that users belong to. This prefix is designed to prevent replication conflicts when you try merging two or more `_user` databases.

For current CouchDB releases, all users belong to the same `org.couchdb.user` namespace and this cannot be changed. This may be changed in future releases.

### 文档（document）

文档是 CouchDB 中的核心概念。一个 CouchDB 数据库实际上是一系列文档的集合。每个文档是一系列数据项的集合。每个数据项都有一个名称与对应的值，值既可以是简单的数据类型，如字符串、数字和日期等；也可以是复杂的类型，如数组和对象。每个文档都有一个全局惟一的标识符（ID）以及一个修订版本号（revision number）。 ID 用来惟一标识一个文档（相当于Key），而修订版本号则用来实现多版本并发控制（Multiversion concurrency control，MVVC）。在 CouchDB 中，文档是以 JSON 对象的形式保存的。文档中至少要包含`_id`和`_rev`字段，其中以“_”作为前缀的顶层字段是由 CouchDB 保留使用的。

* `_id` : 全局惟一的标识符，用来惟一标识一个文档；
* `_rev` : 修订版本号，用来实现多版本并发控制（Multiversion concurrency control，MVVC）；
* `_attachments` : 内嵌型附件，以 base64 编码的格式作为文档的一个字段保存；


*  `GET /[databasename]/[doc_id]`
*  `PUT /[databasename]/[doc_id]` 创建或更新文档
  * 更新已有的文档:在 PUT 请求内容的文档中需要包含_rev字段，表示文档的修订版本号。 CouchDB 使用该字段来做更新时的冲突检测。如果该字段的值与 CouchDB 中保存的该文档的修订版本号一致，则表明没有冲突，可以进行更新。当更新完成之后，返回 HTTP 状态代码 201 ；否则返回 HTTP 状态代码 409，表示有版本冲突。
*  `POST /[databasename]` 创建文档,`_id`由系统决定。
*  `DELETE /[databasename]/[doc_id]?rev=[rev_id]` 删除数据库databasename中 ID 为doc_id，并且修订版本号为rev_id的文档。


用文档来描述关系：

```js
// 用内嵌文档 ID 描述多对多关系
 {
  "_id" : "user1",
  "username" : "Alex",
  "email" : "alexcheng1982@gmail.com",
  "roles":["db_admin","backup_admin"]
 }
 {
  "_id" : "db_admin",
  "name" : " 数据库管理员 ",
  "priority" : 2
 }

 // 用关联文档描述多对多关系
 {
  "_id" : "user1",
  "username" : "Alex",
  "email" : "alexcheng1982@gmail.com"
 }
 {
  "_id" : "db_admin",
  "name" : " 数据库管理员 ",
  "priority" : 2
 }
 {
  "_id" : "user_role_001",
  "user_id" : "user1",
  "role_id" : "db_admin"
 }
```

#### 文档查询

https://pouchdb.com/2014/04/14/pagination-strategies-with-pouchdb.html
https://pouchdb.com/guides/queries.html#pouchdb-find

Pouchdb这里推荐是all_docs

* `GET /[db]/_all_docs` is a special case for CouchDB. Instead of the normal Unicode Collation, it uses ASCII collation. 故不推荐使用[1][ViewCollation]。
* [POST /[db]/_find](http://docs.couchdb.org/en/2.0.0/api/database/find.html): 可以

```js
{
  "selector": {
    "_id": {"$gt": "产品\u0000", "$lt": "产品/\uffff"}
  }
}
```

`_find` 是类似MongoDB的查询方式(https://pouchdb.com/guides/mango-queries.html).
这里被称为`Mango queries`, 从CouchDB@2.1.1开始支持`partial indexes`查询以及分页。

数组的Mango查询类型：

```js
{
  "selector": {
    "tags": {$elemMatch: {$eq: 'apple'}}
  }
}
//等价于
{
  "selector": {
    "tags": {$in: ['apple']}
  }
}
```

如果数组类型是`json object`好像可以加索引(经测试无效，还是不能利用索引！)：https://stackoverflow.com/questions/35784178/how-to-index-multidimensional-arrays-in-couchdb
看到了，是Cloudant的扩展，全文检索引擎，索引类型必须为 `text`. 大致看来需要自己编译couchdb并使用它的dreyfus插件，菜可以和lucene连上。
https://developer.ibm.com/dwblog/2015/text-search-apache-couchdb/
https://github.com/cloudant-labs/dreyfus/wiki/Introduce-dreyfus-into-couchdb
https://github.com/apache/couchdb-docker/issues/8
https://github.com/grueni/oi-userland/tree/couchdb-dreyfus
https://github.com/neutrinity/ntr-couch-docker

```js
{
"Teams": [
  {
   "id": "79d25d41d991890350af672e0b76faed",
   "name": "First Team",
   "level": "123"
  },
  {
   "id": "e500c1bf691b9cfc99f05634da80b6d1",
   "name": "Second Team Name",
   "level": ""
  },
  {
   "id": "4645e8a4958421f7d843d9b34c4cd9fe",
   "name": "Third Team Name",
   "level": "123"
  }
 ],
 "LastTeam": "79d25d41d991890350af672e0b76faed"
}

//index:
{
  "index": {
    "fields": [
      {"name": "Teams.[].id", "type": "string"}
    ]
  },
  "type": "text"
}

//query:
{
  "selector": {
    "Teams": {"$elemMatch": {"id": "79d25d41d991890350af672e0b76faed"}}
  },
  "fields": [
    "_id",
    "FirstName",
    "LastName"
  ]
}
```

对数组的查询可以，但是目前没有索引支持！！
Currently couchdb find does not support indexing array members (https://issues.apache.org/jira/browse/COUCHDB-2867). Pouchdb is matching Couchdb's implementation here.


用Map/Reduce查询数组：

```js
//创建Map/Reduce索引
var designDoc = {
  _id: '_design/_index',
  views: {
    'by_tags': {
      map: function(doc) {
        if (Array.isArray(doc.tags)) {
          doc.tags.forEach(tag=>emit(tag));
        } else if (doc.tags) {
          emit(doc.tags)
        }
      }.toString()
    }
  }
};

pouch.put(designDoc).then(r=>console.log(r)).catch(e=>console.log(e))

//查询参数：详见后述「视图(View)的查询参数」
//keys 参数: 只获取在数组中的key名称。
pouch.query(viewName, {keys:['apple'], inclusive_end: false});

```


避免使用数组:

```
_id:  人/{id}/.tag/apple
name: apple
type: tag
```


至于limit的配置只能通过[max_document_size](http://docs.couchdb.org/en/master/config/couchdb.html).
或者 [max_http_request_size](http://docs.couchdb.org/en/master/config/http.html)
```ini
[couchdb]
max_document_size = 4294967296 ; 4 GB
[httpd]
max_http_request_size = 4294967296 ; 4 GB
```

不过有人在改： https://github.com/apache/couchdb-couch-mrview/pull/56/files
https://jira.hyperledger.org/browse/FAB-2809


[ViewCollation]: https://wiki.apache.org/couchdb/View_collation



### 文档变更通知

`GET /[db]/_changes`
`POST /[db]/_changes?filter=_doc_ids` 如果有大量的`doc_ids`，那么就只能用POST.


```
POST /recipes/_changes?filter=_doc_ids HTTP/1.1
Accept: application/json
Content-Length: 40
Content-Type: application/json
Host: localhost:5984

{
    "doc_ids": [
        "SpaghettiWithMeatballs"
    ]
}
```

#### Changes Feed

文档变更通知的三种方式

##### Polling

A list of changes made to documents in the database, in the order they were made, can be obtained from the database’s _changes resource. You can query the _changes resource by issuing a GET request with the following (optional) parameters:

| Parameter     |	Value                 | Default Value |	Notes |
| ------------- | --------------------- | ------------- | ----- |
| since 	      | seqnum/now 	          | 0 	          | (1)   |
| limit 	      | maxsequences 	        | none          |	(2)   |
| descending 	  | boolean 	            | false 	      | (3)   |
| feed 	        | normal/longpoll/continuous/eventsource | normal |	(4) |
| heartbeat 	  | milliseconds 	        | 60000 	      |  (5)  |
| timeout   	  | milliseconds 	        | 60000 	      |  (6)  |
| filter 	      | designdoc/filtername/_view |	none    |  (7)  |
| include_docs 	| boolean 	            | false 	      | (8)   |
| style 	      | all_docs/main_only  	| main_only 	  | (9)   |
| view 	        | designdoc/filtername 	| none 	        | (10)  |


Notes:

1. Start the results from the change immediately after the given sequence number.
2. Limit number of result rows to the specified value (note that using 0 here has the same effect as 1).
3. Return the change results in descending sequence order (most recent change first)
4. Select the type of feed.
5. Period in milliseconds after which an empty line is sent in the results. Only applicable for longpoll or continuous feeds. Overrides any timeout to keep the feed alive indefinitely.
6. Maximum period in milliseconds to wait for a change before the response is sent, even if there are no results. Only applicable for longpoll or continuous feeds. Note that 60000 is also the default maximum timeout to prevent undetected dead connections.

  You can change the default maximum timeout in your ini-configuration:
  ```ini
  [httpd]
  changes_timeout=#millisecs
  ```
7. Reference to a filter function from a design document that will filter whole stream emitting only filtered events. See the section in the book for more information.
8. Include the associated document with each result. If there are conflicts, only the winning revision is returned.
9. Specifies how many revisions are returned in the changes array. The default, main_only, will only return the current “winning” revision; all_docs will return all leaf revisions (including conflicts and deleted former conflicts.)
10. Allows to use view functions as filters. It requires to set filter special value _view to enable this feature. Documents counted as “passed” for view filter in case if map function emits at least one record for them.


##### longpoll

打开连接，等待直到有改变发生后，就立刻连接关闭。适合于低频率的更新。

##### continuous

一直打开连接,永不disconnect.


`GET /somedatabase/_changes?feed=continuous HTTP/1.1`

```
{"seq":1,"id":"fresh","changes":[{"rev":"1-967a00dff5e02add41819138abb3284d"}]}
{"seq":3,"id":"updated","changes":[{"rev":"2-7051cbe5c8faecd085a3fa619e6e6337"}]}
{"seq":5,"id":"deleted","changes":[{"rev":"2-eec205a9d413992850a6e32678485900"}],"deleted":true}
... tum tee tum ...
{"seq":6,"id":"updated","changes":[{"rev":"3-825cb35de44c433bfb2df415563a19de"}]}
```

##### eventsource

The eventsource feed provides push notifications that can be consumed in the form of DOM events in the browser. Refer to the [W3C eventsource specification](http://www.w3.org/TR/eventsource/) for further details. CouchDB honors the Last-Event-ID header, and if it’s present it will take precedence over the since query parameter.

```js
// define the event handling function
if (window.EventSource) {

  var source = new EventSource("/somedatabase/_changes?feed=eventsource");
  source.onerror = function(e) {
    alert('EventSource failed.');
  };

  var results = [];
  var sourceListener = function(e) {
    var data = JSON.parse(e.data);
    results.push(data);
  };

  // start listening for events
  source.addEventListener('message', sourceListener, false);

  // stop listening for events
  source.removeEventListener('message', sourceListener, false);

}
```

* http://guide.couchdb.org/draft/notifications.html
* http://docs.couchdb.org/en/2.1.1/api/database/changes.html 这个是最新的
* http://docs.couchdb.org/en/1.4.0/changes.html 这个写得简单清晰点。
* https://www.npmjs.com/package/couch-streams

### 视图（view） 与 Map/Reduce 查询

视图是 CouchDB 中文档的呈现方式。在很多情况下，应用都需要对文档进行一定的处理，包括过滤、组织、聚合和生成报表等。在关系数据库中，这通常是通过 SQL 语句来完成的。 CouchDB 中的视图声明了如何从文档中提取数据，以及如何对提取出来的数据进行处理。

CouchDB 中有两种视图：永久视图和临时视图。永久视图保存在设计文档的views字段中。临时视图是通过发送 POST 请求到 `/[databasename]/_temp_view` 来执行的。临时视图只在开发测试中使用，因为它是即时生成的，性能比较差；永久视图的运行结果可以被 CouchDB 缓存，因此一般用在生产环境中。

视图的运行由专门的视图服务器来完成。 CouchDB 中默认的视图定义语言是 JavaScript 。 CouchDB 中的视图运行使用的是 MapReduce 编程模型。每个视图的定义中至少需要提供 Map 方法，Reduce 方法是可选的。

Map 方法的参数只有一个，就是当前的文档对象。 Map 方法的实现需要根据文档对象的内容，确定是否要输出结果。如果需要输出的话，可以通过`emit`来完成。`emit`方法有两个参数，分别是key和value，分别表示输出结果的键和值。使用什么样的键和值应该根据视图的实际需要来确定。当希望对文档的某个字段进行排序和过滤操作的时候，应该把该字段作为键（key）或是键的一部分；value的值可以提供给 Reduce 方法使用，也可能会出现在最终的结果中。可以作为键的不仅是简单数据类型，也可以是任意的 JSON 对象。比如`emit([doc.title, doc.price], doc)`中，使用数组作为键。

```js
//map
function(doc) {
  //checks whether our document has a date and a title attribute
  if(doc.date && doc.title) {
      //The most important feature of a view result is that it is sorted by key.
      //emit key, value
      emit(doc.date, doc.title);
  }
}
```

通过 Map 方法输出的结果称为中间结果。中间结果可以通过 Reduce 方法来进一步做聚集操作。聚集操作是对结果中键（key）相同的数据集合来进行的。 Reduce 方法的输入不仅是 Map 方法输出的中间结果，也可以是上一次 Reduce 方法的结果，后面这种情况称为 `rereduce` 。 Reduce 方法的参数有三个：key、values和rereduce，分别表示键、值和是否是 rereduce 。由于 rereduce 情况的存在，Reduce 方法一般需要处理两种情况：

* 传入的参数`rereduce`的值为false：这表明 Reduce 方法的输入是 Map 方法输出的中间结果。参数key的值是一个数组，对应于中间结果中的每条记录。该数组的每个元素都是一个包含两个元素的数组，第一个元素是在 Map 方法中通过emit输出的键（key），第二个元素是记录所在的文档 ID 。参数values的值是一个数组，对应于 Map 方法中通过emit输出的值（value）。
* 传入的参数rereduce的值为true：这表明 Reduce 方法的输入是上次 Reduce 方法的输出。参数key的值为null。参数values的值是一个数组，对应于上次 Reduce 方法的输出结果。

```js
function(keys, values, rereduce) {
    return sum(values);
}
```


```js
{
  "_id": "_design/foo",
  "views": {
    "bar": {
      "map": "function (doc) { emit(doc.author, 1); }",
      "reduce": "_sum" //use the buildin reduce func to speedup.
      //"reduce": "function (keys, values, rereduce) { return sum(values); }"
    }
  }
}
```

http://docs.couchdb.org/en/2.1.0/ddocs/ddocs.html#reducefun-builtin


#### 视图(View)的查询参数

在查询视图的时候，支持以下的参数查询：

* conflicts (boolean) – Includes conflicts information in response. Ignored if include_docs isn’t true. Default is false
* descending (boolean) – Return the documents in descending by key order. Default is false
* endkey (json) – Stop returning records when the specified key is reached. Optional
* end_key (json) – Alias for endkey param
* endkey_docid (string) – Stop returning records when the specified document ID is reached. Requires endkey to be specified for this to have any effect. Optional
* end_key_doc_id (string) – Alias for endkey_docid param
* group (boolean) – Group the results using the reduce function to a group or single row. Default is false
* group_level (number) – Specify the group level to be used. Optional
* include_docs (boolean) – Include the associated document with each row. Default is false.
* attachments (boolean) – Include the Base64-encoded content of attachments in the documents that are included if include_docs is true. Ignored if include_docs isn’t true. Default is false.
* att_encoding_info (boolean) – Include encoding information in attachment stubs if include_docs is true and the particular attachment is compressed. Ignored if include_docs isn’t true. Default is false.
* inclusive_end (boolean) – Specifies whether the specified end key should be included in the result. Default is true
* key (json) – Return only documents that match the specified key. Optional
* keys (json-array) – Return only documents where the key matches one of the keys specified in the array. Optional
* limit (number) – Limit the number of the returned documents to the specified number. Optional
* reduce (boolean) – Use the reduction function. Default is true
* skip (number) – Skip this number of records before starting to return the results. Default is 0
* sorted (boolean) – Sort returned rows (see Sorting Returned Rows). Setting this to false offers a performance boost. The total_rows and offset fields are not available when this is set to false. Default is true
* stable (boolean) – Whether or not the view results should be returned from a stable set of shards. Default is false. Optional
* stale (string) – Allow the results from a stale view to be used. Supported values: ok, update_after and false. ok is equivalent to stable=true&update=false. update_after is equivalent to stable=true&update=lazy. false is equivalent to stable=false&update=true. Optional
* startkey (json) – Return records starting with the specified key. Optional
* start_key (json) – Alias for startkey param
* startkey_docid (string) – Return records starting with the specified document ID. Requires startkey to be specified for this to have any effect. Optional
* start_key_doc_id (string) – Alias for startkey_docid param
* update (string) – Whether or not the view in question should be updated prior to responding to the user. Supported values: true, false, lazy. Default is true. Optional
* update_seq (boolean) – Response includes an update_seq value indicating which sequence id of the database the view reflects. Default is false.


### 扩展概念

#### 附件(attatchment)

CouchDB 中也可以保存二进制文件。这些文件是以文档的附件形式存储的。 CouchDB 支持两种形式的附件：一种是内嵌型的，附件是以 base64 编码的格式作为文档的一个字段保存；另一种是独立型，附件是独立于文档保存和管理的。附件的存在使得可以在 CouchDB 中保存 Web 应用中的 HTML、CSS 和 JavaScript 文件。每个附件都包含名称、MIME 类型和数据等三项内容。

在请求文档的时候，内嵌型附件的实际数据默认是不包含的，包含的只是附件的元数据:

```js
{
   "_id": "testdoc",
   "_rev": "3-1364618102",
   "_attachments": {
       "Screenshot.png": {
           "stub": true,
           "content_type": "image/png",
           "length": 164279
       }
   }
 }
```

独立型附件可以在不改变文档的情况下，对附件进行操作。另外，不需要对附件进行 base64 编码。要创建独立型附件，只需要发送 PUT 请求到`databasename/doc_id/attachment?rev=rev_id`就可以创建或更新一个名为attachment的附件。 PUT 请求的内容类型（Content-Type）和内容指明了附件的类型和数据。


#### 设计文档(design document)

设计文档是一类特殊的文档，其 ID 必须以`_design/`开头。设计文档的存在是使用 CouchDB 开发 Web 应用的基础。在 CouchDB 中，一个 Web 应用是与一个设计文档相对应的。在设计文档中可以包含一些特殊的字段，其中包括：

* `views`: 包含永久的视图定义；
* `shows`: 包含把文档转换成非 JSON 格式的方法；
* `lists`: 包含把视图运行结果转换成非 JSON 格式的方法；
* `validate_doc_update`: 包含验证文档更新是否有效的方法。
* `updatefun(doc, req)`: 服务器端进行[更新文档处理器](http://docs.couchdb.org/en/2.1.1/ddocs/ddocs.html#update-functions)，在这里可以修改文档的值。

##### `validate_doc_update`

`function(newDoc, oldDoc, userCtx, secObj)`

回调函数参数说明:

* `newDoc`: incoming
* `oldDoc`: 如果是新建则无。
* `userCtx`:当前登录的用户的信息(来自`_users`数据库)
  * db: 当前数据库名称
  * name: 用户名
  * roles: 角色列表
* `secObj`: Security Object(来自 `_security` 数据库)
  * admins: 	Roles/Users with admin privileges
      * roles [array] 	List of roles with parent privilege
      * names [array] 	List of users with parent privilege
  * members 	Roles/Users with non-admin privileges
    * roles [array] 	List of roles with parent privilege
    * names [array] 	List of users with parent privilege

这个例子是 `_users` 数据库的，用来在注册/编辑/删除系统用户时候对数据进行验证。

```js
{
  "_id": "_design/_auth",
  "_rev": "1-c79bc00c889ce9b912fbde8a3f52de37",
  "language": "javascript",
  "validate_doc_update": "function(newDoc, oldDoc, userCtx, secObj){...see below...}"
}
```

```js
//validate_doc_update
function(newDoc, oldDoc, userCtx, secObj) {
    if (newDoc._deleted === true) {
        // allow deletes by admins and matching users
        // without checking the other fields
        if ((userCtx.roles.indexOf('_admin') !== -1) ||
            (userCtx.name == oldDoc.name)) {
            return;
        } else {
            throw({forbidden: 'Only admins may delete other user docs.'});
        }
    }

    if (newDoc.type !== 'user') {
        throw({forbidden : 'doc.type must be user'});
    } // we only allow user docs for now

    if (!newDoc.name) {
        throw({forbidden: 'doc.name is required'});
    }

    if (!newDoc.roles) {
        throw({forbidden: 'doc.roles must exist'});
    }

    if (!isArray(newDoc.roles)) {
        throw({forbidden: 'doc.roles must be an array'});
    }

    for (var idx = 0; idx < newDoc.roles.length; idx++) {
        if (typeof newDoc.roles[idx] !== 'string') {
            throw({forbidden: 'doc.roles can only contain strings'});
        }
    }

    if (newDoc._id !== ('org.couchdb.user:' + newDoc.name)) {
        throw({
            forbidden: 'Doc ID must be of the form org.couchdb.user:name'
        });
    }

    if (oldDoc) { // validate all updates
        if (oldDoc.name !== newDoc.name) {
            throw({forbidden: 'Usernames can not be changed.'});
        }
    }

    if (newDoc.password_sha && !newDoc.salt) {
        throw({
            forbidden: 'Users with password_sha must have a salt.' +
                'See /_utils/script/couch.js for example code.'
        });
    }

    if (newDoc.password_scheme === "pbkdf2") {
        if (typeof(newDoc.iterations) !== "number") {
            throw({forbidden: "iterations must be a number."});
        }
        if (typeof(newDoc.derived_key) !== "string") {
            throw({forbidden: "derived_key must be a string."});
        }
    }

    var is_server_or_database_admin = function(userCtx, secObj) {
        // see if the user is a server admin
        if(userCtx.roles.indexOf('_admin') !== -1) {
            return true; // a server admin
        }

        // see if the user a database admin specified by name
        if(secObj && secObj.admins && secObj.admins.names) {
            if(secObj.admins.names.indexOf(userCtx.name) !== -1) {
                return true; // database admin
            }
        }

        // see if the user a database admin specified by role
        if(secObj && secObj.admins && secObj.admins.roles) {
            var db_roles = secObj.admins.roles;
            for(var idx = 0; idx < userCtx.roles.length; idx++) {
                var user_role = userCtx.roles[idx];
                if(db_roles.indexOf(user_role) !== -1) {
                    return true; // role matches!
                }
            }
        }

        return false; // default to no admin
    }

    if (!is_server_or_database_admin(userCtx, secObj)) {
        if (oldDoc) { // validate non-admin updates
            if (userCtx.name !== newDoc.name) {
                throw({
                    forbidden: 'You may only update your own user document.'
                });
            }
            // validate role updates
            var oldRoles = (oldDoc.roles || []).sort();
            var newRoles = newDoc.roles.sort();

            if (oldRoles.length !== newRoles.length) {
                throw({forbidden: 'Only _admin may edit roles'});
            }

            for (var i = 0; i < oldRoles.length; i++) {
                if (oldRoles[i] !== newRoles[i]) {
                    throw({forbidden: 'Only _admin may edit roles'});
                }
            }
        } else if (newDoc.roles.length > 0) {
            throw({forbidden: 'Only _admin may set roles'});
        }
    }

    // no system roles in users db
    for (var i = 0; i < newDoc.roles.length; i++) {
        if (newDoc.roles[i][0] === '_') {
            throw({
                forbidden:
                'No system roles (starting with underscore) in users db.'
            });
        }
    }

    // no system names as names
    if (newDoc.name[0] === '_') {
        throw({forbidden: 'Username may not start with underscore.'});
    }

    var badUserNameChars = [':'];

    for (var i = 0; i < badUserNameChars.length; i++) {
        if (newDoc.name.indexOf(badUserNameChars[i]) >= 0) {
            throw({forbidden: 'Character `' + badUserNameChars[i] +
                    '` is not allowed in usernames.'});
        }
    }
}

```


## CouchApp

由于 CouchDB 的 REST API 使用 JSON 作为展现形式，因此使用 CouchDB 的 Web 应用只需要编写浏览器端的代码就可以使用 JavaScript 与 CouchDB 进行交互；而 CouchDB 所支持的附件功能，又使得浏览器端的 HTML、JavaScript 和 CSS 代码可以直接存放在 CouchDB 中。这样 CouchDB 中不但保存了 Web 应用的数据，也保存了 Web 应用的逻辑。也就是说，只需要 CouchDB 就可以构建一个完整的 Web 应用运行环境。

* https://github.com/couchapp/couchapp
* https://github.com/jo/couchdb-push Nodejs


结合CouchDB自带virtualhosts和pretty-urls，就可以实现将页面url地址重写到root.

* http://docs.couchdb.org/en/1.3.0/pretty_urls.html
* https://stackoverflow.com/questions/35643281/rewrite-urls-in-couchdb-pouchdb-server

### Couchapp

```bash
python2.7> pip install --user couchapp
couchapp init myapp
cd myapp
```

#### Change your App ID

open the `_id` file: change your app name.


#### set config

`.couchapprc`:

```js
{
  "env" : {
    "default" : {
      "db" : "http://admin:secret@localhost:5984/test"
    },
    "prod" : {
      "db" : "http://admin:password@myhost.com/mydb"
    }
  }
}
```

couchapp push
couchapp push prod


#### Add Some Web Pages

Now we are going to add a index page for our CouchApp. So we can place the index.html under _attachments. CouchDB can directly serve our attachments as static files.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>CouchApp</title>
</head>
<body>
  <h1>Hello CouchApp!</h1>
</body>
</html>
```

#### Push your CouchApp

Now that we have created our basic application, it’s time to push it to our CouchDB server. Our CouchDB server is at the url http://127.0.0.1:5984 and we want to push our app in the database testdb:

```bash
$ couchapp push testdb
```

Go on http://127.0.0.1:5984/testdb/_design/myapp/index.html, you will see.

## [Fauxton](https://github.com/apache/couchdb-fauxton/)

是Couchdb自带的WebUI: http://127.0.0.1:5984/_utils/index.html

似乎还没有启用，所以暂时没有语法高亮，但：
app/addons/components/components/codeeditor.js


[CouchDB Nano Client NodeJS](https://github.com/apache/couchdb-nano)


## CouchDB As Graph

https://stackoverflow.com/questions/25949524/implications-of-modeling-a-graph-in-couchdb

I've been toying with modeling a graph structure (property graph with named relationships) in couchdb and would like to know what are the potential bottlenecks in performance that I will find.

I'm using the following principles:

    Keep documents small.
    Try to embed as little as possible.
    Record all relationships between documents as a new document (a link).

It seems that all these principles are in contradiction with couchdb's philosophy. But bare with me.

With this principles, for example, tagging a person becomes three documents:

```js
{ _id: '10', type: 'person', 'name': 'John Doe' }
{ _id: '20', type: 'tag', 'name': 'Important' }
{ _id: '30', type: 'link', from: 10, to: 20, name: 'tag' }
```

I have also created the following views in a _design document called links:

```js
{
  outgoing: {
    map: function(doc) {
      if (doc.type == 'link') {
        emit([doc.from, doc.name], {_id: doc.to});
      }
    }
  },
  incoming: {
    map: function(doc) {
      if (doc.type == 'link') {
        emit([doc.to, doc.name], { _id: doc.from });
      }
    }
  }
}
```

I can get all the links incoming or outgoing from a document with these urls:

```
http://host/db/_design/links/_view/incoming?startkey=["10"]&endkey=["10",{}]
http://host/db/_design/links/_view/outgoing?startkey=["10"]&endkey=["10",{}]
```

I can even get all the links by name with these urls:

```
http://host/db/_design/links/_view/incoming?startkey=["10","tag"]&endkey=["10","tag",{}]
http://host/db/_design/links/_view/outgoing?startkey=["10","tag"]&endkey=["10","tag",{}]
```

And if I include the include_docs=true parameter I get the documents referenced by the link; either incoming or outgoing. So far so good. There is a graph structure and a way to query it, albeit on a node by node basis.

Good things about this approach:

    It is a general way of storing all relationships. Not necessarily tags, but every relationship.
    You can change the tag name quickly, without changing every person tagged.
    You can merge persons or tags and just update the link documents, which should be very simple.
    Tagging when using replication does not change the documents being tagged or the tags themselves. Just add or delete a tiny link document.
    It would be easy to keep a history of tags for each element.

Bad things, and where I need your help:

    Query for a list of people with their tags is not trivial. In general, querying for a list of documents and their relationships is a very expensive operation that requires many hits.
    Updating the database and keeping it consistent could be a problem. Maybe this is something that will never go away when using couch.
    Doing 'maintenance' on the database, like finding orphan links, could be expensive. Perhaps the database requires garbage collection?
    Visualizing and manipulating this graph structure is neither intuitive nor simple, and applications developed on top of it are responsible for all the graph structure management (which is a bit scary!).

So back to my questions:

    What are the potencial bottlenecks to expect?
    Will this approach scale to millions of records?
    How to do traversing of this structure efficiently without having to do many server hits?


http://grokbase.com/t/couchdb/user/09735ya0m7/map-reduce-graph-traversal-in-couchdb

http://grokbase.com/t/couchdb/user/115gv4yhr6/data-js-a-graph-manipulation-framework-on-top-of-couchdb

就是这个： https://github.com/substance/data
https://github.com/substance/substance

http://probablyprogramming.com/2008/07/04/storing-hierarchical-data-in-couchdb
https://stackoverflow.com/questions/6129561/retrieving-hierarchical-nested-data-from-couchdb

-------------------------
CouchBase已经fork了很远以前，查询语言也不一样。

CouchDB的手机端用PouchDB. CouchBase也有CouchBaseLite（可以同步到CouchDB）.
CouchDB在单机时候就要预先订好shard数量。


## CouchDB Client

* PouchDB
  * https://github.com/pouchdb/pouchdb/issues/2521

```js
var PouchDB = require('pouchdb');
var pouch = new PouchDB('testdb_changes');
var remotePouch = new PouchDB('http://localhost:5984/testdb_changes');
var Promise = require('bluebird');

pouch.bulkDocs([{_id: '1'}, {_id: '2'}]).then(function () {

  return new Promise(function (resolve, reject) {
    pouch.replicate.to(remotePouch).on('complete', function (changes) {
      resolve(changes);
    }).on('error', reject);
  });
}).then(function (change) {
  var lastSeq = change.last_seq;
  console.log("lastSeq is: " + lastSeq);
  return pouch.put({_id: '3'}).then(function () {
    return pouch.changes({since: lastSeq});
  }).then(function (changes) {
    console.log('local changes are: ' + JSON.stringify(changes));
    return remotePouch.allDocs();
  }).then(function (res) {
    console.log('remote pouch contains: ' + JSON.stringify(res));
    return pouch.allDocs();
  }).then(function (res) {
    console.log('local pouch contains: ' + JSON.stringify(res));
  });
}).catch(function (err) {
  console.log(err);
});
```

  * https://github.com/pouchdb/pouchdb/issues/5713
    * `change` 事件中有 `pending` 属性检测同步进度。

```js
var pendingMax = 0;
var batch_size = 1000;    // must match your replication options

function getProgress(pending) {
  var progress;
  pendingMax = pendingMax < pending ? pending + batch_size : pendingMax;  // first time capture
  //pendingMax = pendingMax < pending ? pending : pendingMax;  // wouldn't use batch size in the calculation
  if (pendingMax > 0) {
    progress = 1 - pending/pendingMax;
    if (pending === 0) {
      pendingMax = 0;    // reset for live/next replication
    }
  } else {
    progress = 1;  // 100%
  }
  return progress;
}

var replication = db.replicate.from(remote, {
  live: true,
  retry: true,
  batches_limit: 10,
  batch_size: 1000      // must match above batch_size
}).on('change', function (info) {
  console.log('Replication Progress', getProgress(info.pending));
})
```

### RxDB

* RxDB: 内部使用PouchDB，
  * 不爽的地方：一个Collection就是一个PouchDB数据库。
  * RXJS支持。


rxdb 不支持utf8(unicode)字段名。完全没有必要es5部分支持，es6完全支持unicode 标识符：
https://mathiasbynens.be/notes/javascript-identifiers
https://mathiasbynens.be/notes/javascript-identifiers-es6
https://stackoverflow.com/questions/1661197/what-characters-are-valid-for-javascript-variable-names

```js
//plugins/schema-check.js
export function checkFieldNameRegex(fieldName) {
    if (fieldName == '') return;

    if (['properties', 'language'].includes(fieldName))
        throw new Error(`fieldname is not allowed: ${fieldName}`);

/* //comments for support unicode:
    const regexStr = '^[a-zA-Z][[a-zA-Z0-9_]*]?[a-zA-Z0-9]$';
    const regex = new RegExp(regexStr);
    if (!fieldName.match(regex)) {
        throw RxError.newRxError(
            'fieldnames do not match the regex', {
                regex: regexStr,
                fieldName
            }
        );
    }
*/
};
```


目前PouchDB有个问题没有解决，直接会导致本地数据库越来越大，同时也难以LRU。
https://github.com/pouchdb/pouchdb/issues/802
