---
author: riceball
id: j0njfl52nddeqmlkcpsbky3
title: 你看到的std::string，不是同一个std::string —— C++ STL跨编译器兼容性之痛
desc: ''
date: 2025-12-11 10:15:51+08:00
updated: 1765420214975
created: 1765419351220
category:
  - Thinking
  - Programming
tags:
  - thinking
  - programming
  - language
  - tech
---

# 你看到的std::string，不是同一个std::string —— C++ STL跨编译器兼容性之痛

说实话，最近被 C++ 的 STL 跨编译器兼容性搞得有点头大。本来在琢磨一件挺酷的事儿：能不能把 LLVM 字节码当作运行时跨平台的手段？比如把带 STL 类型的 C++ 代码编译成 LLVM IR，到哪儿都能跑，岂不美哉？

结果一上手就发现，理想很丰满，现实很骨感。先不说 32/64 位、字节序这些老生常谈的问题，光是 STL 这一关就过不去。

首先一个扎心的事实：不同编译器用的 STL 根本就不是一回事。

* GCC 用的是 [libstdc++](https://gcc.gnu.org/onlinedocs/libstdc++/)；
* Clang 默认用的是 [libc++](https://libcxx.llvm.org/)，也可以指定用 [libstdc++](https://gcc.gnu.org/onlinedocs/libstdc++/)；
* 微软的 MSVC 有自己的 STL 实现，叫 [MSL(Microsoft Standard Library)](https://github.com/microsoft/STL)；

这就导致了一个非常实在的问题：STL 类型的布局（layout）在不同编译器下可能不一样。比如你的 std::string 在我这儿可能长得完全不是同一个结构，传过去直接内存错乱而崩溃。所以就算 LLVM 字节码本身是跨平台的，STL 类型却跨不过编译器的墙。

更麻烦的是，有些环境还限制编译器选择。比如 CUDA 在 Windows 上，就只能配合 MSVC 用。这就意味着，你没法简单地通过“全用 Clang”来统一江湖 —— 就算强行都用 Clang，STL 的实现版本一不一样，还是可能翻车。

没想到吧？都 202X 年了，C++ 发展了这么多年，STL 都快用了几十年了，但它在 **ABI 层面仍然没有被标准化**。这真是个遗憾。想想看，我们用了这么多年 C++，却发现它在最底层、最基础的跨编译器调用问题上，依然没有一个完美的解决方案。

结果就是，我们想跨编译器传递带 STL 的对象，还是得回归最原始的 C 风格接口，手动打包、解包，仿佛回到了上世纪。

所以到头来，在 C++ 里搞跨编译器动态库，STL 类型基本成了“禁区”。要么不用，要么自己手搓数据容器，要么就走纯 C ABI —— 说好的现代 C++ 便利呢？（摊手🤷‍♂️）

看来这条路目前还不怎么通。我接下来打算看看 WASM 这边有没有更优雅的解法，能不能把 WASM 函数当作真正的跨平台函数来调。不过那是下一篇的话题了，先挖个坑 🙂
