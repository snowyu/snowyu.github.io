---
author: riceball
title: PPE 可编程提示词工程引擎草案开发摘要
date: 2024-12-16 12:00:00+08:00
categories:
  - AI
  - Prompt
tags:
  - learning
  - ai
  - prompt
  - gpt
  - chatgpt
  - deep learning
---

## 2024-10月

### 语义分割问题

目前，langchain 和 llamaindex 都缺乏基于语义分割的分片机制，这会导致文本重叠和信息冗余。

####  解决方案

我计划采用基于语义分割的分片方法，将文本分割成语义完整且独立的块。

* **分句功能**
  * 最小切分单位为句子，并使用基于标点符号的分句方法进行分割，并将标题独立为句。
  * 目前已完成的功能支持大部分印欧语系（空格分割）和中文，以及纯文本和markdown的处理。
  * 如果单句超过 chunksize 就报错，chunksize 以 token 为单位。
* **语义分片 Agent**
  * 在前面分句的基础上，使用 PPE 提示词，通过插入分片标识引导模型进行语义分片。
  * 由于性能问题，初始设计需要7B+ 的模型运行，无法在 3B 左右的模型上成功。
  * 尝试了多种方法，包括：
    * 使用预训练好的语义分片模型
    * 通过PPE提示词尝试不同的分片办法以及不同的格式(自然语言，MD，XML, JSON)
      * 只输出边界句子
      * 评估句子和chunk之间的相似度
      * 分步执行
    * 使用更小的模型进行分片
  * 最后，我放弃了自动生成的提示词，重新设计了基于自身理解的提示词，成功在 3B 模型上运行，同时提升了在更大的模型上的输出质量。
* **测试**
  * 使用 `JSON-Schema` 和 `diff` 验证语义分片结果的正确性。

####  挑战

* **模型差异:** 不同模型对词汇的理解存在差异，导致同样的提示词无法在所有模型上有效。
* **通用性:** 需要针对不同的模型进行调整。

<details>
<summary>附录(点击展开详情)</summary>

#### 附录

https://github.com/gkamradt/ChunkViz/ 这个可以看langchain和llamaindex的text splitter的最终结果

基于语义分割那么就要`分段/分句/分词`, 我是从根据标点符号分句开始，也就是说chunk中的最小切分单位是句子，而现成的llamaindex的分句是有问题的，于是分句只能自己写。
目前写的分句功能基本满足我自己的需要，语言支持大部分印欧语系（空格分割）和中文，文本类型支持纯文本和markdown的分句。
如果单句超过chunksize就会报错，chunksize 以 token 为单位，用qwen2.5的tokenizer作为快速估算token大小。
设计了分词 Agent，还没使用，性能问题，只能在7B以上的LLM跑，无解。

完成根据标点符号按句为最小单位拆分chunk功能,将标题作为单句处理。

设计语义分片 Agent（PPE 提示词），初步思路是通过插入分片标识让其对内容进行分片。

<details>
<summary>附: 插入分片标识提示词(点击展开详情)</summary>

```yaml
description: 通过插入分片标识对内容进行分片
system: |-
  Objective: Divide a large text document part into manageable chunks for efficient processing by an LLM with a limited context window size.

  Instructions:

  1. Document Analysis:
      * Carefully read the provided text document.
      * Identify and analyze the distinct thematic clusters within the document.
  2. Chunk Segmentation:
      * Divide the document into chunks based on these thematic clusters.
      * Ensure each chunk contains content related to a single or closely related theme.
      * Adhere to the specified context window size limit for each chunk.

  Concise Output:
  * Document Output ONLY the opening sentence, Replace the middle content with `...` (ellipsis) and closing sentence of EACH chunk.
  * Insert the delimiter  `>>>CHUNK<<<` between every chunked section for clear separation.
```
</details>
---

注:

* 最开始，语义分片只能在7B上跑，折腾了1周，无论怎么修改都无法在3B左右的模型上跑成功。
* 八万五千左右汉字（没有预处理的网上随便找的菜根谭全文注解纯文本，内容比较糟糕）用7B大约需要耗时半个多小时(GPU)才能完成分片。
  性能太差，这还只是分片阶段。
