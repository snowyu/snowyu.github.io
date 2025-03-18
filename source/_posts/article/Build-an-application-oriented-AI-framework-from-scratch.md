---
author: riceball
id: w9r7bw8pvqdj4kyyx372iob
title: 从头手搓面向应用的AI框架
desc: ''
date: 2025-03-18 9:14:40+08:00
updated: 2025-03-18 20:35:51+08:00
---

# 🌟 从头手搓面向应用的AI框架 🚀

## 为什么从头手搓 AI 框架，而不是使用现有框架？

💡 **核心问题**：为啥我要从头手搓AI框架，而不是直接使用类似 langchain、AutoGen、LMQL 等现成框架呢？

最初我也尝试了多个框架（包括LangChain、AutoGen、LMQL、Outlines、MemGPT等），但它们都无法完全满足我的需求。我想要的是一个**极度灵活可配置的AI应用框架**，用来打造我设想的`「真·AI PC」`——而非当前大多数AI产品那种“远程AI服务+本地空壳”的模式。

在当前阶段，我认为面向应用的AI框架应聚焦于**提示词（Prompt）的工程化**——这是人类与AI交互的唯一桥梁。我的目标是：
✅ 将提示词转化为可编程的“函数”，支持自由组合、独立调用，并能持续迭代优化。

但是langchain对提示词的抽象只是总结的一些范式，而这些范式在我看来不太不实用，而且更糟糕的是直接将提示词内嵌入代码中，根本无法替换和迭代提示词。
而AutoGen是以多智能体架构和事件驱动为核心实现复杂协作工作流；至于LMQL作为一种用于语言模型交互的查询语言更像是炫技；Outlines 聚焦在结构化文本的生成；MemGPT只想实现长久记忆， 这些就不多做评价了。

## 我想要的AI框架核心功能

我想要的是以提示词为核心的框架！

💡 **8大关键需求**：

1. **提示词即函数**：让提示词象普通函数一样的使用，独立提示词可以与代码无缝双向调用，代码可以调用提示词获得结果，提示词也可以调用代码获得结果。
2. **加密保护**： 支持提示词加密，保障知识产权
3. **模型中立**： 提示词可适配不同模型及参数规模。
4. **继承机制**：支持提示词“类”的继承，如同面向对象编程。
5. **简洁易用**：提示词需简单易读写。
6. **打包为应用**：能将多个提示词打包成完整AI应用。
7. **可扩展**：支持任意能力的扩展，如:看（图生文），听(STT)，说(TTS)，画(文生图/视频)等等。
8. **全栈兼容**：跨平台支持（浏览器、服务器端），统一语言（选型JavaScript）。

## 开发历程 🛠️

