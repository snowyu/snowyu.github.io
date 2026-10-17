---
author: riceball
id: ku3j619yd215nv6lcalfvr3
title: Cordis 的坑与账
desc: 一个栈、几个造出来的词、两种加东西的加法，以及用它的长期账单
date: 2026-10-17 19:20:07+08:00
updated: 1791429073218
created: 1791272696443
---

# Cordis 的坑与账

> 坑是陷人的地方，账是未来要承担的后果。
>
> 读不完的话：第 2 节讲它真正做了什么（其实只有一个栈），第 4 节讲它哪里长错了，第 8 节讲你该不该用。

---

## 0. 两个主角

### 被评估的：Cordis

Koishi 聊天机器人框架的内核，后来 DeepSeek 的 DSH（DeepSeek Harness，Agent 运行时）拿它当底座。

类型上是**插件元框架**：本身不含任何业务能力，只管插件怎么装进一个长期运行的进程、怎么互相依赖、怎么卸载。Koishi 社区插件 4000+（论文口径，Koishi 官方没有给出精确统计）。

DSH 这一侧没有精确数字：**官方没有插件中心**。官方 FAQ 原话是"There is no central registry. The one official discovery mechanism is the GitHub topic `dsh-plugin`"。按这个 topic 计的仓库数在 1.7 万量级（2026-10 的第三方统计，各家口径从几千到 17,894 不等，且 topic 数 ≠ 可安装插件数）。所以**不能拿"DSH 有几千个插件"当论据**——那个数字既没有官方背书，也不是插件数。

还有一处容易忽略：**DSH 不是依赖 cordis 这个 npm 包，而是把源码整包复制进自己的 `vendor/` 目录，改名 `@deepseek-ai/cordis`**。vendored 的版本是 **4.0.0-rc.7**，落后于上游当前的 **4.0.0-rc.10**（2026-09-08）。你读到的文档、看到的 API，可能和你 `npm i cordis` 装到的不是同一个。

> **本文凡涉及机制与行为，一律以仓库源码为准；论文、文档与源码冲突时服从源码。** 而且"源码"有两个——上游 `cordiverse/cordis` 和 DSH `vendor/cordis`，两者不等价，见下。第 3 节会说明为什么这条规则在这里格外必要。

### DSH 改了什么：一份不短的补丁清单

vendor 化的动机官方写得很明白：harness 要**完全拥有自己的框架层**——可审计（auditable）、可打补丁（patchable）、版本可固定（pinned）。改名是为了不抢占上游的 npm 包名。

改动记在 `vendor/README.md` 的本地修改日志里，共十八条。与本文主题相关的三条：

**① `cordis/src/fiber.ts` 生命周期加固——堵了三个"可重入回收"漏洞。** 这是唯一动了行为的一条：

- effect 的 owner-list 包装**在 setup 执行之前**就注册好，所以"从 setup 内部发起的卸载"会等 setup 和全部已收集的清理跑完
- setup 同步失败时移除包装、回滚已收集的清理
- 异步清理在静止前**一直对 owner 可见**；内部 effect 组合会加入一个已在运行的清理；**重复调用公开 disposer 仍保持上游的一次性语义**
- **owner 处于 UNLOADING 时拒绝新建 effect**（PENDING 与 LOADING 仍允许）——防止清理阶段新注册的东西逃出这次卸载的快照
- 子 fiber 在发布前先拿到父级 disposer；清理通知按观察者逐个隔离错误，一个回调报错不会饿死其他回调

**② `Fiber.update()` 改为返回内部 `update` waterfall 的结果**，让 Loader 能 await 重启流程，同时保留同步的配置校验与失败语义。

**③ JSDoc 补写**（`disposal semantics`、`waterfall veto`、`bail conditions`）——官方注明"comment-only; no code changes"，动机是站点 API 参考生成器遇到未文档化成员会直接报错。

**这三条说明两件事。** 一是 DeepSeek **不是照搬**，确实在卸载边界上下了功夫——而这块恰恰是"可逆 effect"最容易出错的地方。二是**这些加固在 `vendor/` 里，不在上游**：上游 rc.7→rc.10 自己也在修同类问题（rc.10 的 changelog 里有 "core: reject repeated `next()` calls from a waterfall listener"、"core: do not leave fiber failures unhandled"）。所以判断"某个坑还在不在"，要先问一句：**你读的是哪一份代码**。本文默认以上游为准，凡是 DSH 额外修掉的，单独标出。

- 仓库：<https://github.com/cordiverse/cordis>
- DSH 仓库与 vendor 目录：<https://github.com/deepseek-ai/deepseek-harness>
- 官方文档：<https://deepseek-harness.github.io/deepseek-harness/en/reference/cordis-primer>
- 上手教程：<https://deepseek-harness.github.io/deepseek-harness/en/develop/cordis-tutorial>

### 用来做参照的：tool-func 系列

isdk 的一组小库，从下往上是一条链：

