---
id: l1u6m3ugxxfnbkqjuz9a90x
title: PPE 可编程提示词工程引擎开发摘要(10-11月小结)
desc: ''
updated: 1734182540071
created: 1733654415046
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

* 最开始，语义分片只能在7B上跑，折腾了1周，无论怎么修改都无法在3B左右的模型上跑成功。
* 八万五千左右汉字（没有预处理的网上随便找的菜根谭全文注解纯文本，内容比较糟糕）用7B大约需要耗时半个多小时(GPU)才能完成分片。
  性能太差，这还只是分片阶段。
* 全文输出的原文是因为如果只让AI输出chunk边界句子，则对某些文章总是无法完全精确原样输出边界句子。

### PPE(可编程提示词工程) 单元测试对`JSON-Schema`的支持

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
  outputSchema:
    properties:
      sections:
        minItems: 3
```
</details>

### 自动化提示词与手动提示词

我不相信`语义分片 Agent`不能在3B左右的模型上跑，按照我的经验这是在3B的能力范围之内的，只是存在质量差异问题，而不应该是完全失败。

最后想到的是`语义分片 Agent 提示词`是由我的`自动提示词生成器`辅助生成的，我干脆抛开它的思路，按照自己的想法，从头自己写，就豁然开朗了，可以成功在3B模型上跑通了。
原来是`自动提示词生成器`的锅，记得当时还挺自豪的，觉得自己设计的`自动提示词生成器 Agent`能在7B左右的模型上跑成功，而不需要更大的模型。然后就能不动脑就不动。
看来，真的是一旦习惯依赖AI，就开始变笨了，还被AI哄着，自以为是的聪明。也许将来有一天，人类最好的结果是变为AI的宠物。

AI生成的提示词对于小模型还是过于繁杂，真是由简入繁易，化繁为简难。

在不同的三个3B左右的模型上跑该语义提示词，发现换一个模型问题又来了，无法用相同的提示词都跑通，调通了这个模型，另一个模型的又出问题。做不到通用。

这三个模型是：

* gemma-2-2b
* qwen2.5-3b
* llama-3.2-3b

继续折腾提示词。我发现，随着模型不同，对通识中的某些词汇的词义理解上也存在歧义。而在小模型下会放大这种差异，换句话说在小模型下更容易发现词义差异。

以`section`为例,其含义并不固定：

* gemmar: Section 通常是章节（Chapter）的一部分，章节是更大的单元，由多个 Section 组成
* qwen2.5: “section”通常指的是一个章节或段落
* llama-3.2: section是一个相对较小的单元，它可能是书中的一个章节，或是书中的一个小节. 对section的理解是甚至可以到列表中项目级别。

## 2024-11月

###  新尝试

想起嵌入模型，分别尝试利用嵌入模型相似度和大模型提示词判定相似度来分片，大概的正确率(菜根谭乱版)比较:

* 46%(嵌入模型测试相似度): 1 minute
  * 调阀值从0.6改为0.55后可以到`60%`  2m2.342s
* 75%(qwen2.5-7b-instruct.Q6_K)   19m
* 54%(qwen2.5-1.5b-instruct.Q6_K) 11m
* X(gemma2-3b) 失败，居然只分了66chunks,自然错误率高得离谱。

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

### 基于自然语言的结构化输出

#### 多步 JSON 输出的问题

1. 某些场景下，需要JSON原样提取结果

在前面的分片中，原样输出边界句子，发现 LLM模型 似乎都倾向于用自己理解后的语句输出，而不会完全原文输出。比如有标点错误，"的"，"地"，“得”助词错误。
对于文言文，如果文档中同时存在文言文原文和白话文翻译，会将两者搞混，然后只输出文言文而忽略白话翻译。

这也反映到了json输出上，当LLM的输出结果，需要传入给程序，就需要结构化的json输出。我为了提升AI的输出质量，基本都采用多步方案，第一步提示词都是没有对结果格式有任何的约束要求，只是在最后一步会调用独立的json智能体脚本，从结果中提取出json。
然后在提取结果中，有时候，json智能体并不会只是原样提取，而是根据自己的理解输出，当然有的场景下，当输出结果并不精确对应json字段，这个就很有用。
但是有的时候，输出结果是足够精确的，并必须要它只是原样提取结果，就很头疼。

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