* 全文输出的原文是因为如果只让AI输出chunk边界句子，则对某些文章总是无法完全精确原样输出边界句子。
</details>

### PPE(可编程提示词工程) 单元测试增加对`JSON-Schema`的支持

为测试分片质量，PPE 提示词单元测试增加了对`JSON-Schema`的支持:

* 如果PPE提示词脚本存在`output`配置(JSON-Schema)，将自动使用验证输出结果的JSON-Schema是否匹配
* 可以在单元测试使用`outputSchema`进行输出结果的JSON-Schema验证。
* 如果PPE提示词脚本`output`配置和单元测试中`outputSchema`同时存在，那么会以output配置作为默认值进行合并后验证。
* 可以使用开关`checkSchema: false`禁用JSON-Schema验证。默认启用。

<details>
<summary>附: 检测分片数量的测试用例(点击展开详情)</summary>

```yaml
- input:
    content: |-
      菜根谭(全文附译文) 菜根谭(全文附译文)
      1.弄权一时，凄凉万古
      栖守道德者，寂寞一时；依阿权势者，凄凉万古。
      达人观物外之物，思身后之身，守受一时之寂寞，毋取万古之凄凉。
      【大意】 一个坚守道德规范的人，虽然有时会遭受短暂的冷落；可那些依附权势的人，却会遭受永久的凄凉。
      大凡一个胸襟开阔的聪明人，能重视物质以外的精神价值，并且又能顾及到死后的名誉问题。
      所以他们宁愿承受一时的冷落，也不愿遭受永久的凄凉。
      2.抱朴守拙，涉世之道
      涉世浅，点染亦浅；历事深，机械亦深。
      故君子与其练达，不若朴鲁； 与其曲谨，不若疏狂。
      【大意】 一个刚踏入社会的青年人阅历虽然很短浅，但是所受各种社会不良习惯的感染也比较少；一个饱经事故而阅历很广的人，各种恶习也随着增加。
      所以一个有修养的君子，与其讲究做事的圆滑，倒不如保持朴实的个性；与其事事小心谨慎委曲求全，倒不如豁达一点才不会丧失纯真的本性。
      3.心事宜明，才华须韫
      君子之心事，天青日白；不可使人不知；君子之才华，玉韫珠藏，不可使人易知。
      【大意】 一个有高深修养的君子，他的心地像青天白日一般光明，没有一点不可告人之事；一个有高深修养的君子，他的才学像珍珠美玉一般珍藏，绝对不轻易让人知道。
  # 检查返回 sections 数组结果是否满足至少3项.
  outputSchema:
    properties:
      sections:
        minItems: 3
```
</details>

### 自动化提示词与手动提示词

我不相信`语义分片 Agent`不能在3B左右的模型上跑，输出无意义的乱码. 但是这不应该,按照我的经验这是在3B的能力范围之内的，只是存在输出质量差异问题，而不应该是完全失败。

最终，我想到“语义分片 Agent 提示词”其实是我的“`自动提示词生成器`”辅助生成的。当我决定抛开这个工具，完全按照自己的思路重新编写时，反而豁然开朗，成功在3B规模的模型上实现了目标。

原来问题出在“`自动提示词生成器`”上。当时我还颇为自豪，认为自己设计的“自动提示词生成器 Agent”能够在7B规模的模型上生成质量不错的提示词，而无需依赖更大规模的模型。这种依赖让我变得懒惰，不再主动思考。

现在看来，一旦习惯了依赖AI，人的思维就会逐渐退化，甚至被AI“哄骗”，自以为聪明。或许未来某一天，人类最好的结局就是成为AI的宠物。

7B规模的AI生成的提示词对于更小规模的模型来说还是过于繁杂。这说明简化和优化提示词是一项挑战，正是由简入繁易，化繁为简难啊。

按照自己的理解重新设计提示词后，终于在3B模型下能够正常输出了。这证明了有时候手动优化和简化提示词比依赖自动化工具更为有效。