- [`tool-func`](https://github.com/isdk/tool-func.js)：函数注册表，让函数能自描述、被别人发现
- [`tool-rpc`](https://github.com/isdk/tool-rpc.js)：把注册的函数暴露到网络上，本地/远程对调用方透明
- [`tool-event`](https://github.com/isdk/tool-event.js)：把实时事件也当作"一个工具"，复用 RPC 的生态

第 4 节会拿它当尺子：**同一个需求，另一种长法是什么样子。**

## 1. 它解决什么问题

**一个 bot 进程要 7×24 运行，插件要能不重启进程地装卸和升级。**

这句话听起来平平无奇，把它变成画面：

> 你的机器人已经连续跑了半年，群里几千人在用。现在你要给"天气查询"插件修一个 bug。
> 重启意味着全体下线半分钟。
> 你要的是：改完代码、保存、这个插件自己卸掉旧版本、装上新版本，群里的对话一次都没断。

要做到这件事，必须解决四个问题：

| 需求 | 需要什么 |
| --- | --- |
| 插件能装进进程 | 一个注册表，按名字找到插件 |
| 插件能卸载且不留垃圾 | 卸载时清理它注册过的所有东西：定时器、监听器、临时文件 |
| 清理不能乱序 | 后创建的先释放 |
| 插件之间有依赖 | 依赖失效时下游跟着拆，依赖回来时跟着装回去 |

**这四条是主干。** 主干之外 Cordis 还提供了：五种事件分发方法、配置系统、声明合并式的服务查找。那些是否必要、代价是什么，第 4 节和第 5 节逐项说明。

时间线在第 0 节已经给全了，这里只留结论：**代码跑了六年，理论才补上来。** 这个顺序在第 3.5 节要反复用。

## 2. 核心机制：一个栈

第 1 节里第 2、3 条需求（能清理、不乱序），实现出来就是一个**函数栈**。

### 2.1 不用框架时会怎么写

插件启动做了三件事：

```typescript
const pool = openPool()                              // 1. 开一个数据库连接池
const timer = setInterval(() => pool.query(), 1000)  // 2. 每秒用连接池查一次
ctx.on('message', handler)                           // 3. 挂一个消息监听器
```

卸载时你得手动写三行，而且顺序不能错：

```typescript
ctx.off('message', handler)   // 先摘监听器
clearInterval(timer)          // 再停定时器
pool.close()                  // 最后关连接池
```

**为什么必须是这个顺序？** 假设你先关连接池、后停定时器——在"池已关、定时器还在"的那几毫秒里，定时器可能又触发一次 `pool.query()`，拿一个已关闭的连接池查数据，必然报错。反过来，先停定时器再关池，怎么都不会错。

### 2.2 Cordis 的方案

它做的全部事情，是把这个顺序交给一个栈。

先把签名写对——**真实的 `ctx.effect()` 不是 `effect(acquire, release)` 两个参数**，上游 `fiber.ts` 里的重载是：

```typescript
effect(execute: () => SyncEffect, label?: string): Disposable
effect(execute: () => Effect,     label?: string): AsyncDisposable
```

**只有一个回调**。它立即执行，回调返回（或 `yield`）的那个函数就是 disposer，被收进当前 fiber 的 disposables。第二个参数 `label` 只用于诊断输出（默认 `'anonymous'`），不影响行为。

所以栈的形状是：

```typescript
// 注册时：execute 立即执行，它返回的 disposer 入栈
function effect(execute: () => Disposable, label = 'anonymous') {
  const disposables: Disposable[] = []
  // execute() 的返回值 / 每次 yield 的值 → disposables.push(...)
  return () => {                            // 这就是被挂到 fiber 上的 dispose
    let task!: void | Promise
    for (const dispose of disposables.splice(0).reverse()) {   // 逆序
      if (task) task = task.then(dispose)   // 遇到异步就串成链
      else { const r = dispose(); if (isObject(r) && 'then' in r) task = r }
    }
    return task
  }
}
```

用真实的写法重写刚才那三件事：

```typescript
// 1. 连接池：获取写在函数体里，关闭作为返回值交回框架
ctx.effect(() => {
  const pool = openPool()
  return () => pool.close()
})

// 2. 定时器：同理
ctx.effect(() => {
  const timer = setInterval(/* ... */, 1000)
  return () => clearInterval(timer)
})

// 3. 监听器：不用包，ctx.on 本身就是一个 effect
ctx.on('message', handler)
```

注意第 1 条里的 `pool` 是 effect 内部的局部变量——**业务代码要用它，就得把它挪到外面去**（坑三会讲这件事）。

**`ctx.on()` 已经是 effect，再拿 `ctx.effect` 包一层是多余的。** 官方原话："Because ctx.on() is an effect, the listener disappears with the plugin — no manual removeListener bookkeeping, ever." 同理，`ctx.plugin()`、服务注册、`ctx.tools.register()` 也都自带 disposer。

卸载时一行 `dispose()`，栈自己从顶往下弹。**你不再需要记住顺序。**

### 2.3 为什么"反着来"总是对的

规律是：**后创建的东西往往依赖先创建的东西。**

这个"往往"为什么可靠到不需要分析依赖？因为**变量作用域**已经替你保证了：定时器回调里引用了 `pool` 这个变量，那么 `openPool()` 那一行就必然写在 `setInterval` 前面——"先定义后使用"和"依赖在前、依赖者在后"是同一个顺序。

LIFO（后进先出）把注册顺序一反转，恰好反转了依赖顺序。**它不是猜对了依赖，它是复用了语言几十年的"先定义后使用"规则。**

准确的说法是：**LIFO 不分析依赖，它只是沿用注册顺序的逆序。** 刻意违反时不成立：

```typescript
let pool: Pool
ctx.effect(() => {                                        // 先注册定时器
  const t = setInterval(() => pool.query(), 1000)
  return () => clearInterval(t)
})
ctx.effect(() => { pool = openPool(); return () => pool.close() })  // 后才拿到池
// 卸载时 LIFO：先关池、后停定时器 —— 顺序错了，且没有任何报错
```

这段代码能通过编译（`let` 的声明被提升了）。机制的全部实现是一个数组加一次 `reverse()`。

**这个 `effect` 业界早有现成的名字**：Haskell 的 `bracket`、Effect-TS 的 `acquireRelease`，中文就是"成对的资源获取与释放"。C++ 的 RAII 也算近亲，但它绑在词法作用域退出（离开大括号就析构），而 Cordis 这个不绑作用域、绑运行时——所以更准确的名字是**运行时可组合的 acquireRelease**。

注意：**Cordis 的这一版把 acquire 和 release 合进了同一个回调**——"获取"写在函数体里，"释放"作为返回值返回。Effect-TS 的 `acquireRelease` 是两个参数、`bracket` 是三个，Cordis 是一个。这不是优劣，是选择：一个回调换来的是可以 `yield` 多次（生成器形式），以及 `label` 可诊断；代价是**资源本体要自己保存**——见坑三。

**所以 Cordis 在这里的真实增量只有一步**：把"谁后获取谁先释放"从写在代码里的语法结构（`try/finally`），变成运行时可组合的数据结构（栈）。互不相识的插件各自往栈里压一对"资源 + 清理函数"，卸载时统一弹出。只有这一步有价值。

`ctx.effect()` 的签名也验证了这条规则的必要性：论文里的抽象形态是 `effect(e)`（e 是一个返回逆的回调），文档里也是单回调；而不少二手文章（包括本文初稿）写成了 `effect(acquire, release)` 两参数。**这一处写错，坑三的整个论证都会跟着偏。** 这类地方一律查 `fiber.ts`。

### 2.4 插件与插件之间，也是这个顺序

A 插件提供数据库服务，B 插件依赖它、起定时器用它的池。

- 加载时：B 等 A 就绪才开始（Cordis 里这个状态叫 **PENDING**）
- 卸载时：A 要下线，B 先被拆

**激活 A→B，拆解 B→A**，和 2.3 是同一个顺序。函数粒度用栈，插件粒度用依赖图；两处都不做分析，都依赖顺序本身。

热重载也同样朴素：配置变了 → 旧插件清理 → 新插件带新配置初始化。

### 2.5 五条边界

机制能管到哪儿，全部写在这五条里。**管住的东西自动正确，没管住的东西彻底没人管，没有中间地带。**

**边界一：栈只管通过 effect 注册的东西。**
裸的 `setInterval`、裸的 `openPool()`，框架看不见也不清理——卸载后定时器继续每秒触发，查一个再没人用的连接池，**没有报错，静默泄漏**。Cordis 为此提供了包装过的定时器方法；第三方资源必须你自己套一层 `ctx.effect`。

（注意：定时器不在 core 里，在 `@cordisjs/plugin-timer` 这个独立包，通过 `ctx.mixin()` 把方法挂到 Context 原型上，所以能直接 `ctx.timeout()` / `ctx.interval()` 而不用 `ctx.timer.xxx`。旧名 `ctx.setTimeout` / `ctx.setInterval` 现在是**已弃用的别名**——这几个方法内部都走 `ctx.effect()` 注册 `clearTimeout`/`clearInterval`。）

**边界二：顺序只沿用注册先后。**
2.3 的反例已经演示了：倒序注册，LIFO 安静地给出错误顺序。

**边界三："可逆"只对成对的注册类操作成立。**
`on/off`、`open/close`、`register/unregister` 是真互逆；消息已发出、数据已写库，不可撤销——清理函数顶多补偿。框架保证清理的**时机和顺序**，不保证时间倒流。

**边界四：异步清理不保证按逆序完成。**
这一条官方明文写了，原话是 "disposer invocation **starts** in reverse registration order, but multiple async disposers run concurrently and have **no serial completion guarantee**"。

差别在于：**启动是严格逆序的，完成不是。** 真正的实现（上游 `fiber.ts`）是 `disposables.splice(0).reverse()` 逐个调用，遇到返回 Promise 的就用 `task = task.then(dispose)` 串成一条链——所以它其实做了串行化，只是这条链只对"同一个 `ctx.effect()` 内部收集的多个 disposer"成立；不同 effect 之间的清理仍由 `Promise.all` 并发跑。于是卸载期间存在一个**半卸载窗口**：服务已注销、定时器还在跑。

官方给的应对是**合并**：如果卸载必须先停轮询、再关连接、最后释放文件，这三步不要拆成三个独立 disposer，写进同一条清理链。

**边界五（DSH 特有，上游没有）：UNLOADING 期间不许再注册。**
DSH 的 vendor 补丁加了一条：owner 处于 `UNLOADING` 时**拒绝新建 effect**（`PENDING`、`LOADING` 仍允许）。这条补的是一个真实漏洞——清理函数里如果又去注册新东西，那东西会逃出这次卸载的快照，变成谁也不管的孤儿。上游没有这条。

### 2.6 Cordis 已经做到的几件事

以下四件是它真实的加固：

- **部分回滚是有的。** `ctx.effect()` 接受生成器形式：`fiber.ts` 里 `Symbol.iterator in effect` 的分支会 `while(true) { iter.next(); safeCollect(result.value) }`，把每步 `yield` 的逆操作**立即**收集。所以加载中途失败时，只撤销已经执行的部分。DSH 的 vendor 补丁进一步保证：setup 同步失败时移除包装、回滚已收集的清理。
- **disposer 是一次性的。** 这一点有官方背书，但说法要改：DSH 的 vendor 修改日志写的是"repeated public disposer calls retain their **upstream single-shot result**"——即重复调用不会执行两次，但公开材料里查不到名为 `armed` 的标志（那是第三方博客的转述，不是 API 合同）。实现上是 `splice(0).reverse()` 清空 + `_disposables.delete()` 摘除，一次性由此得到。
- **终态一致性有形式化保证。** 论文给了 confluence（汇合性，Theorem 80）：无论以什么顺序加载或卸载，最终静止状态等价于按最终配置一次性从零装配。
- **服务不是全局单例。** `ctx.isolate(name, label?)` 给指定服务名建一个独立解析域——源码就是 `Object.create` 一层 shadow 加上新 label。相同 label 归同一作用域，不同 label 才隔离。

confluence 保证的是"最终一致"，不保证"过程中一致"。半卸载窗口依然存在，卸载也没有跨插件的事务语义——A 拆完、B 重装失败，没有补偿协议。这一点连 DSH 自己都认：它的 vendor 日志里对 loader 的措辞是"eager, non-transactional implementation and **do not restore previous plugins or options**"，并且明说配置改动失败会"leave a partially applied tree"。

## 3. 造词：论文里的故作高深，工程里的学生气

第 2 节的机制都很朴素。看 Cordis 给它们起的名字：

| 实际机制 | Cordis 的叫法 | 这个词原本属于哪里 |
| --- | --- | --- |
| 按相反顺序清理 | 逆序回放（reverse replay） | 事件溯源、日志重放 |
| 执行清理函数 | 回滚（rollback） | 数据库事务 |
| 作用域嵌套 | 空间维可组合性 | 物理学 |
| 相反顺序的装卸 | 时间维可组合性 | 物理学 |

**滥造词的判别式：一个词的字面含义指向这套机制不具备的性质，读者按字面理解必然产生错误预期。**

- 按"回滚"的字面义，你以为有版本记录、能回到之前的状态——没有，就是调用一个清理函数。
- 按"回放"的字面义，你以为存了操作日志能重放——没有，就是栈的 `pop()`。

这些词不是同一个毛病，它们来自两种完全不同的动机。

### 3.1 论文里的：为了显得高深

最典型的是那篇论文《A Programming Paradigm for Spatiotemporal Composability》（[arXiv:2608.25512](https://arxiv.org/abs/2608.25512)，cs.PL，v1 提交于 2026-08-26，预印本且在持续修订。逐项还原：

- **时间维可组合性** = 析构顺序：C++ 的 RAII、Haskell 的 `bracket`、Effect-TS 的 `acquireRelease`，都是现成的
- **空间维可组合性** = **作用域 + 依赖的响应式解析**。论文摘要对 spatial 的定义是"declare and **reactively manage** inter-component dependencies"：不只是 ctx 嵌套和原型链 shadow，还包括依赖声明（coeffect 规约）、依赖到位才激活、依赖消失自动停用、依赖被替换则级联重载。**把它还原成单纯的"作用域"会低估对手**——依赖图与级联重连确实是 Cordis 比作用域多做的部分（见 2.4），批评要对着完整的东西发。
- 形式化骨架：论文把"每次变更携带一个逆"记为对一个上下文的变换（第三方转述常写成 `Γ→Γ×(Γ→Γ)` 这类记法，我未能在论文原文中逐字核对，**此处按转述处理**）；落到代码就是 `ctx.effect(execute)` 那个单回调签名和它收集的 disposer 链

把"卸载时按逆序调用清理函数"写成一套演算，把"作用域 + 依赖解析"写成"空间维"，这不是为了说清楚，是为了**让它看起来不像已经存在的东西**。新造的术语天然不可比对：读者没法拿"时空可组合性"去搜，也就没法发现它其实就是作用域、析构顺序和依赖图。

问题在于这组词进了论文，**没有一个人回头补一句"这就是作用域加析构顺序加依赖图"**。

**一句话说清它的真实贡献**：把学术里已有的 effect / coeffect 两个**编译期**概念，搬到**运行时**当机制用——`ctx.effect` 是 reversible effect，`ctx.set` + `inject` 是 reactive coeffect。这是有分量的工程组合，也是论文摘要自己承认的说法（"lifting classical effect and coeffect concepts to runtime mechanisms"）。但搬过去不等于发明，"范式"和"时空"这两个名字夸大了它。

### 3.2 工程里的：学到哪用到哪

另一批词没有那么强的野心，它们只是**学生气**——作者刚学会什么，就用什么来命名眼前的东西：

- 刚读完数据库事务 → 清理函数叫"回滚"
- 刚看完事件溯源 → 栈的弹出叫"回放"

这不是欺骗，是词汇量跟不上表达欲的正常阶段：手里只有这几把锤子，看什么都像钉子。人人都经历过。

### 3.3 这两年的新词：用含糊换掉精确

这股风气现在更盛，AI 领域按周产词。举三个例子：

**harness**——原意是马具、线束、安全带。现在指"Agent 的运行时外壳"。字面义完全不指向实际含义，第一次见只能靠猜。DSH 里的 H 就是它。

**MCP**（Model Context Protocol）——"工具要能被发现、被调用"这件事，**OpenAPI 加一个发现端点早就够了**。三条常见辩护（省上下文、管凭证、把多个调用串成一个任务）分别对应文档裁剪、网关、服务端多包一层，没有一条要求一个新协议。它真正原创的两样东西反而正在被自己删掉：规范 2026-07-28 版同时**弃用（deprecate）**了 Sampling（服务端请求客户端跑一次 LLM）和 Roots（SEP-2577；官方弃用注册表注明最早 2027-07-28 之后才移除，**弃用 ≠ 删除**）。同一版官方博客的原话是 "With the 2026-07-28 release, a remote MCP server is now **no different from any other HTTP workload**"——远程 MCP 服务器变得和任何其他 HTTP 工作负载没有区别，这等于承认它不再是一个"特殊的协议端点"。

而它把工具返回结果文本化这一条改不掉了：规范对结构化结果的要求是 "For backwards compatibility, a tool that returns structured content **SHOULD** also return the serialized JSON in a TextContent block"——是 SHOULD（向后兼容建议）不是 MUST，但多数实现照做，于是**同一份数据发两遍**。**底层丢掉结构，上层就得一路补上**，和 4.3 里 Cordis 的 `emit` 是同一个病。它剩下的价值是生态（写一次到处能用），那和 npm 是同一类，不是协议的功劳。

**上下文工程**（context engineering）——毛病不在"工程"两个字。"工程"用得其所：把 prompt 从一次性的字符串，变成可复用、可组装、可版本管理的输入构造流程，确实是在做工程。

毛病在**用一个含糊的词换掉一个精确的词**：

- `prompt` 在 IT 里此前没有别的意思，一说就知道是喂给 LLM 的那段输入，不会歧义。所以"提示词工程"四个字已经说清楚了：对喂给 LLM 的输入做工程管理。
- `context` 不一样。进程上下文、React Context、HTTP context、Cordis 自己的 Context——它在 IT 里早就被用烂了，每个领域一个意思。

于是这次造词的净效果是：**凭空多了一个同义词，同时把一个精确的词换成了一个含糊的词。** 两边都亏。

能被一个旧词说清楚的，就是滥造词。"上下文工程"还原成"提示词工程"，四个字就说完了。MCP 还原成 OpenAPI 加发现端点——它自己也在往那边走。

### 3.4 形式化本身没有错

形式化有正当价值——一条规则管住全部行为、可机器检查。给已完成的工程补写形式化说明，业界常见。

Cordis 的真实贡献是把 acquire/release 与运行时插件装卸、依赖重连**组合**了起来——有分量的工程组合。但组合不是发明，"范式"和"时空"这两个名字夸大了它。

### 3.5 水分在哪：论文与代码对不上的地方

上面几节只是"名字起得大"。这一节是更硬的判断依据：**论文与仓库 README 自己声明，理论是事后补写的。**

- 论文仓库 README 写着 "This is a preprint **under active revision**"，并邀请读者邮件提交修正（shigma@cordis.io）。
- 时间顺序摆在那里：Koishi 2020-01 → cordis 仓库 2022-05 → DSH 2026-08-13 → 论文 2026-08-26。**代码跑了六年，理论写了十三天之后才挂上去。**
- 论文给的是"证明一个已存在系统应该具有的性质"，不是"先有理论再长出系统"。这个方向本身不丢人，但它决定了论文的用处：它是一份**事后说明书**，不是一份**设计依据**。

于是可以给出一条务实的读法，也是本文采用的做法：

> **论文用来查它声称保证什么；代码用来查这些保证是否真的成立。两者冲突，以代码为准。**

已经发现的冲突/落差有三处，都值得记下来：

| 项 | 论文/文档侧 | 代码侧 |
| --- | --- | --- |
| `effect` 签名 | 多篇二手解读写成 `effect(acquire, release)` 两个参数 | 源码是 `effect(execute, label?)`——**一个回调**，撤销函数由回调返回或 `yield` |
| `waterfall` 是否等异步 | 部分文档表述含糊 | 源码 `waterfall` 非 `async`，返回 `next()` 的结果，**调用方自己 await** |
| 派发模式数量 | primer/教程列五种，framework/events 页只列四种（无 `parallel`） | 源码五个方法都在 |

第二条尤其值得警惕：`isBailed(Promise)` 恒为真，`waterfall` 监听器里少写一个 `await next()`，就会把一个未落定的 Promise 当成"真值"传下去，而**没有任何报错**。这正好是第 5 节要讲的"坑"的典型形态——不是机制错了，是契约没写进类型。

论文里唯一经得起对照、也确实有价值的是 **Theorem 80（Confluence）**：无论以什么顺序装卸，系统静止在一个规范状态。这条在第 2.6 节已经用过，也是本文唯一按论文原文采信的实质性结论。

**对读者的建议**：读这篇论文时，把它当成"一份写给审稿人的、关于一个已上线系统的理想化描述"，而不是"一份可以用来预测系统行为的规格"。它证明的是**在没有 bug、没有异步竞态、没有第三方插件违规的理想模型下**系统应该怎样；而真实行为在源码里。

## 4. 加东西的两种加法

第 2 节把 Cordis 的核心还原成了一个栈。但 Cordis 对外提供的远不止一个栈——五个事件方法、一套配置系统、一套服务查找机制。

于是有一个绕不开的问题：**这些东西该不该有？**

直觉的回答是"太多了"。但这个回答没有区分力，因为有的多是必要的，有的多不是。区分的办法是看它们怎么长出来的。

软件里加东西只有两种加法：

- **收窄**：在已有的东西上加一条限制，得到它的一个特例。就像"正方形"是"矩形"加一条限制（四边相等）——**正方形是矩形的一种**，矩形还在，你随时可以直接用矩形。
- **铺开**：把各种用法并列，每项一个名字。就像一把水果刀，按切的对象（水果）不一样，分成苹果刀、梨刀、桃子刀，做成了三把刀——一把刀本来够用，被拆成了三把。

**只有第一种多了"一层"(继承)。第二种只是把同一个东西的几种用法提前固化成了几个名字。**

### 4.1 先看收窄的样子

第 0 节介绍过的 tool-func 系列，就是一条靠收窄长出来的链，每层是下层的一个特例。从下往上：

```typescript
// ① ToolFunc：自描述、自管理的函数工具集
new ToolFunc({ name: 'ping', func: () => 'pong' }).register()

// ② ServerTools：单个可远程调用的函数
new ServerTools({ name: 'ping', func: () => 'pong' }).register()

// ③ RpcMethodsServerTool：把相关方法组织成一个服务对象
const users = new RpcMethodsServerTool({ name: 'users' })
users.$createUser = async ({ name }) => { /* ... */ }   // $ 前缀 = 自动注册为 RPC 方法
// 客户端调用时传 act: '$createUser'

// ④ ResServerTools：映射标准 REST 动词
class Users extends ResServerTools {
  async get({ id })   { /* ... */ }
  async list()        { /* ... */ }
  async post({ val }) { /* ... */ }
}
// GET  /users/:id → get({ id })
// GET  /users     → list()
// POST /users     → post({ val })

// ⑤ tool-event：把实时事件当作"另一种工具"
await eventClient.subscribe('server-time')   // 订阅本身就是一次 RPC 调用
EventServer.setPubSubTransport(new SseServerPubSubTransport())  // 唯一的全新抽象
```

每往上一层，就多一层限制：

| 层 | 新增限制 | 丢掉的自由度 | 换来什么 |
| --- | --- | --- | --- |
| ToolFunc | 要有名字、进注册表 | 匿名函数、临时闭包 | 可被发现、可被别人调用 |
| ServerTools | 要能跨网络 | 闭包、外部变量、`this` | 远端能调 |
| RpcMethodsServerTool | 方法要 `$` 前缀、扁平 | 任意嵌套的 API 形状 | 一组相关操作有组织 |
| ResServerTools | 预置 `get`/`list`/`post`/`put`/`delete` 五个方法 + `id` 路由 | 任意方法名（`$` 前缀仍可挂自定义方法，不是被限制死） | CRUD 一行路由都不用写 |
| tool-event | 从本地事件总线，到远程事件，控制面必须走 RPC、要 transport | 裸事件总线 | 复用整个 RPC 生态：发现、代理、传输 |

三个特征让这条链成立：

1. **上层是下层的一种**：每层都是下面那层加限制得到的特例，是一条线，不是一堆
2. **选择发生在声明处**：定义这个 tool 时选一次，且**按对象**——`/users` 用 `ResServerTools`，`/ping` 用 `ServerTools`，同一个进程里混着用
3. **可绕过**：你不用 REST 语义，就根本不 `import` 它，下面那层永远对你开着

`tool-event` 是这条链上最克制的一环。Pub/Sub 本身是个完整范式（订阅、广播、双工、断线重连），它没有发明新模型，而是把控制面（`subscribe`/`unsubscribe`/`publish`）映射回标准 RPC 调用，复用 `tool-rpc` 已有的发现、代理、传输生态；**唯一的新抽象**是数据面的一个可插拔 transport。

新增的概念数是 **1**。

### 4.2 再看 Cordis 的五个事件方法

Cordis 的事件系统有两头。一头是**注册监听**：

```typescript
ctx.on('message', handler)   // "有人发消息时叫我"
```

另一头是**派发**（也就是触发这个事件）：

```typescript
ctx.emit('message', session)   // "现在有人发消息了，都起来干活"
```

派发这一头有五个方法：

```typescript
ctx.emit(name, ...args)       // 广播。返回值既不 await 也不收集
await ctx.parallel(...)       // 并发执行，等全部完成
await ctx.serial(...)         // 串行执行，第一个非空返回值即停
ctx.bail(...)                 // serial 的同步版本
await ctx.waterfall(...)      // 环绕中间件，可包装、可短路
```

| 模式 | 等异步? | 监听器的返回值给你吗? | 顺序 | 短路 |
| --- | --- | --- | --- | --- |
| emit | 否 | **不给** | 注册序 | 否 |
| parallel | 是 | 不给（只留错误） | 并发 | 否 |
| serial | 是 | 给 | 注册序 | 是 |
| bail | 否 | 给 | 注册序 | 是 |
| waterfall | **否**（见下） | 给 | 注册序 | 是（不调 `next`） |

（表格依据：`packages/core/src/events.ts` 源码；文档侧见 [Cordis Primer · Dispatch Modes](https://deepseek-harness.github.io/deepseek-harness/en/reference/cordis-primer) 与[教程第 4 章 Events](https://deepseek-harness.github.io/deepseek-harness/en/develop/cordis-tutorial/04-events)）

**`waterfall` 那一行是本次核实改掉的一处**：官方 primer 的 Awaited 列标的是 **No**，源码也证实 `waterfall` 不是 `async`，它把 `next()` 的结果直接 `return` 出去——监听器若是 async，返回的就是个 Promise，**由调用方自己 await**，框架不替你等。文档侧三份材料本身也不完全一致（primer 与教程列五种模式，framework/events 页只列四种、没有 `parallel`）。这类冲突一律以源码为准。

五个方法的源码，全部列在这里，因为它们值得逐行看：

```typescript
emit(...args) {                                    // 同步循环，无 try/catch
  const [thisArg, callbacks] = this._resolve('emit', args)
  for (const callback of callbacks) Reflect.apply(callback, thisArg, args)
}

async parallel(...args) {
  const results = await Promise.allSettled(callbacks.map(cb => Reflect.apply(cb, thisArg, args)))
  const errors = results.filter(r => r.status === 'rejected')
  if (errors.length) throw new AggregateError(errors.map(e => e.reason))   // 值全丢，只留错误
}

async serial(...args) {
  for (const callback of callbacks) {
    const result = await Reflect.apply(callback, thisArg, args)
    if (isBailed(result)) return result            // 第一个真值胜出并短路
  }
}

bail(...args) {                                    // serial 的同步版
  for (const callback of callbacks) {
    const result = Reflect.apply(callback, thisArg, args)
    if (isBailed(result)) return result
  }
}

waterfall(...args) {                               // 非 async
  const inner = args.pop()                         // 最后一个参数是最内层默认行为
  const next = () => {
    const callback = callbacks.shift()
    return callback ? Reflect.apply(callback, thisArg, args) : inner(...args)
  }
  args.push(next)
  return next()
}
```

`isBailed` 的定义是 `v !== null && v !== false && v !== undefined`——这就是"返回值算不算数"的全部判据。

把它们按"是不是对方的限制版本"排一下：

```
waterfall        ← 限制最多（环绕包装）
  ↑
serial ──── bail ← bail 就是 serial 去掉 await
  ↑
emit             ← 限制最少（什么都不收集）

parallel（并发，与上面不可比）
```

- `emit` ⊂ `serial`（serial = emit + 收集返回值 + 短路）
- `serial` ⊂ `waterfall`（waterfall 里写 `if (own) return; return next()` 就精确等于 serial）
- `bail` = `serial` **去掉 await**，是反向限制
- `parallel` 与其余**不可比**——真并发是正交的

（这里按源码补一句限定：`waterfall` 是"可表达 serial"，不是"包含 serial"。`serial` 会逐个 `await`；`waterfall` 里要自己 `await next()`。少写那个 `await`，拿到的就是 Promise 而不是值，而 `isBailed(Promise)` 恒为真——一个未 await 的 Promise 会被当成"真值"继续往下传。）

**`emit → serial → waterfall` 这一段确实是收窄，但整体不是**：`bail` 是 `serial` 去掉一条限制，`parallel` 根本不在这条线上。

五个方法的共同点是另一件事——**它们是同一个"派发"能力被切成的五种用法**，不是五种东西。这是铺开。

这张菜单上有两处说不通的地方，说明它不是推导出来的：

- `serial` 和 `bail` **只差一个 await**，却占了两个方法名（源码里就是同一段循环加不加 `await` 的差别）
- `parallel` 用了 `Promise.allSettled` 却把值全丢了，只留错误（源码里 `results` 只被用于 filter rejected）——**并发又想拿返回值，在这个框架里没有出路**。这一条此前是推断，现已由源码坐实。

### 4.3 `emit` 既是地基，又是五个方法之一

Cordis 事件系统**最底下那个方法是 `ctx.emit`**。它本该是中性的——一个纯粹的"把事件交给监听器"的动作，不带任何用法倾向。

但 `emit` 不是中性的，它自己就是五种用法里的一种：**广播，返回值一律丢弃**。官方文档的原话是 returned promises and values are **not awaited or collected**（既不等待，也不收集）。

拿"监听器的返回值你拿得到吗"给五个方法排序：

| 方法 | 监听器的返回值，你拿得到吗 |
| --- | --- |
| `emit` | 拿不到（连等都不等） |
| `parallel` | 只告诉你有没有出错 |
| `serial` / `bail` | 拿到第一个非空的结果，后面的监听器不再执行 |
| `waterfall` | 全部拿到，还能一层层改掉 |

`emit` 排在最后一名。

现在反过来设想：假如 `emit` 改成"把每个监听器的返回值收成一个数组返回"（[events-ex](https://github.com/snowyu/events-ex.js) 就是这么做的："The emit return the result of listeners's callback function"），会怎么样？

```typescript
const isBailed = v => v !== null && v !== false && v !== undefined   // Cordis 自己的定义

// 想要 serial 的效果？一行就能写出来
const serial = (n, ...a) => ee.emit(n, ...a).find(isBailed)
```

`serial` 和 `bail` 会立刻退化成"你那一行代码怎么写"的事——想加就加，想改就改，想扔就扔，每个项目还能按自己的习惯定制。

（**能退化的只有这两个。** `waterfall` 的环绕语义需要 `next()` continuation，返回值数组表达不了；`parallel` 的真并发是正交维度，也表达不了。所以"五个里最核心的两个会消失"成立，"五个全部会消失"不成立。）

但 Cordis 的 `emit` 不给。地基省掉的这一点，上面就得长出五个方法来补上。

对照 4.1 那条链就能看清差别：`ToolFunc` 不预设这个工具跑在本地还是远端，所以 `tool-rpc` 能从它上面长出来。假如 `ToolFunc` 从一开始就写死"只能在本地调用"，`tool-rpc` 根本不可能存在——**Cordis 的 `emit` 就是这个处境。**

由此得到一条可以用来审查任何 API 的判据：

> **最底下那层，不能是它自己某个用法。** 是，就说明上面只能顺着这个用法长，长不出别的东西。

- `ToolFunc` 不是 `ServerTools` 的某种用法 → 中立 ✓
- events-ex 的 `emit`（返回全部返回值）不是任何派发策略的某种用法 → 中立 ✓
- Cordis 的 `emit` = 五个方法之一 → **地基上刻了用法** ✗

同一个病在别处也犯过：MCP 把工具返回结果文本化，见 3.4。

### 4.4 API 一旦公开发布，就收不回来

把五个方法降级成 helper，能不能绕开这个问题？

加容易，收难。这不是审美判断，是有名字的规律——**Hyrum's Law**（Hyrum Wright，Google，[hyrumslaw.com](https://www.hyrumslaw.com/)）：

> 当一个 API 有了足够多的使用者，**你在契约里承诺什么已经不重要了**：你系统的**所有可观测行为**都会被某个人依赖。

文档契约是你**希望自己有的**契约；**被观测到的行为才是你真正拥有的**契约。返回的列表碰巧是插入序？有人断言了这个顺序。错误信息里某个词？有人 grep 它来决定是否重试。

**所以收回的成本不是线性的——每个方法都在积累看不见的依赖。** 五种模式被大量插件使用（Koishi 侧 4000+ 是论文口径），任何收敛动作的成本都随依赖者数量上升，且**没有公开材料表明官方有过收敛计划**——这一条靠"使用规模"论证就够了，不需要替它假设一个动机。

配套的两条原则，一起构成完整的立场：

- **Rule of Least Power**（W3C TAG Finding，2006-02-23；Editors 为 Tim Berners-Lee 与 Noah Mendelsohn，[原文](https://www.w3.org/2001/tag/doc/leastPower-2006-2-13.html)）：*Powerful languages inhibit information reuse... the less powerful the language, the more you can do with the data.* 底层原语越弱，能被越多场景复用。
- **Mechanism, not Policy**（X Window 设计原则，见《Unix 编程艺术》第 1 章）：*policy tends to have a short lifetime, mechanism a long one.* 策略短命，机制长命。把策略焊进长命的层里，等于把短命的东西放进了不该放的地方。

**这套论证的结论恰恰就是"少即是美"——只是"少"的度量单位是单个单元的职责，不是单元的数量。**

4.1 那条链有三个包、五个类，总数并不少，可没人抱怨它臃肿，因为**每个单元内部都少**：`tool-func` 只管注册表，`tool-rpc` 只管传输，`tool-event` 只管事件；往下看每个类也是一样，`ToolFunc` 只管自描述，`ServerTools` 只管远程调用，`ResServerTools` 只管五个 REST 动词。数量在往上加，每个单元的职责没有变胖——**这就是"少即是美"，而且是它唯一成立的形式。**

Cordis 的问题同样不在"五个方法"这个数量上，而在**每个方法都不是最简的形态，且无法绕过**：`emit` 身上刻着一种具体用法，`serial` 与 `bail` 只差一个 `await` 却占着两个名字，`parallel` 想拿返回值没有出路。判据仍是三条：**是不是收窄、是不是在声明处选、能不能绕过**。Cordis 违反的是第一条（是铺开）和第三条（`emit` 不给返回值，绕过去也重建不了）。

## 5. 坑

先分清两个词：

- **坑：误导或静默失效。** 按常理预期写代码，结果不对，过程中没有报错。
- **成本：交换。** 得到什么、付出什么；有的当场付清，有的长期承担。

第 3 节的滥造词是坑（词面误导）。下面五条也是坑。

有一类东西常被算成坑，其实不是：**每个插件都要写的固定格式**（插件名、`apply` 入口、工具的说明和参数表）。它不会误导你，也不静默失效，你写的时候就知道自己在写什么。它是**成本**——用"框架替你管理装卸"换来的。第 7 节单独算这笔账。

### 坑一：没有故障隔离

所有插件跑在同一个 Node.js 进程里，共享内存和事件循环：一个插件死循环，整个进程卡死；一个插件泄漏，整个进程内存增长；不能单独部署、单独伸缩。

**它隔离的只有生命周期**——整体装上、整体拆下、拆下时清理干净。

定位：不是微服务（无独立进程和故障域），不是浏览器扩展（无沙箱），最接近**操作系统的可加载内核模块**——可以动态装卸，但装载后与内核共享地址空间和特权级，模块里的 bug 同样能让整个系统崩溃。

DSH 官方自己把这条写进了对照表：插件的"Sandboxed by default"一栏是 **No — runs as trusted code**（相比之下 MCP server 是外部进程，有 stdio/http 边界）。

### 坑二：拦截是否生效，取决于别人那一行派发代码

这是 4.3 那个结构问题的具体后果。

**事件怎么被派发，由派发那一行的代码决定，与你怎么写监听器无关。**

写 `ctx.on('message', listener)` 时，你无法声明"我这个监听器要拦截消息"。你的返回值被如何对待，取决于**别人**在派发这个事件时调用了五个方法里的哪一个——`emit` 丢弃、`parallel` 只留错误、`serial`/`bail` 取第一个真值、`waterfall` 全部收集。

**完整看一次失效。** 黑名单插件，想拦截被禁用户的消息：

```typescript
// 插件 A：黑名单
export function apply(ctx: Context) {
  ctx.on('message', (session) => {
    if (banned.has(session.userId)) {
      return true     // 意图：返回 true 表示"拦截"
    }
  })
}
```

而框架内部分发这个事件用的是 `emit`：

```typescript
ctx.emit('message', session)   // emit：逐个调用监听器，返回值全部丢弃
```

接下来逐步发生什么：

1. 被禁用户发了一条消息
2. 框架调用 `emit` → 你的监听器被调用，执行到 `return true`
3. **这个 `true` 在这里被丢弃**——`emit` 的语义就是广播，不消费返回值
4. 下一个监听器（比如自动回复插件）照常被调用、照常运行
5. bot 回复了被禁用户

**全程没有任何报错。** TypeScript 编译通过（回调多返回一个值，类型上合法）；运行通过（监听器确实执行了）；单测甚至通过（"监听器被调用"这个断言是真的）。只有端到端行为不对：黑名单没生效。

失效发生在第 3 步——返回值被丢弃的那一刻，那里没有一行日志、一个警告。

要真正拦截，派发处必须换成 `bail`：

```typescript
ctx.bail('message', session)   // 监听器返回真值时，后续监听器不再调用
```

**病灶到这里才暴露**：你写了 `return true`，但决定这个返回值命运的是框架或另一个插件在别处选了五个方法中的哪一个。读你自己的插件代码看不出来，要去翻派发处的源码。

> **选择权和后果被拆在两个地方，而承受后果的一方看不见那个决定。**

DSH 已经部分修复了这个问题：官方 primer 写明"dispatch mode is **part of the event's public contract**"，新事件用 `@mode` 标签标注，生成的目录会**比对声明与派发点**。

但它是**工具层契约，不是类型层契约**：`interface Events` 的声明合并里只有监听器签名，没有 mode。写错 mode 不会被 `tsc` 拦住，只在生成的目录对不上时被发现。

而底层的结构问题没变：地基 `emit` 依然丢弃返回值，所以"绕过去自己实现"这条路仍然不通。

**还有一个具体伤害**：`emit` 不 `await`。异步监听器如果 reject，**这个 rejection 没有任何人接收**——同步抛错至少会传播并中断后续，异步的会变成 unhandled rejection。

### 坑三：贯穿插件存活期的资源，要自己包一层

先看签名（这次是源码里的）：`effect(execute, label?)` **只有一个回调**，它返回的是 disposer，不是资源。所以资源本体要自己保存——这就是摩擦的源头。

按源码把两类情况分开看，会发现**只有一类是真问题**：

- **acquire 是异步的：不成问题。** 有 `effect(execute: () => Effect, label?): AsyncDisposable` 这个重载，`_execute` 里有 Promise 分支，fiber 用 inertia 等它落地。所以 `ctx.effect(async () => { const p = await openPool(); await p.connect(); return () => p.close() })` 可以直接写。（不像 React 的 `useEffect` 那样禁止 async——那是 React 的选择，不是这类机制的必然。）
- **没有本体：这才是真问题。** `setup()` 做的事是把服务注册进注册表等着被查，dispose 撤销的是一段注册，不是关一个返回值。此外还有第三类：**获取本体与持有本体要分两步**（先 `openPool()` 拿到池，业务代码要用它，disposer 也要引用它）。

后两类在插件整个存活期都要在，于是只能靠闭包传递：

```typescript
let pool: Pool
ctx.effect(() => { pool = openPool(); return () => pool.close() })
// pool 的声明、effect 的注册、使用 pool 的业务代码，位置互相牵制；资源一多，交错成网
```

"没有本体"这一类有现成答案——**生成器形式**：

```typescript
ctx.effect(function* () {
  store.set(id, provider)        // 获取：写注册表
  yield () => store.delete(id)   // 释放：yield 给运行时，立即被收集
}, 'web.registerProvider()')
```

DSH 自己的 `registerSearchProvider` 就是这么写的。`fiber.ts` 里的 `Symbol.iterator` 分支把生成器**立即驱动到底**，每个 `yield` 值随即 `safeCollect`。所以"有获取无本体"不是签名缺陷，而是生成器形式的用途。

剩下的是封装问题。成熟的解法是加一层，把跨存活期的状态圈进一个有 setup/dispose 的单元：

```typescript
const db = (() => {
  let pool: Pool
  return {
    async setup()       { pool = openPool(); await pool.connect() },
    dispose()           { pool.close() },
    query(sql: string)  { return pool.query(sql) },
  }
})()
ctx.effect(() => db.setup().then(() => () => db.dispose()))
// 业务代码只面对 db.query()，交错消失
```

资源种类多就提基类，各生态都收敛到这个形态（Koishi 的 `Service`、RxJS 的 `Disposable`、Effect-TS 的 `Scope`）。

所以这个坑没那么严重：它不是"签名装不下"，而是"单回调签名不替你保管本体"——

- **难写是签名选择的代价**：把 acquire/release 合进一个回调，换来了可 `yield` 多次和可诊断 label，代价是本体要自己保存
- **好写是封装层面的可得**：IIFE 或基类，一次封装全队复用

还有第三条路：把生命周期单元切得更细——每个资源自己就是一个带 setup/dispose 的条目，依赖交给依赖图，封装摩擦在更细的粒度上自然消失。代价记在账单二。

> 按论文或文档层面的理解（`effect` 装 acquire + release）去推导，会得出"异步资源装不下"这个错误结论；读 `fiber.ts` 才知道异步那一路早就有了。

### 坑四：没有远程方案

`ctx.database` 永远是进程内对象，没有传输层抽象。不能把服务透明地换成远程实现，也不能同一服务有时本地跑、有时独立部署。

对照 `tool-rpc`：它用"注册表同名代理"做到本地/远程透明——业务代码不改，注册时决定这个 tool 跑在本地还是远端。需要这种弹性的场景，Cordis 只覆盖本地一半。

### 坑五："插件"一词的歧义

Cordis/Koishi 的"插件"是**后端服务单元**，不是浏览器扩展、VS Code 扩展那种带界面的东西。

判别式不在界面，在**运行时可加载、向宿主暴露标准接口、可独立分发**。但日常语境里"插件"强烈暗示前者——**每次有新成员加入、或和别的团队协作**，都要先确认对方说的是哪一种，这个成本反复发生。给自己的项目立个命名约定（后端的叫 Service / ServicePlugin）能省下这笔成本。

## 6. 亮点

一句话：**一个 effect 原语，加一条"全部副作用 API 都走它"的规范。**

原语本身第 2 节讲过了，规范才是它真正值钱的地方。

框架里每一个会产生副作用的 API——注册命令、添加监听、挂载服务、起定时器——不管名字叫什么，内部实现都是同一件事：执行获取、把返回值和清理函数成对入栈。类比文件操作：`read`、`write`、`append` 表面上是三个功能，本质都是"打开-使用-关闭"。

### 6.1 这条规范为什么不是可选项

第 2 节的五条边界划出了机制的管辖范围：**管住的东西自动正确，没管住的东西彻底没人管，没有中间地带。** 裸写的资源静默泄漏，倒序注册静默错序——框架不清理，也不报错。

所以"全部副作用 API 无一例外走原语"不是风格偏好，是机制能工作的前提。

### 6.2 回报在哪

**只要原语正确（清理必执行、LIFO），全部 API 的卸载行为自动正确。**

查问题只需要查一个原语；新增 API 只要走了原语，自动继承正确性。C++ 的 RAII 也是如此——机制一行讲得完，价值在于整个类型系统无一例外地执行它。

亮点不等于不可替代——这条规范谁都能抄走，抄走的代价在第 8 节算。

## 7. 成本：每个插件要写的固定格式

第 5 节把"坑"和"成本"分开了：坑是误导，成本是交换。现在算第一笔成本，也是唯一一笔**写第一行代码时就能看清**的。

工具要让别人调用，就必须描述自己。这不是 Cordis 的特殊要求——任何提供发现和校验的注册表，都要求三样东西：**名字、说明、参数形状**。OpenAI 的 function calling、MCP、JSON Schema 表单，最后都收敛到这三样。

**调用方看不见的工具，无法被调用。**

同一件事的两种写法。`ToolFunc`：

```typescript
new ToolFunc({
  name: 'get_weather',
  func: async ({ city }) => {
    const res = await fetch(`https://api.weather.com/${city}`)
    return res.json()
  },
  params: { city: { type: 'string' } },   // 可选
  result: { type: 'object' },             // 可选
}).register()
```

写成 DSH 插件（**按官方当前形态**，不是我编的写法）：

```typescript
import type { Context } from '@deepseek-ai/cordis'
import { defineTool } from '@deepseek-ai/dsh-tools'

export const name = 'weather'            // ① 插件身份（用于诊断）
export const inject = ['tools']          // ② 依赖声明（框架据此决定加载顺序）
export function apply(ctx: Context) {    // ③ 唯一入口
  ctx.tools.register(defineTool({
    name: 'get_weather',                 // ④ 工具名
    description: '查询城市天气',          // ⑤ 说明
    parameters: {                        // ⑥ 参数形状
      city: { type: 'string', required: true, description: '城市名' },
    },
    async execute({ city }) {            // ⑦ 业务
      const res = await fetch(`https://api.weather.com/${city}`)
      return res.json()
    },
  }))
}
```

十九行，业务两行。多出来的每一行，各自服务于哪个调用方：

| 行 | 内容 | 服务的调用方 |
| --- | --- | --- |
| ① | 插件名 | 框架：诊断、日志归因、按名定位 |
| ② | `inject` 依赖声明 | 框架：等依赖就绪才执行 apply——**加载顺序由它决定，不由文件顺序决定** |
| ③ | apply 入口 | 框架：整体装上、整体拆下 |
| ④ | 工具名 | 代码、LLM：在工具列表里发现它 |
| ⑤ | 说明文字 | LLM：判断何时调用——没有这行，工具对 LLM 不存在 |
| ⑥ | 参数形状 | LLM：正确传参；框架：校验 |
| ⑦ | `execute` | 业务本身 |

**`inject` 这一行容易被当成元数据漏掉**，它不是：它是第 2.4 节那套依赖机制在插件上的落点——声明了 `['tools']`，框架就保证 `apply` 跑起来时 `ctx.tools` 一定在；不声明就访问，Proxy 会直接抛 `INACTIVE_ACCESS`。它同时也是一份**可审查的能力清单**：静态声明了，编排者才能在插件运行前审一遍它到底要了什么。所以这一档的成本比看上去更高，换来的东西也更多。

**所以差异只在调用：调用方是谁，决定描述写到哪一档。**

- 代码按名调用：`name` + `func` 就够——`ToolFunc` 的最小形态
- LLM 或人调用：再加说明和参数形状——`ToolFunc` 写上 `params` / `result` 即可
- 框架装卸：再加入口结构（name / inject / apply）——只有 DSH 这一档提供

**进程是否长期运行，决定第三档是否必要**：一个插件、重启无所谓时，装卸能力没有意义；五十个插件 7×24 运行时，重启一次等于全体下线一次，装卸变成必需。

选择因此还原为两个问题：**调用方是谁、进程要不要长期跑。** 这里没有对错，只有匹配。

## 8. 账：两张账单

成本是当场付清的，写的时候就知道。账不一样——它要在真实环境用下去才开始显现，而且**利滚利**。

### 8.1 账单一：用 Cordis

| 账目 | 何时发生 | 代价 |
| --- | --- | --- |
| API 无法收回 | 想改五种事件模式 / Schema / 声明合并中任何一个 | 永久——插件越多越收不回（Hyrum's Law，见 4.4）。**注**：这一条按"使用规模"论证即可，不必假设官方有过收敛计划——没有公开材料表明 4.0 想收敛 |
| rc 迁移 | 上游当前 4.0.0-rc.10（2026-09-08），API 未冻结；仓库 README 明写"may change without notice" | 每次 rc 更新，全量回归；且 rc 之间就有不兼容变更（如 rc.10 把 `EntryTree.write()` 换成 `commit(change)`） |
| **版本被 vendored 锁定** | 走 DSH 时 | DSH vendor 的是 **4.0.0-rc.7**，落后上游三个 rc。上游修掉的 bug（如 waterfall 重复 `next()` 的守卫、fiber 失败未处理）在 DSH 里不一定有，反之 DSH 的加固上游也没有——**两条线各自漂移**，读文档对不上代码时要先确认自己看的是哪一份 |
| 单进程故障 | 任一插件死循环或泄漏 | 全进程停机；用重启兜底，则放弃"不重启"的卖点 |
| 拆分重构 | 哪天要把某个服务挪出进程 | 重写所有 `ctx.database` 直连调用，随插件数线性增长 |
| 术语误解 | 每个新成员入职 | 每人一次"回滚不是回滚"的澄清，此后沟通中反复发生 |
| 工具描述 | 每写一个新插件 | DSH 十九行起步，约十七行是描述与入口（第 7 节）；按调用方可减 |
| 资源封装 | 每个"无本体"或"获取/交出分两步"的资源 | 一次 IIFE 或基类封装；"无本体"那类用生成器形式即可（坑三） |
| 异步清理 | 每个有异步 disposer 的插件 | 半卸载窗口存在，需手动合并清理链（边界四） |
| `waterfall` 的 await | 每个写环绕中间件的插件 | 少写 `await next()`，`isBailed(Promise)` 恒真，把未落定的 Promise 当真值传下去，**不报错**（3.5 / 4.2） |
| 退出成本 | 决定离开那天 | 与停留时长成正比，所有写过 `ctx.*` 的代码都要重写 |

### 8.2 账单二：自己组合

思路接近 Unix 哲学：组件小、职责单一，通过组合完成系统。

**用什么：**

- `tool-func`（[isdk/tool-func.js](https://github.com/isdk/tool-func.js)）：注册表与生命周期
- `tool-rpc`（[isdk/tool-rpc.js](https://github.com/isdk/tool-rpc.js)）：本地/远程透明，注册表同名代理，业务代码不改
- `tool-event`（[isdk/tool-event.js](https://github.com/isdk/tool-event.js)）：事件与控制面映射回 RPC，唯一新抽象是可插拔 transport
- `events-ex`（[snowyu/events-ex.js](https://github.com/snowyu/events-ex.js)）：事件，控制流在监听器手里（`emit` 返回监听器结果）
- `custom-ability`（[snowyu/custom-ability.js](https://github.com/snowyu/custom-ability.js)）：能力注入，可摘除
- 自己写约 200 行：effect 栈 + 依赖传播 + JSON Schema 配置层

**缺什么：**

| 账目 | 何时发生 | 代价 |
| --- | --- | --- |
| 维护 | 永久 | 约 300 行 + 6 个包；维护者是你 |
| 装卸记录 | 从第一次装卸开始 | 每次卸载后检查残留（见下） |
| 纪律 | 每次新增会副作用的 API | 没有框架强制，靠 review 和守卫测试；漏一次就是一个泄漏 |
| 能力缺口 | 需要嵌套作用域（会话级批量清理） | context 树已替换为扁平注册表，要自己实现 |
| 粒度代价 | 设计阶段 | 原本内聚的东西拆成多个条目，互相调用要走注册表——拆对了是解耦，拆错了要合回去 |
| Koishi 插件适配 | 想用 Koishi 插件时 | 每个要用的插件都是一次独立适配 |

**下面三笔，是"自己组合"最容易低估的部分：**

**① 规范的覆盖。** 第 6 节那条"凡会副作用的 API 都走原语"，在 Cordis 里覆盖的是整个框架的 API 面——几百个公开 API 内部都走 effect，插件作者随便调哪个，副作用都自动进栈。

这是个**代码事实，只能读框架源码验证**。4000+ 插件证明的是生态规模，证明不了它——插件多说明 API 被大量使用，不说明每个 API 内部都走了原语。

自建体系的规范只覆盖三百行，写下来就覆盖到了。这条差别的实质是：**规范的成本随 API 面增长**。你的代码长到那个规模之前，这条差别不存在；长到之后，规范要跟着覆盖每一个新 API。

**② 装卸记录，且要按正确的变量度量。** "三年不重启"经常被当作可靠证据，但它**混合了两个变量**：

- 运行时长检验**进程稳定性**（低负载空转跑三年，门槛很低）
- 装卸次数检验的才是 **effect 机制**——每次卸载是一次栈弹出，有没有残留只在卸载后可见；插件从不卸载的进程，机制的执行记录为零

而且"三年不重启"本身有两种相反解读：升级都走了装卸循环所以不用重启（机制被反复检验），或者根本没有装卸需求（机制从未被检验）。没有装卸次数的数据，这两种情况区分不开。

> **考察记录的正确问题是"装卸了多少次、每次卸载后有没有残留"，不是"跑了多久"。**

**③ 嵌套作用域。** Cordis 的 context 是嵌套树，子作用域销毁时级联清理。`tool-func` 路线把它替换为扁平注册表——适配小体系的选择；将来需要"一个会话一个作用域、会话结束批量清理"，要自己实现。

**关于 Koishi 插件适配**，还有一笔反向的账：Koishi 插件的全部耦合面是 `apply(ctx, config)` 里那个 ctx——实现一个替身 ctx，提供 `command` / `on` / `model` 这些高频接口，头部插件零改动就能跑。适配把"生态不兼容"从架构问题变成了工程量问题。

但你实现的 ctx 表面越全，你的体系就越在向 Cordis 的一个子集收敛。① 那条"规范的成本随 API 面增长"会换个形式重新出现——**你不是在用 Cordis，你是在维护一个 Cordis 兼容层。**

渐进地做：先适配三件套，跑通最流行的十几个，长尾按需补。

**合起来说**：机制可以替换（几十行），规范必须自己覆盖（随 API 面增长），记录必须用装卸次数积累（不是运行时长）。

## 9. 判断清单

**用它**（三条要同时成立，其中第一条是可判定的门槛）：

1. **生态复用量够大**——你预期要直接用的现成插件（Koishi 的或 DSH 的）有个二三十个往上。少于这个数，"现成生态"这条理由就不成立：DSH 官方没有插件中心，discovery 只能靠 GitHub topic 搜，插件质量与兼容性没有背书，你自己适配的成本会超过自己写的成本。
2. 进程长期跑不重启，可清理的副作用是刚需。
3. 单体，无跨进程诉求（或者你接受未来拆分时重写直连调用）。

**别用**：要故障隔离或独立部署；插件少、进程不需要长期运行，第 7 节第一档的描述就够；要本地/远程透明；在意分层纪律或在自建体系。

**中间路线**：借它的**不变量**（凡获取必回收、依赖变更必传播、校验先于销毁），不借它的 API，保留 adapter 路线，需要时把 Koishi 插件适配进来。

**无论选哪条，先做一件事**：确认你要读的是哪份代码——上游 `cordiverse/cordis`（当前 4.0.0-rc.10）还是 DSH 的 `vendor/cordis`（pin 在 rc.7）。两者不等价，文档站的描述对的是 DSH 里那份。

---

## 收尾：方法比结论重要

遇到任何框架，按顺序做五件事：

1. **先找到代码，再找论文和文档。** 有仓库就先读源码入口（这里是 `packages/core/src/` 九个文件），论文和文档站留到第二步。冲突时以代码为准——尤其当论文晚于代码出现时，它是事后说明书，不是规格。
2. **把名词逐个还原成机制。** "逆序回放"还原成 `pop()`，"时空可组合性"还原成作用域、析构顺序和依赖图，"上下文工程"还原成提示词工程，MCP 还原成 OpenAPI 加发现端点。
3. **分清坑和成本。** 坑是误导（按常理写却静默失效），成本是交换（得到什么、付出什么）。
4. **看它是怎么长出来的。** 是收窄，还是铺开？选择发生在声明处还是派发处？最底下那层是不是它自己的某个用法？
5. **最后算账，再决定。**

而第 4 节给出的是可以拿走、用在别处的那条判据：

> **最底下那层，不能是它自己某个用法。**
> **能用一个原语表达出来的东西，写成 helper 是可撤销的，挂在核心对象上不可撤销。**

再补两条这次核实顺带得到的：

> **论文晚于代码出现时，论文是说明书，不是规格。** 用它查"它声称保证什么"，用代码查"是否真的成立"。
> **契约没写进类型，就等于没有契约。** `emit` 丢弃返回值、派发模式影响拦截、`waterfall` 要自己 `await`——三条都是类型层看不见、运行层不报错的坑。用 `interface Events` 的声明合并只能约束监听器签名，约束不了 mode。

坑是文档、API 语义和原语边界里留下的；账是在真实使用中承担的。看清机制再做选择，仅此而已。

---

## 参考链接

**源码（本文的判据来源，优先于文档与论文）**

- cordis 核心源码目录：`packages/core/src/`（context.ts / events.ts / fiber.ts / registry.ts / service.ts / reflect.ts / utils.ts / logger.ts / index.ts）
- events.ts（五个派发方法的实现）：<https://github.com/cordiverse/cordis/blob/main/packages/core/src/events.ts>
- fiber.ts（`effect()` 生成器分支、disposer 链、状态机六态）：<https://github.com/cordiverse/cordis/blob/main/packages/core/src/fiber.ts>
- context.ts（`isolate()`）：<https://github.com/cordiverse/cordis/blob/main/packages/core/src/context.ts>
- `@cordisjs/plugin-timer`（`ctx.timeout` / `ctx.interval`，旧名已弃用）：<https://github.com/cordiverse/cordis/tree/main/packages/timer>

**Cordis 与 DSH**

- Cordis 仓库：<https://github.com/cordiverse/cordis>
- 论文《A Programming Paradigm for Spatiotemporal Composability》（arXiv:2608.25512，cs.PL，v1 于 2026-08-26，预印本持续修订中）：<https://arxiv.org/abs/2608.25512>
- 论文仓库：<https://github.com/cordiverse/paper>
- DSH 仓库：<https://github.com/deepseek-ai/deepseek-harness>
- DSH vendor 目录说明（vendored 版本与本地修改清单）：`vendor/README.md`（仓库内）
- Cordis Primer：<https://deepseek-harness.github.io/deepseek-harness/en/reference/cordis-primer>
- Cordis 教程：<https://deepseek-harness.github.io/deepseek-harness/en/develop/cordis-tutorial>
- 教程第 4 章 · Events：<https://deepseek-harness.github.io/deepseek-harness/en/develop/cordis-tutorial/04-events>
- 插件与生命周期（disposer 顺序、fiber.dispose 语义）：<https://deepseek-harness.github.io/deepseek-harness/en/develop/framework/>
- 事件系统：<https://deepseek-harness.github.io/deepseek-harness/en/develop/framework/events>
- 服务与依赖（isolate）：<https://deepseek-harness.github.io/deepseek-harness/en/develop/framework/service>
- 写一个插件（官方 name / inject / apply + defineTool 形态）：<https://deepseek-plugin.org/learn/write-a-plugin>
- 插件对照表与 FAQ（无中心 registry、插件默认不沙箱化）：<https://deepseekai.works/plugins>
- Koishi：<https://github.com/koishijs/koishi>

**tool-func 系列与对照物**

- tool-func.js：<https://github.com/isdk/tool-func.js>
- tool-rpc.js：<https://github.com/isdk/tool-rpc.js>
- tool-event.js：<https://github.com/isdk/tool-event.js>
- events-ex.js：<https://github.com/snowyu/events-ex.js>
- custom-ability.js：<https://github.com/snowyu/custom-ability.js>

**MCP（第 3.3 节）**

- 规范 · Tools：<https://modelcontextprotocol.io/specification/draft/server/tools>
- 2026-07-28 规范修订说明：<https://blog.modelcontextprotocol.io/posts/2026-07-28/>
- 2026-07-28 变更日志（Roots/Sampling/Logging 弃用）：<https://modelcontextprotocol.io/specification/2026-07-28/changelog>

**被引用的原则**

- Hyrum's Law：<https://www.hyrumslaw.com/>
- The Rule of Least Power（W3C TAG）：<https://www.w3.org/2001/tag/doc/leastPower-2006-2-13.html>
- 《The Art of Unix Programming》第 1 章（mechanism, not policy）：<https://book.huihoo.com/the-art-of-unix-programming/ch01s04.html>



--------------------------------------------------------------------------------

# 发到 DSH 仓库

可以，而且方向是对的：**发到你自己的博客时，它可以是一篇完整的“Cordis 的坑与账”；发到 DSH 仓库讨论区时，它不能还是这篇，而要改造成一篇“DSH 底层分层建议 / RFC 讨论帖”。**

核心差异是：

- **博客版**：面向普通读者，需要解释 Cordis 是什么、Koishi 是什么、论文是什么、DSH 是什么、为什么坑、为什么账。
- **DSH 社区版**：读者已经知道 DSH / Cordis / vendor / plugin / harness，不需要背景科普；他们真正关心的是：
  - DSH 能不能更稳定；
  - 插件能不能更可移植；
  - 底层能不能可审计、可替换、可测试；
  - 第三方 runtime / tool 生态能不能接入；
  - 官方 vendor 的 Cordis 能不能不要变成唯一不可拆的底座。

所以你在 DSH 社区上想讨论的建议，不是“Cordis 不好”，而是：

> **DSH 应该把 Cordis 从“唯一内核”降级为“一种可替换实现”，并把真正需要长期稳定的能力拆成清晰分层。**

这个表达比“希望他们对底层合理分层，让更多人都能用，类似 tool-func 的架构”更适合 GitHub 社区。

---

# 1. 在 DSH 社区上，真正值得讨论的建议是什么

你可以围绕下面这条主线提建议：

> DSH 现在把 vendored Cordis 作为插件运行时底座。这个选择有合理性：可审计、可补丁、版本可固定。
> 但如果 DSH 想让更多插件、更多 runtime、更多工具生态接入，应该把“DSH 插件契约”和“Cordis 具体 API”解耦。
> 建议引入一层 DSH runtime capability layer：生命周期、事件、服务、工具、配置、传输各自有稳定接口；Cordis 只是其中一种实现。

换句话说，你不是要求他们“换掉 Cordis”，而是要求他们：

> **把 Cordis 变成 adapter，而不是把 DSH 变成 Cordis 的方言。**

这是 DSH 社区更容易接受的版本。

---

# 2. 你真正想提的建议，可以拆成 6 条

下面这些可以直接作为 DSH Discussion 的议题。

---

## 建议一：把插件契约从 Cordis API 中抽象出来

现在 DSH 插件很可能直接写：

```ts
export function apply(ctx: Context) {
  ctx.tools.register(...)
  ctx.on(...)
  ctx.effect(...)
}
```

这里的问题是：`ctx` 不只是“插件入口”，它同时混着：

- 生命周期；
- 事件系统；
- 服务查找；
- 工具注册；
- 配置系统；
- effect 栈；
- isolate / scope；
- DSH vendor 补丁语义。

插件作者一旦写 `ctx.*`，就和 Cordis 细节绑死了。

### 建议

DSH 可以定义一组更稳定的接口，例如：

```ts
interface DSHPluginContext {
  lifecycle: Lifecycle
  events: EventBus
  services: ServiceRegistry
  tools: ToolRegistry
  config: ConfigStore
}
```

插件不直接依赖 Cordis 的 `Context`，而是依赖 DSH 自己的 runtime contract。

Cordis 可以作为默认实现：

```ts
const ctx = createCordisContext(...)
```

但未来也可以有：

```ts
const ctx = createToolFuncContext(...)
const ctx = createMinimalRuntimeContext(...)
const ctx = createRemoteRuntimeContext(...)
```

### 为什么 DSH 社区会关心

因为 DSH 官方已经明确要把 harness 框架层做成：

- auditable；
- patchable；
- pinned；
- controlled。

那么更进一步的问题是：

> 如果框架层要完全拥有，是否应该由 DSH 定义自己的稳定契约，而不是让所有插件直接依赖 vendored Cordis 的 API 细节？

这是顺着官方动机往下提，不是反对官方。

---

## 建议二：把事件派发模式放进类型契约，而不只是文档约定

你博客里最有价值的一条判断是：

> 插件监听器能不能拦截，取决于派发处用的是 `emit`、`serial`、`bail`、`waterfall`。

这在 DSH 社区里是一个很好的工程问题。

当前问题可以这样描述：

```ts
ctx.on('message', () => true)
ctx.emit('message', session)
```

监听器返回 `true`，但 `emit` 不收集返回值，于是拦截不生效。
类型系统不报错，框架也不警告。

### 建议

DSH 可以把事件模式变成类型层或代码生成层契约。

例如：

```ts
interface DSHEvents {
  message: {
    mode: 'emit' | 'serial' | 'bail' | 'waterfall'
    payload: Message
    returns?: unknown
  }
}
```

或者更保守一点：

```ts
defineEvent('message', {
  mode: 'bail',
  payload: messageSchema,
  returns: booleanSchema
})
```

然后类型检查或 codegen 能发现：

- 这个事件是 `emit`，监听器返回值不会被消费；
- 这个事件是 `bail`，监听器返回值会被用于短路；
- 这个事件是 `waterfall`，监听器必须处理 `next()`；
- 如果监听器返回 `true` 但事件是 `emit`，可以警告。

### 为什么这条适合 DSH

DSH 已经有“事件模式是公共契约”的意识，官方 primer 里也提到 dispatch mode 是 event public contract。
但如果你认为它目前主要是文档/工具层契约，而不是类型层契约，那么可以提：

> 建议把 `@mode` 从文档标记提升到类型契约，至少提供 lint / codegen / 类型包装。

这是具体、可落地、不攻击性的建议。

---

## 建议三：不要把 `emit` 作为唯一底层事件语义

你博客里的核心 API 判据是：

> 最底下那层，不能是它自己某个用法。

这个判断很适合发到 DSH。

可以这样表述：

> DSH 事件系统如果希望支持多种插件场景，底层原语不应该预设“广播并丢弃返回值”这一种策略。
> `emit` 可以是默认便捷方法，但不应该是唯一底层语义。
> 底层最好有一个更中性的 dispatch primitive，上层再派生出 `emit`、`serial`、`bail`、`waterfall`。

### 建议

可以定义一个中性原语：

```ts
interface EventBus {
  dispatch<T>(event: EventDescriptor<T>, payload: T): Promise<unknown[]> | unknown[]
}
```

然后：

```ts
emit(event, payload) {
  dispatch(event, payload) // ignore result
}

serial(event, payload) {
  return dispatch(event, payload).find(isBailed)
}

waterfall(event, payload, inner) {
  // composed dispatch
}
```

这样事件策略不是焊死在底层，而是上层 helper。

### 对 DSH 社区的说法

不要说：

> Cordis 的 `emit` 是错的。

要说：

> 如果 DSH 希望事件系统可移植、可测试、可适配其他 event bus，底层最好保持策略中立。

这就更像 RFC。

---

## 建议四：把 effect 生命周期做成可替换接口，而不是插件必须理解 Cordis 语义

你博客里关于 effect 的分析很细，但发到 DSH 时不要展开成“Cordis effect 签名有多容易误解”，而要转成：

> DSH 插件需要生命周期管理，但插件不应该被迫理解 Cordis 内部 effect 栈、fiber 状态、UNLOADING 补丁、异步 disposer 链。

### 建议

DSH 定义稳定生命周期接口：

```ts
interface Lifecycle {
  onDispose(fn: () => void | Promise<void>): Disposable
  begin(): void
  end(): Promise<void>
}
```

Cordis adapter 内部可以用：

```ts
ctx.effect(...)
```

但插件只看到：

```ts
ctx.lifecycle.onDispose(() => pool.close())
```

或者更高层：

```ts
ctx.manage({
  setup: async () => openPool(),
  dispose: pool => pool.close()
})
```

### 为什么这对 DSH 有价值

DSH 已经给 vendor Cordis 加了生命周期加固，比如：

- setup 前注册 owner-list；
- setup 失败回滚；
- UNLOADING 拒绝新建 effect；
- disposer 一次性语义；
- 清理通知隔离错误。

这说明官方已经承认生命周期边界很重要。

那么下一步自然就是：

> 既然 DSH 已经修改了 Cordis 生命周期语义，是否应该把这套语义抽象成 DSH 自己的 runtime contract，而不是让插件作者直接依赖 vendored Cordis 的内部行为？

这个建议顺着官方工作往下推，更容易被接受。

---

## 建议五：把工具注册、服务注册、事件、远程传输拆成不同层

你提到“类似 tool-func 的架构”，这个方向很好。

tool-func 系列的优点是：

- `tool-func`：函数注册表；
- `tool-rpc`：把注册表暴露到网络；
- `tool-event`：把事件也当成工具；
- `events-ex`：事件返回值可被控制；
- `custom-ability`：能力注入可摘除。

DSH 可以借鉴的不是“用 tool-func 替换 Cordis”，而是这种分层：

| 层 | 职责 | DSH 对应问题 |
| --- | --- | --- |
| Identity | 名字、版本、来源 | 插件身份、工具身份 |
| Schema | 参数、返回值、说明 | LLM 工具调用、校验 |
| Lifecycle | setup / dispose / rollback | 插件装卸 |
| Capability | 需要哪些能力 | `inject` |
| Registry | 按名字发现 | 插件中心 / 本地注册 |
| Dispatch | 事件如何派发 | `emit` / `serial` / `waterfall` |
| Service | 服务如何查找 | `ctx.database` / provider |
| Transport | 本地还是远程 | 远程工具、远程事件 |
| Config | 配置如何校验和热更新 | 插件配置 |
| Adapter | 底层 runtime 是什么 | Cordis / tool-func / 自研 |

### 建议

DSH 可以定义：

```ts
interface DSHToolRegistry {
  register(tool: ToolDescriptor): Disposable
  list(): ToolDescriptor[]
  call(name: string, args: unknown): Promise<unknown>
}
```

然后：

- 本地工具：Cordis adapter；
- 远程工具：RPC adapter；
- 事件工具：event adapter；
- 测试工具：in-memory adapter。

这样“让更多人都能用”就不只是口号，而是：

> 第三方 harness、第三方 agent runtime、第三方工具库，只要实现这些接口，就能接入 DSH 插件生态。

---

## 建议六：让 DSH 支持“无 Cordis 模式”或“最小 runtime 模式”

这是最有战略意义的一条。

DSH 当前可能默认：

> DSH plugin = Cordis plugin + DSH tools + DSH harness semantics。

这会导致一个问题：

> 如果用户只想用 DSH 的 tools / events / RPC / agent harness，但不想引入 Cordis 的全部语义，怎么办？

### 建议

提供几种 runtime profile：

```ts
createDSH({
  runtime: 'cordis'
})

createDSH({
  runtime: 'minimal'
})

createDSH({
  runtime: 'custom',
  adapter: myRuntimeAdapter
})
```

或者：

```ts
createDSH({
  lifecycle: cordisLifecycle,
  events: eventsExBus,
  services: simpleRegistry,
  tools: dshTools,
  transport: rpcTransport
})
```

### 对 DSH 社区的价值

这可以带来：

- 更容易测试；
- 更容易替换底层；
- 更容易接入 tool-func / tool-rpc / tool-event；
- 更容易做远程服务；
- 更容易做多进程部署；
- 更容易给插件作者提供清晰心智模型；
- 更容易避免 DSH vendor Cordis 和上游 Cordis 版本漂移带来的文档/行为不一致。

---

# 3. 发到 DSH 社区时，应该删掉什么

如果你把博客原稿直接发到 DSH，会被认为太长、太泛、太像评测 Cordis。建议删掉或大幅压缩这些部分。

## 3.1 删掉 Cordis 背景介绍

不需要介绍：

- Koishi 是什么；
- Cordis 怎么装插件；
- 插件 4000+；
- DSH 插件 topic 统计；
- 论文是什么；
- arXiv 页数；
- 时间线；
- “代码跑了六年，理论才补上来”。

DSH 社区读者已经知道 DSH 和 Cordis，至少不需要从零开始。

可以只保留一句：

> DSH 当前把 vendored Cordis 作为插件运行时底座。

## 3.2 删掉论文术语批评

博客里关于“时空可组合性”“逆序回放”“回滚”“学生气”“故作高深”的部分，不适合 DSH 社区。

原因：

- DSH 社区更关心工程行为；
- 术语批评容易变成论文/命名之争；
- 会分散“底层分层”这个核心诉求。

如果一定要提，只保留一句：

> 论文术语可以帮助理解，但 DSH 插件契约应该以类型和源码行为为准。

## 3.3 删掉 MCP 大段批评

MCP 部分在博客里有用，但在 DSH 社区里可能偏题。

除非你是在提议 DSH 兼容 MCP，否则不要大段展开。

可以压缩成：

> DSH 工具层可以考虑兼容 MCP / OpenAPI / tool-func 生态，但不需要重新发明协议。

## 3.4 删掉“坑”和“账”的强情绪标题

DSH 社区更适合：

- Problem
- Proposal
- Tradeoffs
- Alternatives
- Migration path
- Open questions

而不是：

- 坑
- 账
- 水分
- 滥造词
- 永久成本

可以保留事实，但换词。

---

# 4. 应该保留什么

博客里真正适合发到 DSH 的是这些技术判断：

## 4.1 事件模式决定拦截是否生效

这是核心。

## 4.2 `emit` 不收集返回值，导致底层语义不中立

这是核心。

## 4.3 `waterfall` 的 `await next()` 契约没有进入类型

这也是具体坑。

## 4.4 DSH vendor Cordis 和上游 Cordis 不等价

这是 DSH 社区特别关心的。

## 4.5 DSH 已经 patch 了生命周期，说明生命周期边界很重要

这是顺着官方工作提建议的好切入点。

## 4.6 单进程故障域和远程透明缺失

可以提，但不要变成“DSH 必须微服务化”。

更稳的说法：

> 如果 DSH 想支持远程工具、远程事件、多进程 harness，需要引入 transport 层，而不是把服务永远绑定为进程内对象。

---

# 5. DSH 社区帖的语气策略

GitHub 讨论区里，最有效的语气不是“你们错了”，而是：

> 我理解你们为什么这么做。
> 但如果目标是 X，那么当前结构会造成 Y。
> 我建议尝试 Z。
> 这不要求重写全部，可以渐进。

你可以用这个结构：

1. **承认官方动机**：vendor Cordis 是为了可审计、可补丁、版本固定。
2. **指出当前问题**：插件契约和 Cordis 细节耦合，导致分层不清。
3. **提出目标**：让更多 runtime / tool / event 生态接入。
4. **给出方案**：DSH runtime capability layer。
5. **给出最小落地**：先定义接口，不替换实现。
6. **给出例子**：Cordis adapter、tool-func adapter、minimal adapter。
7. **提出开放问题**：需要讨论哪些地方。

这样不像攻击，更像贡献 RFC。

---

# 6. 一个适合发到 DSH 仓库讨论区的标题

可以用这些标题：

## 标题一：偏分层

> RFC: Separate DSH plugin contract from vendored Cordis APIs

## 标题二：偏可替换

> Proposal: Make Cordis one runtime adapter, not the only DSH runtime contract

## 标题三：偏事件契约

> Discussion: Should DSH event dispatch mode become part of the type contract?

## 标题四：偏生态接入

> Proposal: Define DSH runtime capability interfaces so third-party runtimes can plug in

## 标题五：偏中文社区

> 建议：把 DSH 插件契约从 Cordis API 解耦，让底层 runtime 可替换

如果是 GitHub 英文区，建议用英文标题：

> **RFC: Introduce a runtime capability layer so Cordis becomes one implementation, not the plugin contract**

这个标题比较稳。

---

# 7. 可直接发布的 DSH Discussion 草稿

下面是一个可以直接整理成 GitHub Discussion 的版本。你可以按需要删减。

---

## Title

**RFC: Introduce a runtime capability layer so Cordis becomes one implementation, not the plugin contract**

## TL;DR

DSH currently uses vendored Cordis as the plugin runtime base. That makes sense for auditability, patchability, and version pinning.

However, if DSH wants more third-party runtimes, tool libraries, event systems, RPC transports, and non-Cordis plugin authors to adopt it, the plugin contract should be separated from Cordis-specific APIs.

I propose introducing a DSH runtime capability layer:

- lifecycle
- event contract
- service registry
- tool registry
- config store
- transport adapter

Cordis should remain the default implementation, but it should not be the only contract that plugin authors must understand.

---

## Background

DSH vendors Cordis for good reasons:

- the harness can own its framework layer;
- lifecycle bugs can be patched locally;
- versions can be pinned;
- behavior can be audited.

The vendor notes also show that DSH has already hardened Cordis lifecycle behavior, for example around setup, disposal, reentrant cleanup, and `UNLOADING`.

This suggests DSH already recognizes that lifecycle semantics are important.

The next question is whether those semantics should be exposed through a DSH-owned runtime contract, rather than through vendored Cordis APIs directly.

---

## Problem

Today, a DSH plugin often directly depends on Cordis-style `ctx` APIs:

```ts
export function apply(ctx: Context) {
  ctx.on(...)
  ctx.effect(...)
  ctx.tools.register(...)
}
```

This couples plugin code to Cordis-specific behavior:

- how effects are collected;
- how disposables are ordered;
- how services are looked up;
- how events are dispatched;
- how `inject` interacts with Cordis dependency resolution;
- how DSH vendor patches change lifecycle behavior.

This creates several practical issues.

### 1. Event dispatch semantics are easy to misunderstand

A plugin may write:

```ts
ctx.on('message', session => {
  if (banned.has(session.userId)) {
    return true
  }
})
```

But if the event is dispatched with:

```ts
ctx.emit('message', session)
```

the return value is ignored.

The plugin does not know whether its return value will be:

- ignored;
- collected;
- used to short-circuit;
- used as the next argument in a waterfall.

The decision is made at the dispatch site, not at the listener site.

This is not only a documentation issue. It is a contract issue.

### 2. `emit` is both a convenience API and a policy

If the lowest-level event primitive already means “broadcast and discard return values”, then higher-level patterns such as `serial`, `bail`, and `waterfall` become hard to compose from a neutral primitive.

A more composable design would keep the lowest primitive neutral:

```ts
dispatch(event, payload): unknown[]
```

and derive `emit`, `serial`, `bail`, and `waterfall` from it.

### 3. Plugin authors must understand Cordis lifecycle details

DSH has already added lifecycle hardening in the vendored Cordis code. That is valuable.

But if plugin authors must understand:

- fiber states;
- effect ownership;
- disposer chains;
- generator effects;
- `UNLOADING` behavior;
- async disposer concurrency;

then the DSH plugin contract becomes hard to port.

### 4. Vendor drift becomes harder to reason about

DSH vendor Cordis and upstream Cordis are not identical.

DSH vendor has local patches. Upstream also evolves independently.

This is acceptable if the DSH plugin contract is stable. It becomes harder if every plugin directly depends on Cordis-specific behavior.

---

## Proposal

Introduce a DSH runtime capability layer.

Instead of making plugins depend directly on Cordis `Context`, define DSH-owned interfaces:

```ts
interface DSHPluginContext {
  lifecycle: Lifecycle
  events: EventBus
  services: ServiceRegistry
  tools: ToolRegistry
  config: ConfigStore
}
```

Cordis remains the default implementation:

```ts
createCordisContext()
```

But other implementations become possible:

```ts
createMinimalContext()
createToolFuncContext()
createRemoteContext()
createTestContext()
```

The plugin contract becomes:

```ts
export function apply(ctx: DSHPluginContext) {
  ctx.lifecycle.onDispose(() => pool.close())
  ctx.events.on('message', handler)
  ctx.tools.register(tool)
}
```

---

## Suggested interfaces

### Lifecycle

```ts
interface Lifecycle {
  onDispose(fn: () => void | Promise<void>): Disposable
  begin(): void | Promise<void>
  end(): Promise<void>
}
```

This can be implemented with Cordis `ctx.effect()` internally.

### Event contract

```ts
interface EventDescriptor {
  name: string
  mode: 'emit' | 'serial' | 'bail' | 'waterfall' | 'parallel'
  payloadSchema?: JSONSchema
  resultSchema?: JSONSchema
}
```

Then the event API can validate:

- whether a listener return value is meaningful;
- whether `waterfall` listeners handle `next()`;
- whether a listener returning a boolean is intended to short-circuit;
- whether an event is dispatched with the declared mode.

This can be enforced through:

- TypeScript types;
- codegen;
- lint;
- runtime validation in tests.

### Tool registry

```ts
interface ToolRegistry {
  register(tool: ToolDescriptor): Disposable
  list(): ToolDescriptor[]
  call(name: string, args: unknown): Promise<unknown>
}
```

This allows local tools, MCP tools, RPC tools, and test tools to share one contract.

### Service registry

```ts
interface ServiceRegistry {
  get<T>(name: string): T | undefined
  set<T>(name: string, value: T): Disposable
  isolate(name: string, label?: string): ServiceRegistry
}
```

Cordis can implement this, but a simpler implementation can also exist.

### Transport

```ts
interface Transport {
  call(name: string, args: unknown): Promise<unknown>
  subscribe(event: string, handler: (payload: unknown) => void): Disposable
}
```

This opens the door to remote services, remote tools, and remote events.

---

## Why this helps DSH

### 1. It makes the harness more auditable

DSH can define its own stable contract instead of inheriting every Cordis detail.

### 2. It reduces vendor drift risk

If DSH vendor Cordis changes, plugin authors only need to care about DSH runtime behavior, not Cordis internals.

### 3. It makes plugins more portable

A plugin written against DSH runtime interfaces can run on:

- Cordis;
- a minimal runtime;
- a tool-func-like runtime;
- a test runtime;
- a remote runtime.

### 4. It makes third-party ecosystems easier to connect

Libraries like:

- `tool-func`
- `tool-rpc`
- `tool-event`
- `events-ex`
- MCP clients
- OpenAPI clients

can become adapters instead of competing frameworks.

### 5. It improves event semantics

If event mode is part of the contract, plugins can understand whether their return value will be used.

---

## Minimal implementation path

This does not require replacing Cordis.

A safe path:

1. Keep vendored Cordis as the default runtime.
2. Add DSH runtime interfaces.
3. Implement those interfaces with Cordis internally.
4. Add a new plugin API that uses DSH interfaces.
5. Keep the old Cordis-style API as compatibility.
6. Add tests that verify Cordis adapter and minimal adapter behave equivalently.
7. Add an example with `tool-func` / `tool-rpc` / `tool-event`.

---

## Open questions

1. Should DSH event mode become part of the type contract?
2. Should `emit` remain the default primitive, or should a neutral `dispatch` primitive be introduced?
3. Should plugin authors be encouraged to use `ctx.lifecycle`, `ctx.events`, `ctx.tools` instead of raw Cordis `ctx.effect`?
4. Should DSH define a `ServiceRegistry` interface separate from Cordis service lookup?
5. Should DSH support non-Cordis runtimes officially, or only through unofficial adapters?
6. How much of the existing Cordis-style `ctx` API should remain as compatibility?

---

## Example: plugin contract without direct Cordis dependency

```ts
import type { DSHPluginContext } from '@deepseek-ai/dsh-runtime'

export const name = 'weather'
export const inject = ['tools', 'events']

export function apply(ctx: DSHPluginContext) {
  const pool = openPool()

  ctx.lifecycle.onDispose(() => pool.close())

  ctx.events.on('message', async session => {
    if (banned.has(session.userId)) {
      return true
    }
  }, {
    event: 'message',
    mode: 'bail'
  })

  ctx.tools.register({
    name: 'get_weather',
    description: 'Query city weather',
    parameters: {
      city: {
        type: 'string',
        required: true
      }
    },
    async execute({ city }) {
      const res = await fetch(`https://api.weather.com/${city}`)
      return res.json()
    }
  })
}
```

The plugin does not need to know whether the underlying runtime is Cordis, tool-func, or a test harness.

---

# 8. 如果你想更短一点，可以发这个版本

GitHub 讨论区有时候短一点更好。

---

## Title

**Proposal: Separate DSH plugin contract from vendored Cordis APIs**

## Body

DSH vendoring Cordis makes sense: it gives the harness a pinned, auditable, patchable runtime layer.

But if DSH wants more third-party runtimes and tool ecosystems to adopt it, the plugin contract should not be Cordis-specific.

I’d like to discuss whether DSH should introduce a runtime capability layer:

```ts
interface DSHPluginContext {
  lifecycle: Lifecycle
  events: EventBus
  services: ServiceRegistry
  tools: ToolRegistry
  config: ConfigStore
}
```

Cordis can remain the default implementation.

The benefit is that plugins become easier to test, easier to port, and easier to connect to other ecosystems such as:

- `tool-func`
- `tool-rpc`
- `tool-event`
- MCP
- OpenAPI/RPC transports
- minimal test runtimes

A concrete concern: event dispatch mode affects whether a listener return value is used. A listener returning `true` may be ignored if the event is dispatched with `emit`. This should ideally be part of the event contract, not only documentation.

I’m not suggesting replacing Cordis. I’m suggesting making Cordis one implementation behind a DSH-owned runtime contract.

Would this align with DSH’s long-term direction?

---

# 9. 你可以把博客里的哪些内容转成 DSH 议题

下面是映射关系。

| 博客内容 | DSH 社区可转成什么 |
| --- | --- |
| Cordis 核心是一个 effect 栈 | 建议 DSH 定义稳定 lifecycle interface |
| `effect(execute)` 单回调容易误解 | 建议 DSH 提供 `manage/setup/dispose` 高层 API |
| 异步清理半卸载窗口 | 建议 DSH 定义 disposer completion contract |
| UNLOADING 拒绝新建 effect | 建议 DSH 把该语义写入 runtime contract |
| `emit` 丢弃返回值 | 建议事件模式进入类型契约 |
| `serial` / `bail` 只差 await | 建议事件模式由 descriptor 声明，而不是方法名硬编码 |
| `waterfall` 要自己 `await next()` | 建议类型或 lint 检查 waterfall listener |
| DSH vendor 和上游不等价 | 建议 DSH 明确 runtime compatibility matrix |
| 没有远程方案 | 建议引入 transport interface |
| 工具描述重复 | 建议 DSH tool descriptor 与 MCP/OpenAPI/JSON Schema 对齐 |
| 插件入口结构是成本 | 建议 DSH 提供 minimal plugin contract |
| 单进程故障域 | 建议 DSH 支持远程 service/tool/event adapter |

---

# 10. 在 DSH 社区里，不要把重点放在“Cordis 的坑”

虽然你博客标题叫“Cordis 的坑与账”，但 DSH 社区帖最好不要这样开头：

> Cordis 有几个坑。

因为 DSH 已经选择并 vendor 了 Cordis。这样容易被理解为：

> 你是在批评 DSH 的技术选型。

更好的开头是：

> DSH 选择 vendored Cordis 是合理的。
> 但如果 DSH 想让插件契约长期稳定，建议把 Cordis 从“唯一内核”变成“默认 adapter”。

这样你的批评对象不是 Cordis，也不是 DSH 选型，而是：

> 当前分层边界还不够清晰。

这更容易进入建设性讨论。

---

# 11. 关于“类似 tool-func 的架构”，你可以这样表达

不要直接说：

> 建议 DSH 改用 tool-func。

这会让官方觉得你在推荐另一个库。

更好的说法是：

> tool-func 系列的分层方式值得参考：每一层是下一层加限制，而不是把多种用法并列成多种 API。
> DSH 可以借鉴这种收窄式分层，把插件身份、工具 schema、生命周期、事件、服务、传输拆成不同层。

然后给一个对照表：

| tool-func 系列 | DSH 可对应能力 |
| --- | --- |
| ToolFunc | 工具/函数注册表 |
| ServerTools | 可远程调用的工具 |
| RpcMethodsServerTool | 一组相关方法 |
| ResServerTools | REST 风格资源 |
| tool-event | 事件作为工具 |
| transport | 本地/远程/SSE/WebSocket 传输 |

然后说：

> DSH 不需要使用这些库，但可以借鉴这种“每层是下层特例、选择发生在声明处、可绕过”的结构。

这样更稳。

---

# 12. 你可能遇到的反驳，以及怎么回应

## 反驳一：DSH 已经 vendor Cordis，所以不需要分层

回应：

> Vendor 解决的是版本和可审计问题。
> 分层解决的是插件契约稳定性、可测试性、可替换性。
> 两者不冲突。

## 反驳二：Cordis 已经是 DSH 的核心，抽象会破坏一致性

回应：

> 抽象不是为了破坏一致性，而是为了让一致性有明确边界。
> 当前 `ctx` 同时承载太多语义，插件作者很难知道哪些是 DSH 契约，哪些是 Cordis 细节。

## 反驳三：事件模式已经有文档/`@mode`

回应：

> 文档和 `@mode` 有帮助，但如果它没有进入类型或 lint，插件作者仍然可能误解。
> 对拦截语义这种高风险行为，类型层约束会更可靠。

## 反驳四：现在重写插件契约成本太大

回应：

> 不需要重写。
> 可以先加 DSH runtime interface，再让 Cordis adapter 实现它。
> 旧 API 保留兼容。

## 反驳五：第三方 runtime 接入不是 DSH 的目标

回应：

> 如果 DSH 的目标只是内部 harness，那当前结构可以。
> 如果 DSH 希望成为更通用的 agent runtime / plugin harness，第三方接入能力会很重要。

---

# 13. 我建议你最终发到 DSH 的帖子结构

建议用这个结构：

```md
## TL;DR

DSH 应该把 vendored Cordis 从“唯一插件内核”降级为“默认 runtime adapter”。
插件契约应该由 DSH 自己定义：lifecycle / events / services / tools / config / transport。

## Why

- DSH vendor Cordis 的动机合理：可审计、可补丁、版本固定。
- 但插件直接依赖 Cordis `ctx` 细节，会导致契约不清。
- 事件模式、生命周期、服务查找、工具注册、远程传输混在一起。
- DSH vendor 和上游 Cordis 行为不等价，插件作者需要知道更多边界。

## Proposal

Define DSH runtime capability layer.

```ts
interface DSHPluginContext {
  lifecycle: Lifecycle
  events: EventBus
  services: ServiceRegistry
  tools: ToolRegistry
  config: ConfigStore
}
```

Cordis remains default implementation.

## Concrete concerns

1. Event dispatch mode should be part of contract.
2. `emit` should not be the only neutral primitive.
3. Lifecycle should expose `onDispose/manage`, not force plugin authors to understand Cordis fiber details.
4. Tool registry should align with MCP/OpenAPI/JSON Schema.
5. Transport should allow local/remote service and event adapters.

## Minimal path

1. Add interfaces.
2. Implement Cordis adapter.
3. Keep old API compatible.
4. Add test runtime.
5. Add example adapter for tool-func/tool-rpc/tool-event.

## Open questions

- Should event mode be typed?
- Should `emit` remain default?
- Should DSH officially support non-Cordis runtimes?
- How much compatibility should remain?
```

这个版本比博客原稿更适合 DSH。

---

# 14. 你这篇博客和 DSH 帖的关系

可以这样处理：

- 博客保留完整版：Cordis 机制、论文、坑、账、tool-func 对照。
- DSH 帖只发建议版：分层、契约、可替换、事件模式、生命周期。
- 在 DSH 帖末尾放一句：

> I wrote a longer analysis on my blog, but for DSH the actionable proposal is the runtime capability layer.

或者中文：

> 更完整的分析见博客，但发到 DSH 社区的核心建议是：把 Cordis 变成 adapter，而不是插件契约本身。

这样两边都成立。

---

# 15. 最终建议：你在 DSH 社区要讨论的不是“Cordis 坑”，而是“DSH 的边界应该画在哪里”

你可以把整件事压缩成一句话：

> **DSH 需要决定：Cordis 是 DSH 的运行时内核，还是 DSH 的一个 runtime adapter？**

如果它是内核，插件作者就必须理解 Cordis 细节，DSH 生态会被 vendored Cordis 行为绑定。

如果它是 adapter，DSH 就可以定义自己的插件契约，让更多 runtime、工具库、事件库、RPC 库接入。

你真正想提的建议就是：

> **DSH 应该成为插件契约的所有者，Cordis 只是默认实现。**

这比“希望底层合理分层，让更多人都能用”更准确，也更容易在 DSH 社区形成讨论。