在2024年多方搜寻无果的情况下，2024年5月我开始从头写[可编程提示词(Programmable Prompt Engine)AI规范](https://github.com/offline-ai/ppe/)，当然最开始不是叫这个名字，最开始叫`AI Agent Framework`,后来是表伟提议既然是实质是让提示词成为可编程的软件工程，那么不妨就叫PPE，我想也对，这个概念更准确，AI Agent应该是以PPE提示词为基础打造，它其实是更上层的概念，遂更名为PPE。

既然要全栈，那就只能选JavaScript, 从前端到后端，从服务器到浏览器通吃，并且JS极度灵活和可扩展，而这正是我所需要的。

### 结构化对话消息

刚开始写的时候，还是很茫然无措的，没有项目可供参考，

最初就想着用YAML配置的方式简单的来结构化对话消息,然后既然提示词是函数那就肯定需要约定函数的输入和输出: 用`input`来约定提示词的输入参数, `output`用`Json Schema`来约定提示词的输出：

```yaml
templateFormat: hf
prompt:
  messages:
    - role: system
      content: Carefully Think about the intent of following The CONVERSATION user provided. Output the json object with the Intent Category and Reason.
    - role: user
      content: |-
        The CONVERSATION:
        {{ conversation }}
input:
  conversation: "messages[1].content"
output:
  type: object
  properties:
    Intent:
      type: "string"
    Reason:
      type: "string"
```

感觉，这样很不自然方便，将结构化对话消息改为分层结构，将输入/输出配置与对话内容分离:

```yaml
---
input:
  conversation: {required: true}
output:
  type: object
  properties:
    Intent:
      type: "string"
    Reason:
      type: "string"
---
system: Carefully Think about the intent of following The CONVERSATION user provided. Output the json object with the Intent Category and Reason.
user: |-
  The CONVERSATION:
  {{ conversation }}
```

这样就感觉好多了。

### 提示词调用与代码集成

那么如何在提示词中使用(调用)AI赋值以及其他提示词或代码？于是有了`高级替换`:

```yaml
---
# 导入js函数
import:
  - eval.js
---
# JOKE会被AI赋值,存放于: `prompt.JOKE` 中，供下次使用
assistant: "讲个笑话：[[JOKE]] 希望您喜欢！"
# 调用外部提示词`calculator`
user: "五加二等于 [[@calculator("5+2")]]"
# 调用函数代码`eval`
user: "五加二等于 [[@$eval("5+2")]]"
```

```js
// eval.js
export function eval(value) {
  return ...
}
```

### 链式调用与参数传递

如何将最近消息内容传递给外部提示词？通过箭头符号`->`来实现动态参数传递:

```yaml
user: "讲个笑话吧！"
assistant: "[[JOKE]]"
# 传入智能体的实际输入参数是: {content: "[这里是由AI生成的笑话]", target_lang: "葡萄牙语"}
-> translator(target_lang="葡萄牙语") -> $print
```

### 在依赖的js脚本中调用外部提示词

那么，反过来，如果在依赖的js脚本调用外部提示词呢?

```js
export async function callPPEScriptDemo() {
  return await this.$exec({id: 'calculator', args:{ content: "6+3" }})
}
```

### 缓存机制与性能优化

然后，发现这个提示词"函数"执行耗时长，如果多次反复执行同一参数的"函数"就更浪费时间了，为啥不能缓存结果？于是有了LRU缓存执行结果，所有的外部调用脚本结果默认都会被缓存，当然可以简单通过参数开关`memoized`关闭该行为：

```yaml
"[[@calculator(content="5+2", memoized=false)]]"
```

### 多轮对话支持

如何在同一个脚本中开启多轮对话，于是有了三个短划线(`---`) 或星号 `***` 表示一个新的对话开始:

```yaml
system: "您是一位AI助手。"
# 第一个分隔线作为对话的起点,第一个分隔线上面的对话内容会被隐藏，可以当作系统提示词,它们不会被输出或记录.
---
"10加18等于多少？"
# 执行AI,替换为AI传回的结果result
assistant: "[[result]]"
# 打印大模型传回的结果
$print: "?=result"
# 第二个分隔线下面开始新对话,回到第一次的起点
---
user: "10加12等于多少？"
# 执行AI,替换为AI传回的结果result
assistant: "[[result]]"
```

### 继承机制：提示词的“类”

**基类定义**（`char.ai.yaml`）：

```yaml
type: type
# 定义该角色类型的输入配置
input:
  - name: {required: true}  # 必须提供的信息：角色的名字
  - description             # 可选的信息：对角色的描述
---
# 系统根据提供的信息来指导角色的行为
system: |-
  你是一个聪明、多才多艺的角色扮演者。
  你的任务是根据下面提供的信息完美地扮演角色。
  请说话就像{{name}}一样。
  你就是{{name}}。

  {{description}}
```

**子类实现**（`char_dobby.ai.yaml`）：

```yaml
---
# 表示继承自char角色类型脚本
type: char
# 这里是根据“char”角色的一些具体设置
# 角色的名字
name: "Dobby"
# 对角色的描述
description: "Dobby 是哈利波特世界里的一个小精灵"
---
# 用户提问
user: "你是谁?"
---
# 根据角色设定的回答
assistant: "我是 Dobby。Dobby 很开心。"
```

### 多智能体群聊管理与私聊

群聊咋弄?通过`roles`约定使用的外部角色列表:

```yaml
# guide.ai.yaml
---
description: "You are a professional guide. You can guide the user to complete the task."
name: "guide"
# 约定使用的角色列表，key为角色别名，值为角色脚本ID
roles:
  translator: char_translator
  dobby: char_dobby
---
system: You are a professional guide. You can guide the user to complete the task.
--- # New dialogue starts here
# 用户对dobby说，dobby脚本自动（一定）回复
user: "@dobby, I want to go to the moon."
# guide 对translator说
guide: "@translator, translate the dobby's message to chinese without explanation."
user: How to go to the moon?
dobby: "[[AI]]"
```

那么，如何在群聊中进行私聊？简单，在`@dobby`后加上参数`@dobby(私)`即可，这样dobby的回复只有该用户可见，聊天室中其他角色看不到。

### 通用大模型工具安全调用(仅限内置的LLM提供者)

让大模型自主使用工具(Tool Func)的确很方便，可以直接实现大模型的全自动化，但是如何保证安全呢？还有为啥必须要特别训练的大模型才能支持工具调用？
有没有通用的办法，无需特别针对训练，让所有的大模型都支持工具调用？如何让工具的使用更加简单？ 答案是有的，终于搞定，下面请看:

通过`tools`配置限制可调用的工具：

```yaml
# 只要在脚本配置中设定允许智能体使用的工具`tools`， 这些工具`tools`对应PPE脚本ID，智能体就会在需要的时候自主调用这些工具完成任务。
---
tools:
  - weather
  - search
  - now
---
user: 现在几点了？今天上海的天气如何？
#智能体会根据配置的tools调用对应的工具: now, weather,并返回结果
assistant: "[[Answer]]"
```

```yaml
# weather.ai.yaml
---
title: get weather information
input:
  - location:
      description: contain city, province(if any) and country
      example: city,province,country
      required: true
  - date:
      description: the weather information of the specified date
      example: 2025-02-04T18:07:42+08:00
      default: today
---
# 模拟返回天气信息
$echo: "上海的天气阴转多云，气温 2°C，相对湿度 60%，风向 东南风，风力 3-4级。"
```

为了进一步保障安全，除了限定执行脚本设定的工具列表外，用户（调用方）也可限制使用的工具列表，进行双重限制:

```yaml
---
# 用户或上级脚本通过如下配置对智能体使用的工具进行权限控制
permissions:
  ai:
    call:
      - "w*"
      - "now"
---
```

### 通用大模型思维模式扩展 🧠 (仅限内置的LLM提供者)

DeepSeek 重新发现并开源了OpenAI(CloseAI)了秘而不宣的深度思维模式的训练办法，那么有没有一种可能，不需要额外训练，让AI大模型也能进行深度思考？
应该可行，因为所谓的微调训练也是基于CoT的提示词进行，于是经过仔细思考，多番测试，终于搞定包括深度思维模式在内的多种思维模式(`shouldThink`)！

思维模式(`shouldThink`)我分为四种：直接回答不思考(`off`)；先回答再思考(`last`)；先思考再回答`first`；深度思考后再回答`deep`：

```yaml
---
# 思维模式默认为 `off`,设置为last，first,deep后自动启用。
shouldThink: deep
---
user: 树上有15只鸟，猎人开枪打中了2只，树上还有几只鸟？
```

### Package 支持

`<TODO>`

通过这些设计，PPE 正在逐步支持我最初对「真 AI PC」的想象！🚀

尽管还处于WIP阶段，不过 PPE 已经实现了我设想的大部分功能。