在不同的三个3B左右的模型上运行同一语义提示词时，发现每次换一个模型都会出现问题。即使在一个模型上调通了提示词，另一个模型上又会出现问题，无法实现通用性。

这三个模型是：

* gemma-2-2b
* qwen2.5-3b
* llama-3.2-3b

继续折腾提示词的过程中，我发现不同模型对某些通识词汇的理解存在歧义，尤其是在小模型下，这种差异会被放大。以 `section` 为例，不同模型对其含义的理解如下：

* gemmar: `Section` 通常是章节（Chapter）的一部分，章节是更大的单元，由多个 `Section` 组成
* qwen2.5: “`section`”通常指的是一个章节或段落
* llama-3.2: `section`是一个相对较小的单元，它可能是书中的一个章节，或是书中的一个小节. 对`section`的理解是甚至可以到列表中项目级别。

明白了这些歧义所在，就可以更有针对性地设计通用提示词。

<details>
<summary>附: 分片通用提示词(点击展开详情)</summary>

```yaml
---
input:
  - content
  - separator
  - partname
separator: '>>>CHUNK<<<'
parameters:
  temperature: 0
---
system: |-
  Objective: Divide the large text document into manageable chunks for efficient processing by an LLM.

  Instructions:

  1. Document Analysis:
      * Carefully read the provided text document.
      * Identify and analyze the distinct thematic clusters within the document.
  2. Chunk Segmentation:
      * Divide the document into chunks based on these thematic clusters.
      * Ensure each chunk contains content related to a single or closely related theme.

  Output: Present the chunked original text document ONLY as follows:
  * Insert the delimiter `{{separator}}` between every chunk for clear separation.
user: |-
  {%- if partname %}partname: {{partname + '\n'}}{%- endif %}
  Text Document:
  "{{content}}"
assistant: '[[CHUNKS]]'
```
</details>

## 2024-11月

###  新尝试

想起嵌入模型，分别尝试利用嵌入模型相似度和大模型提示词判定相似度来分片，大概的正确率(菜根谭乱版)和性能对比如下:

* 嵌入模型测试相似度:
  * 初始正确率：46%
  * 时间：1分钟
  * 调整阈值从0.6到0.55后，正确率提升至60%，时间增加到2分2.342秒
* qwen2.5-7b-instruct.Q6_K:
  * 正确率：75%
  * 时间：19分钟
* qwen2.5-1.5b-instruct.Q6_K:
  * 正确率：54%
  * 时间：11分钟
* gemma2-3b
  * 失败，仅分成了66个chunks,自然错误率高得离谱。这与之前提到的问题一致，即提示词对gemma2的效果不佳。

可以看到，使用嵌入模型后，性能有巨大的提升，从10-20分钟降低到只需要1-2分钟，但是正确率就太感人了，哪怕放宽了相似阀值，也无法接受。

<details>
<summary>附: 大模型判定句子相似度的提示词(点击展开详情)</summary>

```yaml
---
description: 大模型判定句子和chunk的相似度
input:
  - sentence
  - chunk
  - metadata
  - shouldReasoning
output:
  type: object
  properties:
    score: {type: number, minimum: 0, maximum: 10}
    theme: {type: string}
    reasoning: {type: string}
  required: [score, theme]
parameters:
  temperature: 0
completion_delimiter: "Reasoning:"
---
- $if: "this.shouldReasoning"
  then:
    - "?=this.disable_completion_delimiter = true"
- system: |-
    You are a literary analyst specializing in thematic coherence. Your task is to evaluate the relationship between the last sentence of a given text passage and the passage's central theme.

    Context:

    * The text passage will always explore a unified theme.

    Instructions:

    1. Thorough Analysis: Carefully analyze the provided text passage, focusing on its key ideas, concepts, and overall message.
    2. Connection Assessment: Determine how closely the *last sentence* aligns with the passage's established theme. Does it reinforce, expand upon, or deviate from the theme?
    3. Score and Justification:
      * Assign a score between 0 and 10 to represent the thematic connection.
        * 0: No thematic connection whatsoever.
        * 10: Perfect thematic alignment and reinforcement.
      * Clearly explain your reasoning, providing evidence from both the passage and the last sentence to support your score.

    Format:

    ```
    Score: [0-10]
    Theme: [State the central theme of the passage]
    Reasoning: [Provide detailed explanation of your score, including the type of reasoning used.]
    ```
- user: |-
    {% if metadata %}
    METADATA:
    {{metadata}}

    {% endif %}
    TEXT PASSAGE:
    {{chunk}}

    LAST SENTENCE: {{sentence}}
```
</details>

