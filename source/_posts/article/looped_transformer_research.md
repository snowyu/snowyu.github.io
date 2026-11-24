---
author: riceball
id: dw3yantjeof7c47ovsvs8qq
title: Looped Transformer Research
desc: 'SenseNova Loop-9B 与 Inkling 2 Mini 的循环架构对比、KV/速度测算与设计空间假说'
date: 2026-11-23 07:00:00+08:00
updated: 1765420214975
created: 1765419351220
category:
  - Thinking
  - AI
  - LLM
tags:
  - thinking
  - ai
  - llm
  - transformer
---

# Looped Transformer 深度研究报告：从架构对比到设计空间探索

> 基于 SenseNova Loop-9B 与 Thinking Machines Inkling 2 Mini 的对比分析
>
> 研究日期：2026年11月23日
>
> 数据截至 2026-11-23。引用标记：`[S#]` 商汤一手来源，`[T#]` Thinking Machines / HF /
> vLLM / Unsloth 一手来源，`[A#]` 论文。全部 URL 见 §10.5。
> 标注 *(推断)* 的内容是我自己的推导，不是官方口径。

---

## 目录

1. [引言：为什么 Loop 在 2026 年成为架构主线](#1-引言)
2. [基础：Looped Transformer 到底在做什么](#2-基础)
3. [两个模型的全景对比](#3-全景对比)
4. [Loop 内部机制深度剖析](#4-loop-内部机制深度剖析)
5. [关键问题：5.4B 是怎么算出来的](#5-关键问题54b-是怎么算出来的)
6. [优劣之争：机制假说与 Benchmark 证据](#6-优劣之争机制假说与-benchmark-证据)
7. [KV Cache 精确计算](#7-kv-cache-精确计算)
8. [速度差异：三个 regime 与实测锚点](#8-速度差异三个-regime-与实测锚点)
9. [开放问题](#9-开放问题)
10. [附录：数据、术语与来源](#10-附录数据术语与来源)

---

## 1. 引言

### 1.1 时间线

- **2026-10-29**：`OpenSenseNova/SenseNova-Loop` 仓库创建 `[S2]`
- **2026-10-31**：SenseNova-Loop-9B-**Preview** 释出 `[S1]`
- **2026-11-17**：SenseNova-Loop-9B 正式版（权重 + 代码，Apache 2.0）`[S1][S3]`
- **2026-11-18**：AWQ / GGUF 权重上架；寒武纪、海光等宣布 Day-0 适配 `[S1][S5][S14]`
- **2026-11-20**：Thinking Machines Lab 发布 **Inkling 2 Mini**（Apache 2.0）；vLLM /
  SGLang Day-0 支持 `[T1][T2][T8][T9]`
- **2026-11-23**：商汤宣布 10 家以上国产芯片完成 Day-0 适配 `[S4]`

### 1.2 它们共同验证了什么（以及代价）

核心命题：**推理质量更依赖计算深度，而不是参数宽度。**

但 2026 年的证据已经把这句话变成了一笔可定价的交易：

> Inkling 2 Mini 的对照实验里，**不循环的模型训练时只少花 7.5% 计算**，
> 但若要在 512K-token agentic trace 上追平循环版本的 loss，
> **推理时需要多花 140% 的计算**。 `[T2]`

同一篇博客还给出了循环**位置**的定价：把中间 12 层循环，等效算力增益
**1.51–1.91×**；把最后 12 层循环只有 **1.24–1.36×**（28 项评测里 27 项中间更好）`[T2]`。

换句话说，"深度换参数"是真的，但**深度不是免费的**——这正是本报告第 9 节要问的问题。

### 1.3 学术脉络

2026 下半年这个方向已经从"论文井喷"进入"量产 + 方法论收敛"。以下是与本报告直接相关的工作：

| 工作 | 年份 | 关键贡献 | 来源 |
|------|------|---------|------|
| Universal Transformer (Dehghani et al.) | 2018 / ICLR 2019 | 首次提出循环 Transformer | `[A1]` |
| Huginn (Geiping et al.) | 2025-02 | 3.5B / 800B tokens；prelude–核心–coda + **input injection**；推理期遍数可超训练值 | `[A3]` |
| **Ouro** (Zhu et al.) | 2025-10 | **第一代**：1.4B/2.6B，7.7T tokens，**整栈循环 R=4**（无 prelude/coda）+ Q-exit 早退 | `[A2][P1]` |
| Parcae (Prairie et al.) | 2026-04 | 约束注入参数谱范数以稳定循环；1.3B 达到"两倍大小 Transformer"最高 **87.5%** 质量 | `[A4]` |
| Hyperloop Transformers (Zeitoun et al.) | 2026-04 | 超连接 + 循环，**约少 50% 参数**仍匹敌 depth-matched / mHC 基线 | `[A5]` |
| LoopCD (Liu et al.) | 2026-10 | 用中间 pass 的"弱-强预测对"做对比解码，**循环次数减半**仍追平全深度，前向 FLOPs **−22.5~48.2%** | `[A6]` |
| LoopCD (Yu et al.) | 2026-09 | **同名但不同论文**（loop-wise contrastive decoding）——引用必须带 arXiv 号 | `[A7]` |
| Looped World Models | 2026-06 | 首个循环世界模型，最高 **100×** 参数效率 | `[A8]` |
| SMELT (Wang et al.) | 2026-09 | **三预算对齐**（FLOPs / 非嵌入参数 / KV）；循环中间一半层两次，最大 54B | `[A9]` |
| There Is No Free Loop | 2026-10 | 训练后再加循环往往**不值**推理代价；循环的定价分析 | `[A10]` |
| Towards Looped Models Done Right, Part I | 2026-10 | 把**放置 / 输入注入 / 递归状态组织**三根轴解耦做对照实验 | `[A11]` |
| Iso-Depth Laws | 2026-04 | 一次循环 ≈ **0.46** 个真层；hyper-connections → **0.65** | `[A35]` |
| Loopie | 2026-07 | 循环 **MoE**（20B-A2B / 6B-A0.6B），与 vanilla 30B-A3B **等算力**对照仍明显胜出 | `[A36]` |
| Nanbeige4.2-3B | 2026-07 | 生产级：3B 非嵌入参数 + **28T tokens** + agentic SFT/RL | `[A37]` |
| Shared Memory in Looped LMs | 2026-10 | **第一遍写 KV、后续只读** → 更好：困惑度 −1.1~1.8，显存 −76~79% | `[A38]` |
| STARS | 2026-05 | 正则 Jacobian 谱半径 + 随机 loop 采样，专治"循环到某深度见顶后崩塌" | `[A42]` |
| LoopUS | 2026-05 | 把已有 checkpoint 改造成 encoder→loop→decoder，带**抑制隐状态漂移**的选择门 | `[A43]` |

> **关于 Huginn 的常见误传**：媒体常写"3.5B 模型用 50 个循环匹敌 50B 模型"。
> 论文原话是"最高相当于 **50B 的计算负载**"——是算力等效，不是能力等效 `[A3]`。
> 这个区别与本文 §2.3 的"推理等效参数"是同一类陷阱。

**关于 Ouro 的定位**：它是**第一代**产品级 LoopLM。
它证明的是"循环可以在预训练期学会、深度可以变成可控量"，
**不是**"大跨度多遍在 9B 以上仍然划算"——它的 1.4B/2.6B 规模、
非等算力的对照口径、以及从未扫过 span 这三点，使它对本报告 §9 的假说
**既不支持也不反驳**。详见 §2.5。

---

## 2. 基础

### 2.1 标准 Transformer 的瓶颈

标准 Transformer 中，模型深度 = 参数数量：

```text
标准 Transformer:
  层0 → 层1 → 层2 → ... → 层31
  (每层独立权重，每层只经过一次)

  想更深？→ 加更多层 → 更多参数 → 更多内存
```

这个 1:1 的耦合关系是传统扩展的主要约束。

### 2.2 Looped Transformer 的核心思想

打破深度与参数的 1:1 耦合——**让部分层重复执行**：

```text
Looped Transformer:
  层0-3 → [层4-27]×N → 层28-31
  (中间层共享权重，执行 N 次)

  想更深？→ 多循环几次 → 不增加参数 → 只增加计算时间
```

**类比**：像一个人反复读同一段文字。第一遍取大意，第二遍看细节，
第三遍发现隐含逻辑——每次都用同一个大脑，理解逐层加深。

代价同样来自这个类比：每多读一遍，就多用一份时间（推理延迟），
而大脑的体积（内存）不变。

### 2.3 三个关键概念

**（a）Prelude / Core / Coda 三段式**

两个模型都把解码器分三段：

- **Prelude**（前导）：跑一次，负责嵌入与内部表征之间的"翻译"
- **Core**（循环核心）：跑多次，承载抽象推理
- **Coda**（尾随）：跑一次，负责输出侧的"翻译"

这个三明治结构在 2026 年已被对照实验支持：三轴解耦研究发现 prelude–core–coda
结构在上下文抽取与推理任务上一致更好 `[A11]`；TML 也给出同样的直觉说明 `[T2]`。

**（b）"推理等效参数"（inference-equivalent parameters）**

SenseNova 说"约 14.6B 推理等效参数"时，指的是：

> 每个 token 实际执行的计算量，等效于一个 14.6B 参数的非循环稠密模型 `[S1]`。

**不是**说模型存了 14.6B 参数——它只存了 9,656,254,576 个 `[S6]`。
（TML 的对比表把 SenseNova 记作 **9.4B / 14.6B**，商汤自己写"约 9B"，
实测 safetensors 统计为 **9.66B**——差异来自是否计入 ViT、MTP draft、FP32 mHC
路由参数。引用时必须注明口径。`[T1][S1][S6]`）

**（c）"有效活跃参数"（effective active parameters）**

对 MoE 模型（Inkling 2 Mini）：

> 一个 token 在前向传播中实际触碰到的权重总量（含循环重复触碰的）`[T1]`。

3.4B 是一次完整传播中激活的**唯一**权重；5.4B 是三遍循环后的**总触碰量** `[T1]`。

**共同的陷阱**：这两个指标都是"权重触碰量"的代理，**不等于 FLOPs**。
注意力 FLOPs 随上下文长度增长，而权重触碰量不变；MoE 的"读取带宽"和"计算量"
也不是一回事。§8 会分开处理。

### 2.4 两个模型在"跨度 × 遍数"谱系上的位置

| 模型 | 物理层 | 循环跨度 | 遍数 | 跨 pass 信息通路 | 来源 |
|------|-------|---------|------|-----------------|------|
| Ouro-1.4B/2.6B | 24 | 24（**全栈**） | R=4（可 Q-exit 早退） | 串联；embedding 直连核心，无 prelude/coda | `[A2][P1]` |
| Huginn-0125 | 递归核心 | 全栈式递归 | 训练随机 K，推理可外推 | input injection | `[A3]` |
| SenseNova Loop-9B | 32 | 24（层 4–27） | 2 | 串联 + 双流 mHC | `[S1][S6]` |
| Inkling 2 Mini | 24 | 12（层 6–17） | 3 | 每遍从 prelude 出发 + 门控消息 | `[T1][T7]` |

**要点**：这张表只能说明"大跨度**可训练**"，不能说明"大跨度**高效**"。
三行的参数量（1.4B / 9.66B / 26.4B）、数据量（7.7T / 未披露 / 未披露）
与对照口径（Ouro 比"更大稠密模型"、TML 用等算力阶梯、SenseNova 用自家 harness）
全都不同，**不可横向比较**。"跨度越大越浪费"目前不是定论，也不是反论——
它是 §9 要测的东西。目前唯一做了**等算力 + 跨度**类对照的是
SMELT（循环中间一半层 × 2，三预算对齐，最大 **54B** 非嵌入参数）`[A9]`
与 Loopie（含 vanilla 30B-A3B 对照）`[A36]`——两者都站在"中小跨度 + 少遍"
这一侧，且都是 **MoE**。

### 2.5 Ouro 该不该算家族成员？——该，但按"第一代"引用

**结论**：应纳入，但它的证据身份是"**可行性证明 + 工具箱**"，不是"效果证明"。
以下数字全部来自 Ouro 官方项目页 `[P1]` 与论文 `[A2]`。

#### 它证明了什么（值得吸收）

1. **循环要在预训练期就学会，而不是事后加**。7.7T tokens 的完整配方：
   warmup → Stable-I 3T(4K) → 分叉（2.6B 由 **upcycle 复制层**得到）→
   Stable-II 3T（**带 4 遍，为稳定性**）→ CT anneal 1.4T(16K) →
   LongCT 20B(64K) → mid-training 300B(32K) → Reasoning SFT ~8.3M 例 `[P1]`。
   循环没有破坏预训练标度——这是后面所有工作的前提。
2. **深度是可控量**：每个 loop 挂 LM head + exit gate，
   loss = exit 概率加权的任务 loss − β·H(exit 分布)；第二阶段只训 gate；
   推理时按累积 exit 概率阈值 q 退出（**Q-exit**）`[P1]`。
   商汤宣称的 Dynamic Loop 属于同一条路线 `[S1]`。
   实测 trained gate 在每个预算下都最好（2.5 遍时 MMLU ≈ 66%，4 遍 67.35%）`[P1]`。
3. **收益来自"知识操作"而非"知识存储"**，且 latent reasoning 比显式 CoT 更忠实 `[P1]`
   ——与 §5、§6.3 的结论一致。
4. Apache-2.0 权重可复现；**158 篇引用 / 35 篇实质性跟进（15 篇直接跑 Ouro ckpt）** `[P1]`。

#### 它的证据边界（不能作为效果证据引用）

1. **规模不可比**：只有 1.4B / 2.6B。R=4 后每 token 触碰量约 **9–10B**
   *(推断：层参数 ×4 + 嵌入)*，仍低于 SenseNova 的 14.6B；
   它**从未**在 ≥9B 体量上测试全栈循环。
2. **对照不是等算力**：比的是 Qwen3-1.7B / 4B / 8B、Gemma3-4B / 12B。
   拆 MMLU：Ouro-2.6B 74.6 只赢 Qwen3-4B 73.2，**输给 Qwen3-8B 76.6**；
   GSM8K 81.58 < Qwen3-8B 83.09。"最高匹敌 12B"里的 12B 是较弱的 Gemma3-12B `[P1]`。
   → 不能读成"2.6B 循环模型 ≈ 12B"。
3. **没有 span 消融**：R 固定 4、全栈固定，从未扫跨度 → 对 H1/H2 不构成证据。
4. **超过训练深度会退化**（6-benchmark 平均）`[P1]`：

   | 循环步数 T | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
   |-----------|----|----|----|----|----|----|----|----|
   | Ouro-1.4B | 49.93 | 66.90 | 71.55 | **72.39** | 71.32 | 71.14 | 70.49 | 69.87 |
   | Ouro-2.6B | 59.98 | 73.37 | 76.58 | **77.44** | 77.23 | 76.94 | 76.84 | 76.44 |

   峰值正好在训练深度 T=4，之后**单调下降**。这比 SenseNova 的
   "2→4 遍只 +1.04/+1.35 pp"更尖锐：**全栈 4 遍已经是这种模型的甜点** `[P1][S1]`。
5. **第一代最大的负债是 4 份 KV**：官方自测只保留**最后一遍** cache（¼ 内存），
   GSM8K 78.92→78.85 几乎无损，但 MATH-500 82.40→**80.40**（−2.0 pp）；
   只保留第一遍则崩溃（18.73 / 8.43）`[P1]`。第二代的 MELT / LLA / HLA /
   FlashLoop / Shared-Memory 全是在还这笔债 `[A39][A40][A27][A41][A38]`。

   算一笔单价 *(推断，仅用 `config.json` `[P2]`：24 层、16 KV heads、head_dim 128、
   **无 GQA**、24 层全是全注意力)*：

   ```text
   Ouro-1.4B：  每层每 token 2×16×128 = 4,096 元素（BF16 = 8,192 B）× 4 遍 = 32.8 KB
   SenseNova：  2,176 B/槽（Q8_0）× 14 槽                                  = 30.5 KB
   ```

   → 一个 **1.4B** 模型的每 token KV 单价，与 **9.66B** 模型同量级。
   这就是"循环把显存单价抬高"的最直接代价，也解释了为什么第二代工作
   几乎全在 Ouro 上验证 KV 压缩。
6. **serving 侧没人接住它**：vLLM 于 2025-11 加入 `OuroForCausalLM`，
   **2026-07-25 从 main 移除**（#49786），v0.26.0 是最后一个原生版本；
   而且 vLLM **总是跑满 4 遍**——它的自适应早退在引擎里根本用不上 `[P1]`。
   再叠加 §8 测到的 batch-1 kernel 主导（每 token 5,689 个小 kernel）`[A18]`，
   "省参数"并没有变成"省成本"。

**一句话**：Ouro 的贡献是"把循环做进预训练"+"把深度变成可控量"这两件事，
以及由此长出的整个跟进生态；它关于"全栈 4 遍很好"的数字**不能外推到 9B 稠密模型**。
真正该从它身上吸收的是 **Q-exit 深度控制**、**每个 loop 都算 LM loss 的训练法**、
以及**过训练深度会退化**这条负面结果（它直接约束了 §9 的"多遍"方向）。

---

## 3. 全景对比

### 3.1 基本规格

| 维度 | SenseNova Loop-9B | Inkling 2 Mini |
|------|-------------------|----------------|
| 开发方 | 商汤科技 (SenseTime) | Thinking Machines Lab |
| 发布日期 | 2026-11-17（Preview 10-31）`[S1]` | 2026-11-20 `[T1]` |
| 总参数 | 9,656,254,576（含 ViT 与 1 层 MTP draft）`[S6]` | 26.4B（含 23 层 ViT + 3 层 DSpark draft）`[T1][T7]` |
| 模型类型 | 稠密 (Dense) | MoE（128 专家 / top-8，**无共享专家**）`[T7]` |
| 一次传播活跃参数 | = 总参数（稠密） | 3.4B `[T1]`（vLLM 写作 3.5B `[T9]`） |
| 含循环的等效量 | ~14.6B inference-equivalent `[S1]` | ~5.4B effective active `[T1]` |
| 物理层数 | 32 | 24 |
| 循环范围 / 遍数 | 层 4–27（24 层）/ 2 `[S6]` | 层 6–17（12 层）/ 3 `[T7]` |
| 层执行次数 | 56 | 48 |
| 隐藏维度 | 4,096 `[S6]` | 2,304 `[T7]` |
| FFN 维度 | 12,288（稠密）`[S6]` | 1,152 / 专家 `[T7]` |
| 注意力构成 | 24 线性 + 8 全（每 4 层 3 线性 + 1 全）`[S6]` | 20 滑窗(1024) + 4 全（每 6 层 5 + 1）`[T7][T9]` |
| Q / KV 头 / head_dim | 16 / 4 / **256** `[S6]` | 24 / 8 / **128** `[T7]` |
| 上下文长度 | 512K `[S6]` | 1M `[T7]` |
| 输入 / 输出 | 文本 + 图像 → 文本 | 文本 + 图像 → 文本 |
| 许可证 | Apache 2.0 | Apache 2.0 |
| 权重大小 | BF16 仓库实测 **19.36 GB** `[S6]`；4-bit AWQ ~4.9 GB `[S1]` | NVFP4+MXFP8 **~20 GB**（实测 20.19）`[T1][T4]` |
| 社区量化 | GGUF（Q8_0 / Q5_K_M / Q4_K_M）`[S1]` | Unsloth UD-Q4_K_XL 17.6 GB `[T10]` |
| 最低部署内存 | 4-bit 权重 + 4-bit KV：**12 GiB** @256K `[S1]`（分档见 §7.2） | 官方推荐 **32 GB+** `[T1]` |
| 推测解码 | 1 层 MTP + SenseSpec draft `[S1][S13]` | 3 层 DSpark draft，读 visit 5/23/41 `[T7][T9]` |
| 数值格式 | BF16 主干 + FP32 mHC 路由参数 `[S1]` | 层 0–19 NVFP4、层 20–23 MXFP8；**端到端 4-bit 训练** `[T2][T14]` |
| 技术报告 | 尚未发布（仅权重 + 代码）`[S1]` | 模型卡 + 博客 + varloop 研究卡 `[T1][T2][T3]` |

### 3.2 数据流路径

**SenseNova Loop-9B**（`loop_settings = {start: 4, end: 28, eval_count: 2}` `[S6]`）：

```text
输入 → [层0-3] → [层4-27] → [层4-27] → [层28-31] → 输出
  Prelude    Pass 1      Pass 2      Coda
             ↑_________________↑
             24 层跨度，共享权重

  数学表达：B(B(h))，B = 24 层循环块，h₂ 由 h₁ 继续 `[S1]`
```

**Inkling 2 Mini**（`loop_config = {core_start: 6, core_end: 18, num_passes: 3, gate_rank: 64}` `[T7]`）：

```text
Pass 1:  h₀ → [层6-17] → r₁
Pass 2:  h₀ → [层6-17] → r₂    ← 读取 r₁ 的 message
Pass 3:  h₀ → [层6-17] → r₃    ← 读取 r₂ 的 message
         → [层18-23]（Coda 接在最后一遍之后）`[T9]`
```

其中 `h₀` 是 prelude（层 0–5）的输出：**三遍都从同一个 `h₀` 出发**，
遍与遍之间只通过 message 通信 `[T2][T9]`。

### 3.3 训练策略差异

| | SenseNova Loop-9B | Inkling 2 Mini | Ouro（对照） |
|--|-------------------|----------------|-------------|
| 披露程度 | 无技术报告，仅模型卡 + 代码 `[S1]` | 博客详细说明 `[T2]` | 论文 `[A2]` |
| 规模/配方 | 未披露预训练 token 数 | 主线"预测性扩展阶梯" `[T2]` | 7.7T tokens `[A2]` |
| 稀疏化 | 无 | 训练中**一次剪掉 2/3 专家**（384 → 128，每层保留使用最多的），再 **1T tokens 蒸馏**修复 `[T2]` | — |
| 后训练 | 未披露 | SFT + RL **2.2T tokens / 2,000 步** + on-policy 蒸馏对齐 `[T2]` | Thinking 变体 `[A2]` |
| 量化 | 官方发布 AWQ 4-bit 与 GGUF `[S1]` | 预训练→RL 全程 NVFP4 专家（最后 4 层 MXFP8），**部署精度 = 训练精度** `[T2][T14]` | — |
| 遍数选择 | 试 **1–4** 遍；默认 2 遍，3–4 遍更好 `[S1]` | 固定 3 遍；varloop 版 1–5 遍（RL 仅 3）`[T2]` | R=4 + Q-exit `[P1]` |

### 3.4 跨 pass 拓扑与 cache 语义

| | SenseNova | Inkling 2 Mini |
|--|-----------|----------------|
| pass 的输入 | Pass2 = Pass1 的输出（串联）`[S1]` | 每遍都从 prelude 输出出发，只通过 message 看上一遍 `[T2][T9]` |
| KV / conv 状态 | **按 layer-visit**：56 槽（14 全注意力）`[S7]` | **按 layer-visit**：48 KV + 48 conv-state `[T6][T9]` |
| 能否跨 pass 复用 | **否**：官方注释 cache 按 visit 独立 `[S7]` | **否**；varloop 提供 `loop_share_cache` `[T9]` |

> 注意：两边的实现都按 layer-visit 存 cache，SenseNova 也要为循环块里的
> 6 个全注意力层**各存两份 KV**——"串联循环可复用上一遍 cache" 这一直觉不成立。
> §7 按此计算。

---

## 4. Loop 内部机制深度剖析

这是两个模型最核心的分歧点。

### 4.1 SenseNova：串联循环 + 双流 mHC

#### 循环间：简单串联

```text
h₀ → [Block B] → h₁ → [Block B] → h₂
      Pass 1         Pass 2

第二遍完全依赖第一遍的输出——没有旁路，没有参考，只有串联。 `[S1]`
```

#### 循环内：双流 mHC 保护信息流

mHC（流形约束超连接）的配置范围是 `start: 4, end: 28`——
**恰好只覆盖循环块**，且不能跨越循环阶段边界 `[S6][S7]`：

```text
mHC 配置：streams = 2, Sinkhorn iterations = 20, pre_scale = 1.0,
          fixed_identity = false，路由参数用 FP32 `[S1][S6]`

  流A: ──→ ⊕ ──→ [注意层] ──→ ⊕ ──→ [FFN] ──→ ⊕ ──→
          ↑                    ↑                ↑
  流B: ──→ ⊕ ─────────────────┴────────────────┘

  实现细节：每个循环层的 attention 与 FFN 各挂一个 MHCRouter
  （读流 → Sinkhorn 混合 → 写回）`[S7]`
```

**Sinkhorn 归一化**：交替做行归一化与列归一化 20 次，使混合矩阵接近双随机
（行和与列和均为 1），防止信息在混合过程中单向流失 `[S1]`。

> 与论文的关系：Hyperloop Transformers 用"每个 loop 之后施加超连接"来稳定循环，
> 并称这带来约 50% 的参数节省 `[A5]`。SenseNova 是同一思路（manifold-constrained
> hyper-connections，缩写 mHC）的产品化版本，但**没有公开训练细节**。

#### 混合注意力

```text
每 4 层一组：3 层线性注意力 + 1 层全注意力 `[S1]`
全注意力层的下标：3, 7, 11, 15, 19, 23, 27, 31  → 共 8 层 `[S6]`
  · 其中 6 层落在循环块 [4,28) 内 → 两遍之后变成 12 个 KV 访问槽
循环边界对齐完整的 4 层组，保证两遍的注意力模式一致 `[S1]`
```

线性注意力侧的规格（`[S6]`）：16 个 key head × 128 维、32 个 value head × 128 维、
短卷积核 4。 *(推断)* 递推状态约 `32 × 128 × 128 ≈ 0.52M 元素/层`，
BF16 下 24 层合计约 **25 MiB/序列**，与上下文长度无关——所以"线性注意力状态可忽略"
在长上下文下成立，但它**不是 0**，且会主导极短上下文的显存构成。

#### 主干与工程实现

`SenseNovaLoopConfig` 继承 `Qwen3_5Config`，注意力用 SDPA `[S6][S7]`——
也就是说 SenseNova 是在成熟的 Qwen3.5 类主干外面套了一层循环 + mHC。
这一点比"原生支持"更准确地解释了它的生态成熟度（详见 §10.3）。

### 4.2 Inkling 2 Mini：并行参考循环 + 门控消息传递

#### 循环间：跨 Pass 消息传递

三遍都从 prelude 输出出发，遍与遍之间只靠 message 传递信息 `[T2][T9]`：

```text
Pass 1:  h₀ → [层6] ... [层17] → r₁
Pass 2:  h₀ → [层6] ... [层17] → r₂   ← 读 r₁ 的 message
Pass 3:  h₀ → [层6] ... [层17] → r₃   ← 读 r₂ 的 message
```

message 的来源不是"上一层"，而是**上一 pass 的两个 block**：
Inkling 沿用 Inkling 2 Small 的 **Attention Residuals**（Kimi，`[A19]`）——
每 6 层算一个 block，一趟 pass 恰好产生 2 个 block，每个子层用
**自己的 learned query** 去读这 2 个 block `[T9]`。

#### 门控机制（修订：原文公式有误）

从第 2 遍开始，每个循环子层的输入（注意力的 Q / K / V 输入 + MLP 输入）
各自获得一条 message，由 **rank-64 控制器**融合：

```text
h   = W_down · [ rms(input) ; rms(message) ]        # rank-64 瓶颈
out = (1 − tanh(W_forget · h)) ⊙ input + tanh(W_gain · h) ⊙ message
```

来源：`[T9]`（vLLM 给出参考实现原式），`loop_gate_rank = 64` `[T7]`。

> 关键点：控制器是 **rank-64 下投影 + 独立的 forget / gain 两路 tanh 门**，
> 而不是单一 sigmoid 门——这决定了它能否在训练初期把 message 完全关掉。

**为什么这样能稳定训练**：门在训练初期**完全屏蔽 message**，
于是每一遍开头都等价于"非循环模型"；随训练逐步放开对 message 的增益 `[T2]`。

**关键数字**：12 个循环层 × 4 种输入（Q / K / V / MLP）= **48 条 message**，
且只发生在 pass 2 与 pass 3（每 token 每次后续 pass）`[T9]`。

#### 滑动窗口层的特殊处理

Inkling 的注意力是混合的：**20 个滑窗层（窗口 1024）+ 4 个全注意力层**
（层 5、11、17、23；`layer_types` 由 `(i+1) % 6 == 0` 生成）`[T7][T9]`。

一个重要细节：滑窗层在第一遍把 Q/K/V 从**同一个输入**投影；
第二遍及以后，由于 Q/K/V 各自收到不同 message，它们变成**三个独立输入** `[T9]`。

#### 注意力的其他细节

- 24 个 query head、8 个 KV head，`head_dim = swa_head_dim = 128` `[T7]`
- 学习式**相对位置 bias + sink + 输出门**；全注意力层还带 dynamic K/V 卷积 `[T8][T9]`
- 短卷积 `conv_kernel_size = 4`，需要 per-pass 的 conv-state `[T7][T6]`
- Transformers 实现里注意力**只能 eager 模式**（因为有相对 bias 与 sink）`[T6]`
- 每个 pass 有自己的 KV cache 与 conv-state cache：**48 + 48**（不是 24 + 24）`[T6][T9]`

#### DSpark 草稿模型

官方 checkpoint 内含 **3 层 DSpark draft**（`mtp_config`，intermediate 9216），
读取目标模型在 layer-visit 5 / 23 / 41 以及最终归一化状态 `[T7][T9]`；
vLLM/SGLang 用 `--speculative-algorithm DSPARK` 启用，但 **DSpark 要求默认 pass 数** `[T9]`。

#### 可变循环次数：TML-d24-varloop-research

研究版 `TML-d24-varloop-research` 支持自定义 pass 数（训练时见过 1–5 遍，
**RL 只在 3 遍**；架构与正式版相同）`[T2][T3][T5]`：

| 配置 | 平均 CoT token | 每句词数 | 词典词比例 | 不确定性词（"wait"/"actually"/"hmm"） |
|------|---------------|---------|-----------|--------------------------------------|
| 1 pass | 3,703 | 8.9 | 94.6% | 9.7 |
| 3 passes | 1,731 | 8.7 | 94.5% | 3.6→3.9 |
| 5 passes | 1,661 | 8.7 | 94.4% | 3.6 |

来源：`[T2]`，数据取自 **varloop 研究模型在 GPQA Diamond** 上的 trace
（不是 Inkling 2 Mini 本体；不确定性词一栏 3 pass 为 3.9、5 pass 为 3.6）。

其他 varloop 结论（全部 `[T2]`）：

- **无 CoT 能力**随遍数上升后饱和：Think Fast 时间视界 1 pass 16s → 3 pass 37s，
  之后基本持平 `[T2][A30]`
- **N-Hop Lookup**（纯串行推理）持续改善到 **10 遍**，尽管模型最多只训练过 5 遍
- 有 CoT 的标准评测里，多遍主要利好**长上下文**（GraphWalks BFS、MRCR v2）、
  数学/抽象/视觉推理与简单 harness 下的长程 agentic 任务；
  **闭卷事实类基准几乎不变**（AA-Omniscience、SimpleQA Verified、SimpleVQA、WorldVQA）
  → 与"循环不会让权重装下更多事实"一致
- **CoT 可控性极低**：750–1,250 token 的 CoT 中，Inkling 2 Mini 与 varloop(3 pass)
  遵循 CoT 约束的比例 ≤0.1%，Qwen3.8-27B 为 1.3% `[T2][A31]`
- LinuxArena 隐蔽率对遍数**无趋势** `[T2]`

**关键发现**：循环次数越多，模型在内部完成的推理越多，写出来的 CoT 反而更短
（5 遍不到 1 遍的一半长度）且仍可读——"想得更深，说得更少" `[T2]`。
这直接削弱了"读 CoT 就能监督循环模型"的假设，也是 §9 之外值得单独追的线
（`[A28][A29]`）。

---

## 5. 关键问题：5.4B 是怎么算出来的

### 问题

Inkling 2 Mini 循环 3 次、每 token 活跃 3.4B，为什么推理等效是 5.4B 而不是 3.4 × 3 = 10.2B？

### 解答

**3.4B 是什么？** 模型做**一次完整前向传播**（经过全部 24 层）时激活的**唯一**权重总量——
已经包含了第一次经过循环层。

**模型卡原文** `[T1]`：

> "each extra pass through the looped layers adds about 1.0B effective active parameters.
> Since the model runs with three passes, there are 5.4B effective active parameters per token."

```text
第一次完整传播（含第一遍循环层）：  3.4B
第二遍经过循环层（额外）：        +1.0B
第三遍经过循环层（额外）：        +1.0B
────────────────────────────────────────────
每 token 有效权重触碰量：            5.4B ✓
```

### 循环层为什么每次只贡献 ~1.0B

`[T7]` 的 config 足以独立验证这个数字 *(推断，但只用官方超参)*：

```text
单个循环层的激活权重：
  Q: 2304 × (24×128) = 7.08M
  K: 2304 × (8×128)  = 2.36M
  V: 2304 × (8×128)  = 2.36M
  O: (24×128) × 2304 = 7.08M          小计 ≈ 18.9M
  专家: 8 × 3 × 2304 × 1152                          ≈ 63.7M
  路由/卷积/Norm                                      ≈ 0.4M
  → 每层 ≈ 83M
  12 层 → ≈ 0.996B ≈ 1.0B ✓ 与官方"每遍 +1.0B"吻合

非循环部分（唯一激活）：
  12 个非循环层                       ≈ 1.0B
  embedding 201024×2304               ≈ 0.46B
  lm_head  200058×2304                ≈ 0.46B
  ViT（23 层，hidden 1024）           ≈ 0.3B
  → ≈ 2.2B，与 3.4 − 1.0 = 2.4B 吻合（差值来自 norm/conv/MTP 等）
```

> 注意：`3.4 − 1.0 = 2.4` 只是同一数字的两种写法，真正的验证是上面的逐层复算。

### 重要推论

```text
存储内存占用 ← 由 26.4B 总参数决定（NVFP4+MXFP8 实测 ~20.2 GB）`[T4]`
推理速度     ← 接近 5.4B 模型的量级（每 token 做了这么多计算/权重读取）
模型质量     ← 受益于 48 次层执行的推理深度，但**不等于**知识量
```

最后一条有官方背书：**循环不会让权重装下更多事实**——Inkling 2 Mini 的
AA-Omniscience 与同级模型一致，且知识类基准对 pass 数几乎不敏感 `[T2]`。

---

## 6. 优劣之争：机制假说与 Benchmark 证据

### 6.1 为什么直觉上"草稿纸式"更优越？

以下是**机制推理，不是实验结论**（目前没有公开对照实验分离这两种拓扑）：

**（a）无信息瓶颈**

```text
深井式（SenseNova）：
  h → [Block] → h' → [Block] → h''
  唯一通道是 h'。第一遍丢掉的信息，第二遍无法恢复。

草稿纸式（Inkling）：
  Pass 2 从"干净"的 h₀ 出发，选择性地读上一遍的 block
  → 不受前一 pass 表征退化的硬约束
```

**（b）门控自适应**

rank-64 控制器的 forget / gain 两路让模型能逐通道决定遗忘（→0）或注入（→1）`[T9]`。

**（c）错误恢复能力**

串联式里第一遍的错误直接进入第二遍输入；门控式可以过滤掉一部分。

**支持这两个直觉的间接证据**：Inkling 论文式实验显示 message 融合
让循环在**512K agentic trace** 上有效（non-loop 需多 140% 推理计算才能追平）`[T2]`；
而循环模型研究中确实发现"多遍之间表征平面的收敛程度"决定了 KV 平面能否共享
（所谓 ripeness）`[A15]`——这与"第二遍面对的是分布不同的输入"是同一现象的另一面。

### 6.2 但深井式并非一无是处

**（a）实现简洁性**

```text
深井式：
  ✓ 计算图简单：B(B(h))，可直接静态展开
  ✓ 主干成熟：SenseNova 的实现就是 Qwen3.5 主干 + 循环/mHC 包装 `[S7]`
  ✓ 国产引擎的做法印证了这点：寒武纪基于 vllm_mlu 把 Loop "静态展开"，
    再补 MLU 算子与 mHC 路由优化 `[S5]`

草稿纸式：
  ✗ 每 token 每 pass 48 条 message 读取 + 48 个控制器 `[T9]`
  ✗ 每个 pass 独立的 KV / conv-state 管理 `[T6]`
  ✗ 需要引擎侧融合：vLLM 把 4 条 message 读进 1 个 kernel、
    控制器权重堆叠成 batched GEMM，否则 kernel launch 会吃掉收益 `[T9]`
```

**（b）Kernel 开销才是 batch=1 的真实瓶颈**

对循环模型的系统测量显示：Ouro 在 batch 1 时"融合所有 loop 提交"几乎不涨
（0.99×），**每 token 5,689 个小 kernel 才是成本**；在保持结果逐位一致的前提下
做融合可把吞吐提到 **1.11–1.59×** `[A18]`。这说明"串联更简单"的收益主要在
kernel 层面，而不是 FLOPs 层面。

**（c）生态成熟度**

SenseNova 有 10 家以上国产芯片 Day-0（壁仞、光本位、寒武纪、海光、昆仑芯、
摩尔线程、沐曦、昇腾、曦望、曦智）`[S4]`。但要注意措辞：
vLLM（PR #64832）、SGLang（PR #47281）、llama.cpp（PR #32588）**截至 2026-11-23
均未合并**，官方 HF 路径需要 `trust_remote_code` 或专用 llama.cpp fork `[S9][S10][S11][S12]`。
（详见 §10.3。）

### 6.3 Benchmark 上的验证（修订：补 harness 与真实胜者）

TML 模型卡与博客的对照（SenseNova 也在同一张表里）`[T1][T2]`：

| 任务（harness） | Inkling 2 Mini | SenseNova Loop-9B | Qwen3.8-27B |
|-----------------|---------------|-------------------|-------------|
| SWE-bench Verified（bash only） | 79.2% | 67.3% | 77.8% |
| DeepSWE v1.1（mini-swe-agent v2.4.6） | 48.2% | 4.4% | 42.2% |
| SWE-bench Pro v2 Hard（mini-swe-agent） | 77.9% | 53.9% | 73.8% |
| Terminal-Bench 2.1（Inkling 用 pi v0.83.0） | 71.6% | 59.6% | **73.0%** |
| AutomationBench-AA v1.0.6 | 41.8% | – | 48.2% |
| GAIA | – | 69.90（商汤自有 harness）`[S1]` | – |
| BrowseComp（含 compaction） | 79.0% | 16.7% | 61.6% |
| LongBench v2 | 66.9% | 51.4% | 52.3% |
| AA Intelligence Index v5.0 | 20.1 | – | 20.1（**打平 Qwen**） |
| GPQA Diamond | 86.6% | 74.8% | 90.5% |
| HLE（text only） | 30.7% | 15.6% | 33.9% |

> 口径提示：上表的 "–" 表示该来源**未给出数据**，不计入胜负。
> 商汤 harness 的 AutomationBench（36.67）与 TML 的 AutomationBench-AA v1.0.6
> （41.8 / 48.2）**不可并列**：harness、任务子集与版本都不同——商汤称其 36.67
> 与 Qwen3.8-27B 打平 `[S1]`，而 TML 表里 Qwen3.8-27B 是 48.2%。

**能得出的结论**：在编码/agentic 上 Inkling 2 Mini 明显强于同表其他 <30B 模型
（HF 统计它在 48 项里领先 32 项 `[T8]`）。SenseNova 在 TML 的 harness 下
DeepSWE 只有 4.4%、BrowseComp 16.7%，但在自家 harness 下 Terminal-Bench 59.55、
GAIA 69.90——**harness 与任务分布的差异足以淹没模型间差异**。

**不能得出的结论**：不能由此推出"草稿纸式更适合多步推理"。
两模型在稠密 vs MoE、9.66B vs 26.4B、数据量与 RL 规模（2.2T tokens）上全都不同，
差异无法归因到循环拓扑。一个现成的替代解释：对照实验显示
**Looped-MoE 明显优于稠密循环模型**，原因是不同 pass 会路由到不同专家、
跨环路由发散恢复了表达力 `[A12]`——Inkling 的优势可能来自 MoE，而非 message。

### 6.4 总结：两种赌注

```text
SenseNova 赌的是：
  稠密 9B + 循环增深（24 层 × 2）+ mHC 信息保护
  → 用 ~9.66B 的体重做出 ~14.6B 的深度 `[S1]`
  → 核心卖点：极低内存部署（4-bit 权重 4.9 GB；64K 上下文 ~9–10 GiB）`[S1]`
  → 风险：稠密循环模型在规模化上证据较弱 `[A12]`

Inkling 2 Mini 赌的是：
  MoE 稀疏 + 循环增深（12 层 × 3）+ 门控消息传递
  → 26.4B 体重 / 5.4B 触碰，做到接近 27B 稠密的智能（AA 20.1 打平）`[T1]`
  → 核心卖点：同量级里编码/agentic 最优 + 每任务成本 1/6 `[T1][T11]`
  → 风险：知识类任务明显弱于大模型 `[T1][T2]`
```

---

## 7. KV Cache 精确计算

### 7.0 三个口径前提

1. **Inkling 的 head_dim 是 128**：config 明确 `head_dim: 128`、`swa_head_dim: 128`、
   `num_key_value_heads: 8` `[T7]`。用 `hidden_size / num_heads = 2304 / 24 = 96`
   推会错——它显式设了 head_dim。
2. **两边都按 layer-visit 存 cache，SenseNova 的全注意力槽不是 8 而是 14** `[S7][T6]`。
3. **SenseNova 上限是 512K，不能按 1M 比较**（`max_position_embeddings = 524288` `[S6]`）。

关键的巧合：两个模型**每个 KV 槽的宽度完全相同**：

```text
Inkling：   8 KV heads × 128 = 1024 元素/token/槽
SenseNova： 4 KV heads × 256 = 1024 元素/token/槽
Q8_0：1.0625 B/元素 → 两边都是 2 × 1024 × 1.0625 = 2,176 B/token/槽
```

所以差异全部来自**槽的数量与是否被窗口截断**。

### 7.1 Inkling 2 Mini @ Q8_0

| 属性 | 值 |
|------|-----|
| KV heads / head_dim | 8 / 128 `[T7]` |
| 全注意力物理层 | 4（层 5, 11, 17, 23）`[T7]` |
| 滑窗物理层 / 窗口 | 20 / 1024 `[T7]` |
| 全注意力槽（3 pass） | prelude 1 + 核心 2×3 + coda 1 = **8** |
| 滑窗槽（3 pass） | prelude 5 + 核心 10×3 + coda 5 = **40** |

```text
每 token 每槽 = 2(K+V) × 8 × 128 × 1.0625 = 2,176 B

全注意力：
  8 × 2,176 × 1,000,000 = 17.41 GB = **16.21 GiB**  @1M
  8 × 2,176 ×   524,288 =  9.11 GB =  **8.48 GiB**  @512K
滑窗（窗口 1024）：
  40 × 2,176 × 1,024 ≈ 89 MB
conv-state（48 份，短卷积核 4）：< 2 MB *(推断)*

总计 ≈ 16.2 GiB @1M ／ ≈ 8.6 GiB @512K
```

**引擎侧实测锚点**（vLLM，GB200 单卡 TP1，4K 上下文）`[T9]`：

| 配置 | KV 容量 |
|------|---------|
| 1 pass | 352K tokens |
| 2 pass | 233K tokens |
| 3 pass（默认） | **175K tokens** |
| 3 pass + `loop_share_cache` | 194K tokens |

1→3 pass 时全注意力槽从 4 变 8，容量约减半（352K → 175K），与上面的算法一致。
`loop_share_cache` 只多回收 19K token——因为 **conv-state 仍按 pass 存** `[T9]`。

### 7.2 SenseNova Loop-9B @ Q8_0

| 属性 | 值 |
|------|-----|
| KV heads / head_dim | 4 / 256 `[S6]` |
| 全注意力物理层 | 8（层 3,7,11,15,19,23,27,31）`[S6]` |
| 其中落在循环块 [4,28) | 6 |
| **全注意力槽（per-visit）** | 第一遍 7（含层 3）+ 第二遍 6 + Coda 1 = **14** |
| 线性注意力 | 24 层，固定大小状态 ~25 MiB/序列 *(推断)* `[S6]` |

```text
每 token 每槽 = 2 × 4 × 256 × 1.0625 = 2,176 B

  14 × 2,176 × 524,288 = 15.95 GB = **14.85 GiB**  @512K（上限）
   8 × 2,176 × 524,288 =  9.11 GB   @512K  ← 若把"物理层数"当成槽数就会算成这个
```

**用官方显存表做交叉验证**（4-bit 权重 4.9 GB）`[S1]`：

| 上下文 | 官方：8-bit KV | 官方：4-bit KV | 14 槽预测（8-bit） | 8 槽预测（8-bit） |
|--------|--------------|--------------|------------------|-----------------|
| 64K | ~10 GiB | ~9 GiB | 6.4 GiB | 5.6 GiB |
| 128K | ~12 GiB | ~10 GiB | 8.3 GiB | 6.7 GiB |
| 256K | ~15 GiB | ~12 GiB | 12.0 GiB | 8.8 GiB |

绝对值都低估了官方数字（引擎预留、ViT / MTP draft / 激活 / 碎片化，
约 3–4 GiB 固定开销 *(推断)*），所以应该看**随上下文的增量**：

```text
官方增量（8-bit KV）  64K→128K: +2 GiB   128K→256K: +3 GiB
14 槽预测             64K→128K: +1.86    128K→256K: +3.72   ← 吻合
 8 槽预测             64K→128K: +1.06    128K→256K: +2.12   ← 偏低

官方增量（4-bit KV）  64K→128K: +1 GiB   128K→256K: +2 GiB
14 槽预测             64K→128K: +0.93    128K→256K: +1.86   ← 吻合更好
```

增量与 14 槽线性一致 → 确认 **per-visit cache** 是实际行为。

### 7.3 对比结论（修订）

| | Inkling @1M | Inkling @512K | SenseNova @512K |
|--|------------|--------------|-----------------|
| 全注意力槽 | 8 | 8 | **14** |
| 被窗口截断的槽 | 40（1024） | 40 | 0（24 层线性注意力，状态固定） |
| B / token / 槽 | 2,176 | 2,176 | 2,176 |
| KV 总量 | **16.2 GiB** | **8.5 GiB** | **14.9 GiB** |

**结论**：

- 每个槽的宽度两边**完全相同**，"Inkling 的 head_dim 更小"这个论据不存在。
- 在**同等 512K 上下文**下 Inkling 约小 **1.7×**，原因是：
  只有 4 层全注意力（vs SenseNova 8 层），且 40 个槽被窗口截到 1024；
  SenseNova 则要为循环块里的 6 个全注意力层**各存两遍 KV**。
- SenseNova 的线性注意力（75% 的层）确实省掉了随上下文增长的 KV，
  但它的 per-token KV 宽度（head_dim 256）与"per-visit 双份"抵消了这部分优势。
- 循环 KV 是循环模型的普遍痛点：Ouro 官方自测"只留最后一遍 cache"可省 ¾ 内存，
  但 MATH-500 掉 2.0 pp（第一遍单独用则崩溃）`[P1]`；围绕这笔债已形成一条产品线——
  平面共享（76–79% 显存下降、困惑度还更低 `[A38]`）、latent KV（10.7× 压缩 `[A27]`、
  21.3× 压缩使 batch 32→768 `[A40]`）、lazy update（6× 小 KV + 1.64× 提速 `[A41]`）、
  亚 1-bit 量化 `[A22]`、错误定位 `[A16]`。
  **含义**：§7 的 per-visit 显存不是不可撼动的下限，而是一项可回收 3–4× 的负债；
  若 SenseNova 的 14 个槽能共享到 8 个，它的 512K KV 会从 14.9 GiB 降到 ~8.5 GiB。

---

## 8. 速度差异：三个 regime 与实测锚点

### 8.1 用 FLOPs 代理只是第一层

```text
Inkling 2 Mini：  ~5.4B 等效触碰 / token `[T1]`
SenseNova Loop-9B：~14.6B 推理等效 / token `[S1]`
比值 ≈ 2.7×  →  单纯按计算量，Inkling 每 token 约为 SenseNova 的 37%
```

但"等效参数量"不等于速度。真实的 decode 延迟至少要分三种情形：

### 8.2 Regime 一：短上下文、batch=1 —— 带宽主导 *(推断)*

权重字节/token（含循环重复读取）：

```text
Inkling： 5.4B × ~0.5 B(NVFP4，层 20–23 为 MXFP8 ≈ 1 B) ≈ 2.7–3.0 GB/token
SenseNova（4-bit AWQ）：≈ 14.2B 层参数读取 × 0.5 B ≈ 7.1 GB/token
SenseNova（BF16）：≈ 28 GB/token
→ 比值约 2.4–2.6×，与 FLOPs 比值接近
```

TML 的速度曲线也是按这个口径标称的：
"614 GB/s、BF16 权重、batch=1，**包含循环带来的重复读取**的理论上限" `[T2]`。

### 8.3 Regime 二：长上下文 —— KV 读取主导 *(推断，用 §7 的槽数)*

以 128K 上下文、Q8_0 为例，每生成一个 token 需要流过：

```text
Inkling：   8 × 2,176 × 131,072 ≈ 2.28 GB（+ 滑窗 89 MB）
SenseNova：14 × 2,176 × 131,072 ≈ 3.99 GB
→ 仅 KV 一项的差距就是 ~1.7×，会削弱 Inkling 的相对优势
```

### 8.4 Regime 三：实测数字

| 指标 | 数值 | 来源 |
|------|------|------|
| Inkling decode step（GB200 TP1，4K ctx，仅前向） | 1 pass 1.51 ms / 2 pass 2.67 ms / 3 pass **3.85 ms**（batch 1） | `[T9]` |
| 同上，batch 32 | 3.81 / 5.92 / **8.11 ms** | `[T9]` |
| 每任务成本（AA Intelligence Index v5.0，Tinker 官方价） | Inkling **$0.59** vs Qwen3.8-27B $3.53（≈1/6） | `[T11]` |
| 每任务耗时 | Inkling **9.0 min** vs Qwen3.8-27B 38.2 min（≈1/4；AA 另给非推理模式 13.4 min） | `[T11]` |
| 智能/瓦特（DGX Spark） | Inkling **0.703** vs Qwen3.6-35B-A3B 0.430 / Gemma-4-26B-A4B 0.159 / Qwen3.5-27B 0.036 | `[A32]` |
| 循环模型的 kernel 开销 | Ouro batch1：每 token 5,689 个小 kernel；融合后吞吐 1.11–1.59× | `[A18]` |

> 任何第三方速度数字都需要注明量化格式、上下文长度、并发与引擎版本，
> 否则不可比。

**推测解码对循环模型尤其关键**：循环块让每 token 的权重读取翻倍以上，
draft 模型能把这些开销摊薄到多个 token 上。两家都给了原生 draft
（Inkling 3 层 DSpark `[T7][T9]`；SenseNova MTP + SenseSpec 的 DSpark/DFlash2 `[S1][S13]`），
文献里还出现了专为循环模型设计的流水线式多 token 投机解码 `[A23]`。

---

## 9. 开放问题

(略)

## 10. 附录：数据、术语与来源

### 10.1 基准测试数据汇总

**编码与 agentic（TML 模型卡 / 博客，harness 见括注）** `[T1][T2]`：

| 基准 | Inkling 2 Mini | SenseNova Loop-9B | Qwen3.8-27B |
|------|---------------|-------------------|-------------|
| SWE-bench Verified（bash only） | 79.2% | 67.3% | 77.8% |
| SWE-bench Multilingual（bash only） | 73.7% | 56.9% | 70.0% |
| SWE-bench Pro v2 Hard（mini-swe-agent v2.4.6） | 77.9% | 53.9% | 73.8% |
| SWE-bench Multimodal v2 | 37.9% | 31.0% | 37.5% |
| DeepSWE v1.1（mini-swe-agent v2.4.6） | 48.2% | 4.4% | 42.2% |
| Terminal-Bench 2.1（Inkling: pi v0.83.0） | 71.6% | 59.6% | 73.0% |
| Terminal-Bench 4.0（mini-swe-agent v2.4.6） | 5.6% | 1.2% | 5.6% |
| FrontierCode v2.0（stirrup v0.2.1） | 15.1% | – | 14.9% |
| AutomationBench-AA v1.0.6 | 41.8% | – | 48.2% |
| Vibe Code Bench v1.1（openhands） | 77.9% | – | 64.9% |
| PMPP-Hard AUC（pi v0.83.0） | 455.82 | – | 262.50 |

**知识 / 检索 / 长上下文** `[T1]`：

| 基准 | Inkling 2 Mini | SenseNova Loop-9B | Qwen3.8-27B |
|------|---------------|-------------------|-------------|
| BrowseComp（compaction） | 79.0% | 16.7% | 61.6% |
| DeepSearchQA | 85.3% | 38.1% | 79.7% |
| MCP Atlas | 82.7% | 51.4% | 77.3% |
| LongBench v2 | 66.9% | 51.4% | 52.3% |
| MRCR v2（8-needle 256K–512K） | 46.4% | 6.5% | 38.0% |
| GraphWalks BFS 256K | 69.7% | 26.5% | 50.4% |
| HLE（text only） | 30.7% | 15.6% | 33.9% |
| GPQA Diamond | 86.6% | 74.8% | 90.5% |
| AA-Omniscience v1.1（score） | −8.6 | – | −6.4 |
| AA Intelligence Index v5.0 | 20.1 | – | 20.1 |

**视觉** `[T1]`：

| 基准 | Inkling 2 Mini | SenseNova Loop-9B | Qwen3.8-27B |
|------|---------------|-------------------|-------------|
| MMMU Pro Standard 10 | 74.9% | 64.5% | 76.3% |
| PerceptionBench | 57.5% | 33.0% | 52.4% |
| OmniDocBench v1.6 | 92.8% | 84.4% | 91.5% |
| MathVision | 89.0% | 63.1% | 90.0% |
| MuirBench | 77.5% | 54.3% | 65.9% |

**商汤自有 harness** `[S1]`（与上表口径不同，不可并列比较）：

| 基准 | Preview | 正式版 | Qwen3.8-27B（商汤口径） |
|------|---------|--------|------------------------|
| AutomationBench | 14.33 | **36.67** | 36.67 |
| Terminal-Bench 2.1 | 40.45 | **59.55** | – |
| GAIA | 37.86 | **69.90** | – |
| BIRD | 71.38 | **72.34** | – |
| AIDABench | – | 65.31 | 65.01 |
| NL2Repo | – | 41.36 | 44.60 |

### 10.2 SenseNova Loop-9B 正式版 vs Preview

| 指标 | Preview (2026-10-31) | 正式版 (2026-11-17) | 变化 |
|------|---------------------|---------------------|------|
| AutomationBench | 14.33 | 36.67 | +155.8% |
| Terminal-Bench 2.1 | 40.45 | 59.55 | +47.2% |
| GAIA | 37.86 | 69.90 | +84.6% |
| 上下文长度 | 262K（config 里 `original_max_position_embeddings = 262144`） | 512K | +95.4% |
| 量化支持 | 无官方 4-bit | AWQ + GGUF（BF16/Q8_0/Q5_K_M/Q4_K_M），11-18 上架 | – |
| 4-bit 权重大小 | – | ~4.9 GB | – |

来源：`[S1][S6][S8]`。Preview 发布于 **2026-10-31**，仓库创建于 10-29。

### 10.3 部署生态对比（截至 2026-11-23）

| 推理框架 | SenseNova Loop-9B | Inkling 2 Mini |
|---------|-------------------|----------------|
| Transformers | `trust_remote_code`；环境 5.18.0 + PyTorch 2.11 `[S1]` | 上游支持（含 varloop）`[T6]` |
| vLLM | **PR #64832 未合并**，需自建分支 `[S9]` | **Day-0**（Blackwell / Hopper / Spark）`[T9]` |
| SGLang | **PR #47281 未合并** `[S10]` | Day-0（示例要求 SM103）`[T8]` |
| LightLLM | 官方示例（`ghcr.io/modeltc/lightllm:main`）`[S1]` | – |
| llama.cpp | 需官方 fork `24ea7bb`；PR #32588 未合并、无 mHC kernel `[S11][S12]` | ggml-org GGUF `[T13]`；Unsloth 量化 `[T10]` |
| Ollama / Exo Labs | – | 官方支持（Apple silicon）`[T1]` |
| MLX | – | 已上游到 mlx-lm（含多模态、mlx-community 量化）`[T8]` |
| NVIDIA Dynamo / Tokenspeed / Unsloth | – | 官方列出 `[T1]` |
| RL / 训练 | torchtitan；SenseSpec `[S1][S13]` | Tinker；SkyRL、Miles、NeMo AutoModel `[T1]` |
| 寒武纪 MLU | Day-0（vllm_mlu；Loop 静态展开 + 算子 + mHC 路由优化）`[S5]` | – |
| 海光 DCU | Day-0 `[S14]` | – |
| 摩尔线程 / 沐曦 / 昇腾 / 壁仞 / 昆仑芯 / 曦智 / 光本位 / 曦望 | Day-0（10 家以上）`[S4]` | – |

### 10.4 关键术语表

| 术语 | 含义 |
|------|------|
| Looped Transformer | 中间层重复执行以增深计算的 Transformer |
| prelude / core / coda | 循环解码器的三段式结构 `[A11][T2]` |
| span（跨度） | 被循环的物理层数 |
| mHC | 流形约束超连接：多残差流 + 双随机（Sinkhorn）混合 `[S1][A5]` |
| Sinkhorn 归一化 | 交替行/列归一化，逼近双随机矩阵；SenseNova 用 20 次迭代 `[S6]` |
| Attention Residuals（attnres） | 每 N 层成一个 block，各层用 learned query 读更早 block（Kimi `[A19]`）；Inkling 每 6 层 `[T7]` |
| message / gate controller | Inkling 的跨 pass 信息：rank-64 下投影 + 独立 forget/gain tanh 门 `[T9]` |
| input injection | Huginn/Ouro 一系的机制：把输入按深度注入递归核心 `[A2][A3]` |
| 推理等效参数 | 每 token 计算量等效的非循环模型参数量 `[S1]` |
| 有效活跃参数 | 含循环重复触碰的总权重触碰量 `[T1]` |
| layer-visit cache | KV / conv 状态按"第几次执行哪一层"存储，而非按物理层 `[S7][T6]` |
| KV plane / ripeness | 循环模型每个 pass 一个 KV 平面；平面间收敛程度决定能否共享 `[A15]` |
| DSpark / MTP | 推测解码的 draft 机制；两家都有原生 draft `[S13][T9]` |
| NVFP4 / MXFP8 | NVIDIA 4-bit 浮点格式 / Microscaling 8-bit 格式 `[T1]` |
| Loop 静态展开 | 引擎把多遍循环展开成固定计算图（寒武纪做法）`[S5]` |

### 10.5 参考来源（全部带 URL）

**SenseNova 一手 / 相关（S）**

- `[S1]` SenseNova-Loop-9B 模型卡 — <https://huggingface.co/sensenova/SenseNova-Loop-9B>
- `[S2]` OpenSenseNova/SenseNova-Loop（代码、README、许可证） — <https://github.com/OpenSenseNova/SenseNova-Loop>
- `[S3]` SenseTime 官方新闻稿（2026-11-17 正式版） — <https://www.sensetime.com/en/news/sensenova-loop-9b-release-20261118-1435>
- `[S4]` SenseTime：超 10 家国产芯片 Day-0 适配（2026-11-23）
  <https://www.sensetime.com/cn/news/sensenova-loop-9b-day0-chips-20261123-2026>
- `[S5]` IT之家：寒武纪 Day-0 适配细节（Loop 静态展开 / 算子 / mHC 路由） — <https://www.ithome.com/1/028/568.htm>
- `[S6]` SenseNova-Loop-9B `config.json`（层类型、头数、mHC、loop_settings）
  <https://huggingface.co/sensenova/SenseNova-Loop-9B/raw/main/config.json>
- `[S7]` `modeling_sensenova_loop.py`（per-visit cache、执行计划、MHCRouter）
  <https://huggingface.co/sensenova/SenseNova-Loop-9B/raw/main/modeling_sensenova_loop.py>
- `[S8]` SenseNova-Loop-9B-Preview 模型卡 — <https://huggingface.co/sensenova/SenseNova-Loop-9B-Preview>
- `[S9]` vLLM PR #64832（sensenova_loop，未合并） — <https://github.com/vllm-project/vllm/pull/64832>
- `[S10]` SGLang PR #47281（未合并） — <https://github.com/sgl-project/sglang/pull/47281>
- `[S11]` llama.cpp PR #32588（未合并） — <https://github.com/ggml-org/llama.cpp/pull/32588>
- `[S12]` 官方 GGUF 仓库 / llama.cpp fork 讨论
  <https://huggingface.co/sensenova/SenseNova-Loop-9B-GGUF>
  <https://huggingface.co/sensenova/SenseNova-Loop-9B/discussions/8>
- `[S13]` OpenSenseNova/SenseSpec（DSpark / DFlash2 draft 训练） — <https://github.com/OpenSenseNova/SenseSpec>
- `[S14]` 海光 DCU 完成 SenseNova Loop-9B 推理适配 — <https://finance.sina.com.cn/jjxw/2026-11-18/doc-inizehkx4752407.shtml>

**Inkling / Thinking Machines 一手（T）**

- `[T1]` Inkling 2 Mini 模型卡（参数、数值格式、完整评测表） — <https://thinkingmachines.ai/model-card/inkling-2-mini/>
- `[T2]` Introducing Inkling 2 Mini（循环设计、剪枝与蒸馏、监控性实验） — <https://thinkingmachines.ai/news/inkling-2-mini/>
- `[T3]` TML-d24-varloop-research 模型卡 — <https://thinkingmachines.ai/model-card/tml-d24-varloop-research/>
- `[T4]` HF checkpoint（实测 20.19 GB / 26.39B 参数） — <https://huggingface.co/thinkingmachines/Inkling-2-Mini>
- `[T5]` varloop checkpoint — <https://huggingface.co/thinkingmachines/TML-d24-varloop-research>
- `[T6]` Transformers `inkling2_loop` 文档（per-pass cache、eager-only、config 默认值）
  <https://huggingface.co/docs/transformers/main/en/model_doc/inkling2_loop>
- `[T7]` Inkling-2-Mini `config.json`（head_dim 128、loop_config、layer_types 规则、mtp_config）
  <https://huggingface.co/thinkingmachines/Inkling-2-Mini/raw/main/config.json>
- `[T8]` Hugging Face 博客（48 项中领先 32 项、MLX / llama.cpp / SGLang 用法） — <https://huggingface.co/blog/inkling2mini>
- `[T9]` vLLM 博客：Day-0 支持（门控公式、48 message、per-pass cache、实测延迟与 KV 容量） — <https://vllm.ai/blog/2026-11-20-inkling2-mini>
- `[T10]` Unsloth 本地部署指南（UD-Q4_K_XL 17.6 GB、硬件区间、专用 llama.cpp 构建） — <https://unsloth.ai/docs/models/inkling-2-mini>
- `[T11]` Artificial Analysis：Inkling 2 Mini vs Qwen3.8-27B（$0.59/9.0 min vs $3.53/38.2 min）
  <https://artificialanalysis.ai/models/comparisons/inkling-2-mini-vs-qwen3-8-27b>
- `[T12]` VentureBeat 报道（第三方）
<https://venturebeat.com/technology/thinking-machines-wows-with-inkling-2-mini-looped-transformer-model-that-runs-locally-on-laptops>
- `[T13]` ggml-org GGUF — <https://huggingface.co/ggml-org/Inkling-2-Mini-GGUF>
- `[T14]` TML Connectionism：端到端 4-bit 训练 — <https://thinkingmachines.ai/blog/end-to-end-4-bit-training/>

**论文（A）**

- `[A1]` Universal Transformer — <https://arxiv.org/abs/1807.03819>
- `[A2]` Scaling Latent Reasoning via Looped Language Models（Ouro）
<https://arxiv.org/abs/2510.25741>
<https://huggingface.co/ByteDance/Ouro-1.4B>
<https://huggingface.co/ByteDance/Ouro-2.6B>
- `[P1]` **Ouro 官方项目页**（R=1→8 完整曲线、训练配方、KV 共享实测、Q-exit、vLLM 移除时间线） — <https://ouro-llm.github.io/>
- `[P2]` Ouro-1.4B `config.json`（24 层、16 KV heads 无 GQA、`total_ut_steps = 4`）
  <https://huggingface.co/ByteDance/Ouro-1.4B/raw/main/config.json>
- `[A3]` Scaling up Test-Time Compute with Latent Reasoning: A Recurrent Depth Approach（Huginn）
  <https://arxiv.org/abs/2502.05171>
- `[A4]` Parcae: Scaling Laws For Stable Looped Language Models — <https://arxiv.org/abs/2604.12946>
- `[A5]` Hyperloop Transformers — <https://arxiv.org/abs/2604.21254>
- `[A6]` Decoding Looped Transformers Better for (Almost) Free（LoopCD，22.5–48.2% FLOPs）
  <https://arxiv.org/abs/2610.02185>
- `[A7]` LoopCD: Loop-wise Contrastive Decoding（同名另一篇） — <https://arxiv.org/abs/2609.24196>
- `[A8]` Looped World Models — <https://arxiv.org/abs/2606.18208>
- `[A9]` SMELT: Scaling Laws for Compute-Matched MoE Looped Transformers — <https://arxiv.org/abs/2609.01343>
- `[A10]` There Is No Free Loop — <https://arxiv.org/abs/2610.42030>
- `[A11]` Towards Looped Models Done Right, Part I: Topology, Input Injection, Recurrent-State Design
  <https://arxiv.org/abs/2610.23036>
- `[A12]` Sparse Layers are Critical to Scaling Looped Language Models — <https://arxiv.org/abs/2605.09165>
- `[A13]` What Makes Recurrence Effective in Looped Language Models? — <https://arxiv.org/abs/2609.36636>
- `[A14]` Allocating Recurrent Compute in Looped Language Models（MixerLoop） — <https://arxiv.org/abs/2608.18230>
- `[A15]` Recency Is the Wrong Axis: Windowed Deepest-Plane KV Caching in Looped LMs
  <https://arxiv.org/abs/2610.34436>
- `[A16]` Where KV-Cache Error Lives in Looped Language Models（Ouro / Huginn） — <https://arxiv.org/abs/2610.41825>
- `[A17]` Cross-Loop Query Handoff in the Ouro Looped Language Models — <https://arxiv.org/abs/2610.34639>
- `[A18]` What Sets the Serving Speed of Looped Language Models? — <https://arxiv.org/abs/2611.05150>
- `[A19]` Attention Residuals（Kimi Team） — <https://arxiv.org/abs/2603.15031>
- `[A20]` Late Entry in Looped Language Models — <https://arxiv.org/abs/2611.24576>
- `[A21]` Enabling Dynamic Computation in Looped LMs — <https://arxiv.org/abs/2610.09013>
- `[A22]` LoopVQ: Sub 1-bit KV Cache Quantization for Looped Transformers — <https://arxiv.org/abs/2611.05304>
- `[A23]` LoopFill: Pipelined Multi-Token Speculative Decoding for Looped Transformers
  <https://arxiv.org/abs/2611.19649>
- `[A24]` Adaptive Depth in Looped Transformers — <https://arxiv.org/abs/2607.20519>
- `[A25]` How Much Gradient Does Truncated Backprop Lose in Looped Transformers? — <https://arxiv.org/abs/2610.28871>
- `[A26]` LoopQ: Quantization for Looped Language Models — <https://arxiv.org/abs/2605.16343>
- `[A27]` Hybrid Latent Attention for Looped Language Models — <https://arxiv.org/abs/2610.07940>
- `[A28]` Monitoring latent reasoning in looped language models — <https://arxiv.org/abs/2610.18127>
- `[A29]` On the Chain-of-Thought Monitorability of Looped Language Models — <https://arxiv.org/abs/2610.02741>
- `[A30]` Think Fast: Estimating No-CoT Task-Completion Time Horizons — <https://arxiv.org/abs/2606.07157>
- `[A31]` Reasoning Models Struggle to Control their Chains of Thought — <https://arxiv.org/abs/2603.05706>
- `[A32]` Intelligence per Watt: Measuring Intelligence Efficiency of Local AI — <https://arxiv.org/abs/2511.07885>
- `[A33]` Recurrent Looped Transformer — <https://arxiv.org/abs/2610.07591>
- `[A34]` Quantizing Looped Transformers — <https://arxiv.org/abs/2609.30820>
- `[A35]` How Much Is One Recurrence Worth? Iso-Depth Scaling Laws — <https://arxiv.org/abs/2604.21106>
- `[A36]` Loop the Loopies!（Loopie，循环 MoE，等算力对照） — <https://arxiv.org/abs/2607.16051>
- `[A37]` Nanbeige4.2-3B（3B 非嵌入参数 / 28T tokens / agentic） — <https://arxiv.org/abs/2607.22083>
- `[A38]` The Surprising Effectiveness of Shared Memory in Looped Transformers — <https://arxiv.org/abs/2610.02383>
- `[A39]` Memory-Efficient Looped Transformer（MELT，单份门控 KV） — <https://arxiv.org/abs/2605.07721>
- `[A40]` Looped Latent Attention: Cross-Loop KV Compression — <https://arxiv.org/abs/2607.15456>
- `[A41]` FlashLoop: Fast and Memory-Efficient Looped Transformers via Lazy Updates — <https://arxiv.org/abs/2609.29812>
- `[A42]` STARS: Stabilizing Recurrent Dynamics for Test-Time Scalable Latent Reasoning
  <https://arxiv.org/abs/2605.26733>
- `[A43]` LoopUS: Recasting Pretrained LLMs into Looped Latent Refinement Models — <https://arxiv.org/abs/2605.11011>
- `[A44]` Improving Test-Time Scaling with Adaptive Looped Transformers（TaH²） — <https://arxiv.org/abs/2609.35748>
- `[A45]` LoopFormer: Elastic-Depth Looped Transformers via Shortcut Modulation — <https://arxiv.org/abs/2602.11451>

**文献聚合清单（第三方维护）**

- <https://github.com/HJSang/awesome-looped-transformers>
- <https://github.com/asimfish/awesome_loop_transformer>
- <https://github.com/ArminAzizi98/looped-lm-survey> （系统检索快照 2026-10-06）