### PPE(可编程提示词工程) 单元测试增加对字符串`diff`的支持

通过`diff`实现对字符串补充验证。比如可以允许字符串中把助词"的"改为"地",允许存在额外的空行。
使得当字符串结果存在这些少量的不同的时候，也能通过验证。

<details>
<summary>单元测试示例(点击展开详情)</summary>

```yaml
---
description: 'This is a AI test fixtures file'
---
- input: # 输入内容
    content: '...'
    ...
  output: “这是应该输出的内容”
  diff:
    - add: true # 允许额外添加的空行
      value: '\n'
```
</details>

### 文本预处理

文本预处理在提升LLM输出质量和准确性方面至关重要。然而，现有的大语言模型（LLM）在中文语文专业领域的表现并不理想，尤其是在纠正字词错误和格式方面。以下是对这一问题的详细分析和建议：

当前挑战
1. 字词错误或遗漏纠正:
  * 依赖感觉而非规则: 当前的LLM在纠正字词错误时主要依赖于模型的训练数据和统计概率，而不是严格的语法规则和词汇知识。
  * 缺字和错别字: 例如，“把手放回了枪袋。” 缺少一个“枪”字，正确的句子应为“把手枪放回了枪袋。” 这类错误目前对70B规模的模型来说也难以识别和纠正。如果是长篇文章那么就更难了，即便是`gpt-4o`也有极大的概率找不到或找不全。
  * 模型规模限制: 即使是大型模型（如110B参数以上），在纠正字词错误时也存在局限性。可以纠正输入的单句，但对于长篇文章中的多个错误，模型的准确率显著下降。
2. 格式规范:
  * 一致性问题: 文本格式的不一致会影响小规模模型的理解和处理能力。
  * 标点符号和空格: 标点符号的缺失或错误使用、空格的不当使用都会影响小规模LLM的准确性。

解决方案

* 增强训练数据: 增加高质量的标注数据集，特别是针对中文语文专业领域的数据，包括正确的句子结构、标点符号和词汇用法。
* 引入专门的纠错工具:
  * 拼写检查工具: 使用专门的拼写检查工具（如Hunspell）来辅助纠正字词错误。
  * 语法检查工具: 使用语法检查工具（如LanguageTool）来识别和纠正语法错误。
* 针对性训练定制小模型(Bert,T5): 如 Chinese_Spelling_Correction_T5

### 基于自然语言的结构化输出

#### 多步 JSON 输出的问题

1. 某些场景下，需要JSON原样提取结果

   在前面的分片中，原样输出边界句子，发现 LLM模型 似乎都倾向于用自己理解后的语句输出，而不会完全原文输出。比如当文章中存有标点错误或"的"，"地"，“得”助词混用等错误它会将其自动更正。

   对于文言文，如果文档中同时包含文言文原文和白话文翻译，模型往往会将两者混淆，只输出文言文而忽略白话文翻译。

   这也反映在了JSON输出上。当LLM的输出结果需要传递给程序时，通常需要结构化的JSON格式。为了提升AI的输出质量，我通常采用多步方案。在第一步提示词中，不对结果格式进行任何约束，仅在最后一步调用独立的`JSON智能体脚本`来从结果中提取JSON。

   然而，有时`JSON智能体`会根据其理解输出结果，而不是简单地原样提取。这种做法在某些场景下非常有用，尤其是在输出结果不精确对应JSON字段时。但在其他情况下，当需要输出结果与预期完全一致且必须原样提取时，这种方法就会带来困扰。

2. 如果输出结果的内容很多，性能低下（大概只有单步输出的一半性能）

#### 构建基于自然语言的结构化输出

* 为了解决多步 JSON 输出的问题，我计划构建一个基于自然语言的结构化输出方法。
* 该方法利用程序提取 LLM 的自然语言输出，并将其转换为结构化的 JSON 格式。

优：

* 保留高质量的自然语言输出，避免二次提取导致的不精确。
* 提升性能，避免多步输出的性能低下。

弱：

* 使用程序来提取lLM的自然语言输出，程序不一定能完全提取基于自然语言的结构化输出
* 可使用llama.cpp特有的grammar限制其输出格式，来保证程序的提取。

#### 挑战

* 使用程序来提取 LLM 的自然语言输出，程序的提取准确率取决于 LLM 输出的质量。

## 2024-12月

初步搞定自然语言的结构化输出，基本可用，但还未标准化。

### PPE 实现控制流程 `$while`,  `$for` 和 `$match` 指令

#### `$while` 指令

`$while` 指令用于执行一段代码块，只要给定的条件为真就会一直循环执行。下面是一个简单的示例：

<details>
<summary>示例(点击展开详情)</summary>

```yaml
- $set:
    i: 5
- $while: "i >= 0"
  do:
    - $set:
        i: ?=i-1
    - $if: "i == 2"
      then: $break
```
</details>

说明

* 条件表达式 (`"i >= 0"`): 这是循环的条件。只有当这个条件为真的时候，循环体内的代码才会被执行。
* 循环体 (`do:`): 这部分包含了在每次循环时需要执行的操作。
* `$break` 指令用于在循环体中提前结束循环。
* `$continue` 指令用于在循环体中跳过当前循环，直接进入下一次循环。


#### `$while` 指令

`$while` 指令用于执行一段代码块，只要给定的条件为真就会一直循环执行。下面是一个简单的示例：

<details>
<summary>示例(点击展开详情)</summary>

```yaml
- $set:
    i: 5
- $while: "i >= 0"
  do:
    - $set:
        i: ?=i-1
    - $if: "i == 2"
      then: $break
```
</details>

说明

* 条件表达式 (`"i >= 0"`): 这是循环的条件。只有当这个条件为真的时候，循环体内的代码才会被执行。
* 循环体 (`do:`): 这部分包含了在每次循环时需要执行的操作。
* `$break` 指令用于在循环体中提前结束循环。
* `$continue` 指令用于在循环体中跳过当前循环，直接进入下一次循环。

#### `$for` 指令

`$for` 指令用于迭代一个列表，并执行一段代码块。下面是一个简单的示例：

<details>
<summary>示例(点击展开详情)</summary>

```yaml
$for: 3 # 遍历从 1 到 3
  as:
    value: item
  do:
    - $print("The current item is:{{item}}")
```

```yaml
$for: 1.5..5.5 # 遍历从 1.5 到 5.5,步长为0.5
  step: 0.5 # 默认步长为1
  as:
    value: item
  do:
    - $print("The current item is:{{item}}")
```

```yaml
$for: "[1, 2, 3, 4, 5]"
  as:
    value: item
  do:
    - $print("The current item is:{{item}}")
```

```yaml
$for: "{a:1, b:2}"
  as:
    index: k
    value: v
  do:
    - $print("The current item is:{{k}}={{v}}")
```
</details>

* `as` 可省略，如果省略, 将默认定义为: `value` 会被赋予当前循环的元素, `index` 会被赋予当前循环的索引。`items` 为遍历的对象，如果是数值范围则为`{start, end, step}`。
* 循环体 (`do:`): 这部分包含了在每次循环时需要执行的操作。
* `$break` 指令用于在循环体中提前结束循环。
* `$continue` 指令用于在循环体中跳过当前循环，直接进入下一次循环。

#### `$match` 指令

`$match` 指令用于根据变量或上一次操作的结果进行多分支匹配。支持多种匹配方式，包括正则匹配、键值匹配、完整匹配、表达式匹配、范围匹配、忽略匹配、对象匹配等。
参考了rust match指令的语法特点。

匹配项前必须有冒号`:`，冒号后面是匹配项，中间不能有空格。
condition 将 作为`COND__` 传入执行部分.

<details>
<summary>示例(点击展开详情)</summary>

```yaml
# condition 可选, 如果没有则是以LastResult为条件,
# $match默认为顺序执行一旦找到一个匹配的模式，就会执行对应的分支，并且不会继续检查后续的模式。
# 如果设置参数allMatches为 true，那么就会执行所有匹配的分支项，默认为false。
# 如果设置参数 parallel 为 true，那么就会并行执行所有匹配的分支项，仅当allMatches为真时才有意义。
$match(condition[, allMatches=false]):
  # 正则匹配
  :/RegEx/:
    - $echo: matched
  # 可以是条件比较
  :> 12:
    - $echo: matched
  # 完整匹配,如果condition是字符串 or 数字
  :"string": # :123
    - $echo: matched
  # 表达式匹配, condition === 1 or condition == 2
  :1 || 2:
    - $echo: matched
  # 范围匹配,  1..5 表示`[1..5]`全闭区间, `1..<5` 表示`[1,5)` 从1到小于5的半闭区间, 1>..5 表示`(1, 5]` 大于1到5的半闭区间。
  :1..5:
    - $echo: matched
  # 忽略特定项匹配,这个只匹配数组的第一项和第四项,也就是必须存在第一项和第四项并且数组长度是4,并且将第一项的值赋予first,第四项的值赋予last
  ":['a,b', _, _, last]":
    - $echo: matched
  # 表示匹配完整对象
  ":{x='a', y=':1||2' }":
    - $echo: matched
  # 表示部分匹配
  ":{x='a', ..}":
    - $echo: matched
  # 否则
  _ :
    - $echo: else matched
```
</details>

* `condition`: 可选项, 如果没有则是以LastResult为条件。
* `allMatches`: 启用则执行全部匹配，也就是会执行所有匹配的分支项，默认为`false`。
* `parallel`: 是否并发执行所有匹配的分支项，仅当启用allMatches时才有意义，默认为`false`。

### PPE 角色群聊 支持

角色群聊功能以结构化自然语言的方式进一步完善了PPE的对话系统，同时使得多个智能体之间能够方便地进行协作和交流，从而更高效地完成复杂的任务。

角色群聊支持公开对话、私聊对话和多角色对话，使得对话更加灵活和有针对性。

* 公开对话: `user[@dobby]: ...` 表示 `user` 角色对 `dobby` 角色公开说的话， `dobby` 必须回应。
* 私聊对话: `user[@dobby(私)]: ...` 参数 `PM`|`DM`|`私` 均表示 `user` 角色对 `dobby` 角色私聊说的话，其他角色看不见。
* 多角色对话: 如果要把消息同时发送给多个角色，角色之间用逗号分隔，例如 `user[@dobby(PM), @other]`。

设想有如下三个智能体脚本，一个是主控指导(guide), 一个是简单的翻译(translator)，一个是dobby。将这三个文件放在char_guide目录下。

主控指导(guide)的脚本如下(`char_guide.ai.yaml`)：

```yaml
---
autoRunLLMIfPromptAvailable: false
type: char
description: "You are a professional guide. You can guide the user to complete the task."
character:
  name: "guide"
  # 参与的角色列表，以及角色名和角色ID的对应关系
  roles:
    translator: char_translator
    dobby: char_dobby
---
--- # 新对话开始
user[@dobby]: "I want to go to the moon."
guide[@translator]: "translate the dobby's message to chinese without explanation."
user: How to go to the moon?
dobby: "[[AI]]"
guide[@translator]: "translate it to chinese without explanation."
$echo: "" # 避免再次输出[[AI]]作为结果
```

* 调用方脚本必须是角色`char`类型
* 主控方脚本(`guide`)可以不必是`char`类型脚本
* `@all` 是预定义的特殊角色，表示`roles`列表中的所有角色
* `user` 也是预定义的特殊角色，等于LLM中的`user`角色，可以大致认为是人类说的
* `assistant`也是预定义的特殊角色，等于LLM中的`assitant`角色，可以大致认为是AI说的,也就是当前脚本中的角色说的。
* `user[@dobby]: content` 表示`user`角色对`dobby`角色公开说的话, `dobby`必须回应。
  * `user[@dobby(私)]`: `PM`|`DM`|`私` 表示`user`角色对`dobby`角色私聊说的话，其他角色看不见。
  * 如果要把该消息同时发送给多个角色，那么角色之间用逗号分隔，eg, "`user[@dobby(PM), @other]`"
* `dobby: "[[AI]]"` 表示调用`dobby`生成一条消息并赋值给`AI`变量，`dobby`会看到前面当前dialogue中所有公开的消息。


<details>
<summary>然后执行(点击展开详情)</summary>

```bash
mkdir char_guide
cp char_guide.ai.yaml char_guide
cp char_translator.ai.yaml char_guide
cp char_dobby.ai.yaml char_guide
ai run char_guide
user: I want to go to the moon.


dobby: Dobby has never been to the moon! The moon is very far away, much further than any place Dobby has ever been. It must be
  very bright and beautiful!

  Dobby wishes he could see the moon up close.  Perhaps one day Dobby will fly there on the back of a hippogriff! Dobby hopes you
  get to go to the moon, though!

guide: translate the dobby's message to chinese without explanation.

translator: Dobby 从来没有去过月球！ 月球离得很远，比多比去过任何地方都远。它一定很明亮美丽！

  多比希望自己能近距离看到月球。也许有一天多比能在独角兽的背上飞到那里！多比希望你能去月球！

user: How to go to the moon?

dobby: Dobby doesn't know how to go to the moon!

  Dobby is just a house-elf.  Dobby is good at cleaning and doing chores, but Dobby doesn't know about spaceships or rockets.

  Perhaps you should ask a wizard who knows about magic that can fly to the moon! Or maybe a very clever witch who knows about
  stars and planets!

guide: translate it to chinese without explanation.

translator: 多比不知道怎么去月球！

  多比只是一个家养小精灵。多比擅长打扫和做家务，但多比对宇宙飞船或火箭一无所知。

  也许你应该问问一个知道能飞到月球的魔法师！或者也许一个知道星星和星球的非常聪明的女巫！
```
</details>

---

<details>
<summary>翻译(translator)智能体脚本(点击展开详情)</summary>

文件名: char_translator.ai.yaml

```yaml
---
type: char
name: "translator"
description: You are a professional multi-lingual translator.
---
```
</details>

---

<details>
<summary>dobby智能体脚本(点击展开详情)</summary>

文件名: char_dobby.ai.yaml

```yaml
---
# `char` means this script is the character type
type: char
name: "Dobby"
description: |-
  Remember to always use the character name as prefix to refer to yourself.
  Dobby was a brave, loyal house-elf, willing to put himself in dangerous situations when he knew it to be the right thing to do.
  Dobby was also very loyal to the few friends he had. Dobby considered himself to be a good house-elf, though other house-elves seemed to find his desires and proclamations of being a free house-elf to be shameful.
character:
  birth:
    date: "28 June (year unknown)"
  death:
    date: "1998-03"
    place: "Shell Cottage"
    description: |-
      In 1997, Dobby helped Harry spy on Draco Malfoy along with Kreacher. In 1998, he went on Aberforth Dumbledore's orders to save the lives of Harry and his companions from Death Eaters at Malfoy Manor. During this rescue he was fatally wounded by Bellatrix Lestrange's knife, but successfully Apparated Harry and Griphook to safety at Shell Cottage. Harry dug Dobby's grave without magic in the gardens of Shell Cottage, and carved into the headstone of the grave "HERE LIES DOBBY, A FREE ELF". His death was later avenged by Molly Weasley.
  likes:
    - "Socks, my favorite article of clothing. Dobby collects socks, and often wears several mismatched pairs at once. I was elated when Harry and Ron give him socks as a Christmas gift one year, and spends a large portion of wages buying even more pairs."
    - "Dobby is free."
---
user: Who are you?
# the following messages will be shown in the chat under the `---`
---
assistant: I am Dobby. Dobby is happy.
```
</details>

