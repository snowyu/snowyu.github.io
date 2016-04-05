---
author: riceball
date: 2011-05-30 15:33:47+00:00
title: 开源 Bitcoin P2P电子货币系统技术内幕
categories:
  - P2P
  - Digital Currency
tags:
  - learning
  - bitcoin
  - digital currency
  - hashcash
  - p2p
  - proof-of-work
  - redian
---

开源 Bitcoin P2P电子货币是点对点的电子现金系统，创建于2009年[[http://en.wikipedia.org/wiki/Bitcoin](http://en.wikipedia.org/wiki/Bitcoin)]。无需金融机构直接点对点支付。该电子货币系统的特色是无需信托中间人，能够方便的进行互联网上的汇款。第三方不能够控制或者阻止您的交易。Bitcoin 交易几乎免费, 而信用卡的网上在线支付系统通常收取 1-5% 的交易费用，加上其他各种费用高达数百美元。避免了中央储备银行的不良政策和不稳定性所造成的安全隐患. Bitcoin系统的有限货币通胀是均匀分布(由CPU决定)于整个网络, 而不是由银行垄断。

这被某些人认为是最危险的开源项目，但我觉得恰恰相反，这是有史以来最令人兴奋的开源项目。这样发行的币才是真正的“人 民 币”，人民才是被服务，而不是被管理。P2P必将从商业、政治、生活各个方面重新定义新的更加公平公正的意识形态。


## 名词解释以及背后的技术


Bitcoin涉及到很多有意思的技术，要想搞懂bitcoin首先必须对这些技术理解和把握然后是对Bitcoin术语的理解，bitcoin最重要的技术支撑是P2P，数字签名(EC DSA)，散列(SHA256, RIPEMD-160), POW，和HashCash。而术语则是：transaction, block,  address, Merkle Tree.


### 工作证明 [POW(Proof-Of-Work)](http://en.wikipedia.org/wiki/Proof-of-work_system)机制


工作证明POW系统是要求对方服务前，必须要出据某种工作证明的机制。主要用于防止拒绝服务攻击和反垃圾信息。通常这种“工作证明”会花费一定的时间计算才能得到。最常见的例子是[CAPTCHA](http://en.wikipedia.org/wiki/CAPTCHA)。另外用于防止DoS和垃圾信息的机制是[HashCash](http://en.wikipedia.org/wiki/Hashcash)，bitcoin使用的原理就类似于[HashCash](http://en.wikipedia.org/wiki/Hashcash).


### [HashCash](http://en.wikipedia.org/wiki/Hashcash) 机制


hashcash 的灵感来自于这样一个想法，即一些数学结果难于发现而易于校验。一个众所周知的例子是因数分解一个大的数字（尤其是因数较少的数字）。将数字相乘来获得它们的积的代价是低廉的，但首先找到那些因数的代价却要高得多。

对交互式质询来说，因数分解足以胜任。比如，希望客户端能象征性地为其付出代价方能访问在线资源。这个时候可以定义协议，首先服务器向客户端发送一个消息，说“只要您能因数分解这个数，我将让您得到这个资源”。没有诚意的客户端将无法得到我的资源，只有那些能够证明自己有足够的兴趣、付出一些 CPU 周期来回答这个质询的才能得到这个资源。

不过，有一些资源无法很方便地进行交互式协商。比如电子邮件反垃圾或者支付交易，怎么才能避免邮箱不被垃圾邮件所占据？“我并不介意陌生人给我写信，但是，我希望他们能以稍微认真的态度，亲自通过对我有价值的邮件与我取得联系。至少，我不希望他们是垃圾邮件制造者，那些人向我和上百万的其他人发送包含同样消息的邮件（double-spending），期望我们中的某些人能购买某种产品或者落入一个骗局。”而对于电子货币，内容的复制几乎是没有代价的，如何保证电子货币（内容）没有被交易（发送）多次？这和反垃圾邮件是同样的问题。

hashcash的解决之道就是：在电子邮件的消息头中，增加一个 hashcash 戳记（hashcash stamp）散列值；该散列中包含收件人地址，发送时间，salt，该散列值特别之处在于它至少前20位必须是0才是一个合法的hashcash戳记。为了得到合法的散列值，发送者必须经过许多次尝试（改变salt值）才能获得。一旦生成戳记，不希望每一个给我发送邮件的垃圾邮件制造者都能重复使用它。所以，hashcash 戳记要带一个日期。这样可以指定时间更早的戳记是非法的。另外 hashcash 的接收端要实现一个double-spending数据库，用来记录戳记的历史信息。


### Bitcoin中的术语解释


散列：bitcoin在计算散列时一般会计算2次。第一轮总是使用SHA-256散列，而第二次在大多数情况下，也是使用[SHA-256](http://en.wikipedia.org/wiki/SHA-2)散列，但用于生成较短的散列(例如生成 bitcoin接收地址的时候)会用[RIPEMD-160](http://en.wikipedia.org/wiki/RIPEMD)散列。

```
hello
 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 ( sha-256)
 9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50 (sha-256)
```

生成比特币地址时(RIPEMD-160)：

```
hello
 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 (sha-256)
 b6a9c8c230722b7c748331a8b450f05566dc7d0f (ripemd-160)
```

Addresses: Bitcoin Address是ECDSA公钥(public key)的散列，计算方法如下：

```python
if 正式网络
  Version=0x00
else if 测试网络
  Version=0x6F
end
key_hash=Version+RIPEMD-160(SHA-256(public_key))
Checksum = SHA-256(SHA-256(Key hash))[0..3]  #取两次散列值后的前4位
Bitcoin_Address = Base58Encode(Key_hash+Checksum)
#Base58编码做了特殊处理，与通用的base58有一些区别：转换的时候
#前面的0被作为单个0保留。
```

![](bitcoin-dc-validate.png)


Bitcoin 电子货币系统的核心功能是面对面（点对点）支付，就像真实货币一样，无需中间人，
几乎不需要交易费。它背后的技术实现是很巧妙的通过将造币(Mint)，交易(transaction，
这里提到的交易都是特指的支付)，交易验证(transaction verifiction)交织在一起，形成一
个完美的圆。所以要想把它的机理理解清楚，就必须同时理解bitcoin的电子货币，交易，
造币的确切含义。

首先从电子货币谈起。


### 电子货币和交易单(Transaction)


Bitcoin电子货币解决的是：

1. 任意造币的问题：通过“挖矿”机制保证了不能任意造币。
2. 重复花钱的问题(Double-Spending)：利用P2P网络，通过HashCash的机制。


事实上Bitcoin系统中不存在独立的电子货币，货币值是依附于交易单存在的，
所以在bitcoin中的电子货币的实质就是交易单，确切的说是货币交易（Transactions）
的 数字签名链，它的数字签名算法使用的是ECDSA（[椭圆曲线数字签名算法](http://www.secg.org/collateral/sec2_final.pdf) secp256k1曲线）进行签名的。

交易单的数据如下：

```
In:
Previous tx: f5d8ee39a430901c91a5917b9f2dc19d6d1a0e9cea205b009ca73dd0
4470b9a6
Index: 0
scriptSig: 304502206e21798a42fae0e854281abd38bacd1aeed3ee3738d9e1446
618c4571d1090db022100e2ac980643b0b82c0e88ffdfec6b64e3e6ba35e7ba5fd
d7d5d6cc8d25c6b241501

Out:
Value: 5000000000
scriptPubKey: OP_DUP OP_HASH160 404371705fa9bd789a2fcd52d2c580b65d35
549d OP_EQUALVERIFY OP_CHECKSIG
```

交易单记录的是本次交易的收入来源(in)和支出(out)。当你支出（给）一笔钱的时候，
首先在交易单中就要描述清楚你要支出(out)的钱的收入来源(in)，然后在支出(out)
项中，指明要支出的金额，以及通过脚本的形式写明接收者的公钥，然后用自己的私钥
签名(scriptSig)认可该笔交易，最后将交易单广播到网络。

收入来源(in):

* Previous tx: 为收入来源交易单的散列值，也就是待支付的钱是谁给你的，经常会有多个收入来源被列在交易单中
* index: 指明是收入来源交易单中具体哪一个out，也就是Previous tx交易单中的out索引值（因为out也可以有多个）。
* scriptSig: 拥有者对该交易的ECDSA签名认可。

接收对象(out):

* Value: 发送的币值，以Satoshi 为单位，1BTC = 100,000,000 Satoshi
* scriptPubKey: 接收方的公钥脚本。


in与out的关系：


* 每一笔交易，out的总额应该等于in的总额。但是，在这个交易单里，只会有out的Value，没有in的Value，而是通过in的Pervious与index，追溯到上一个交易单的某一个out，获得Value。
* 一次send bitcoin，剩下的钱，应该out给自己，否则这个钱就丢了。


情况列举：


* 我有10个BTC，是某一次交易获得的，我要送给朋友A，10个BTC。这时候，有一个in，一个out。
* 我有10个BTC，是某一次交易获得的，我要送给朋友A，5个BTC，这时候，有一个in，两个out，一个指向朋友5个BTC，一个指向我自己，得到剩下的5个BTC。
* 我有10个BTC，是以前的两次交易获得的，我要送给朋友A，10个BTC，这时候，有两个in，一个out。
* 我有10个BTC，是以前的两次交易获得的，其中一次获得了6个BTC，另一次获得了4个BTC，我要送给我的朋友7个BTC，这时候，有两个in，两个out。



```c++
// An input of a transaction.  It contains the location of the previous
// transaction's output that it claims and a signature that matches the
// output's public key.
//
class CTxIn
{
public:
    COutPoint prevout;
    CScript scriptSig;
    unsigned int nSequence;
    //....
}

//
// An output of a transaction.  It contains the public key that the next input
// must be able to sign with to claim it.
//
class CTxOut
{
public:
    int64 nValue;
    CScript scriptPubKey;
    //....
}

//
// The basic transaction that is broadcasted on the network and contained in
// blocks.  A transaction can contain multiple inputs and outputs.
//
class CTransaction
{
public:
    int nVersion;
    std::vector<CTxIn> vin;
    std::vector<CTxOut> vout;
    unsigned int nLockTime;

    //....
```

每一笔交易单验证追查到最后，第一笔总是“挖矿”所得，这被称为coinbase。
如果是第一次“挖矿”所得，电子货币的内容用JSON格式表示如下：

```json
{
  "hash":"b3141455cb397e42665b90b3726c4770fd36101715618718111403bc780ceaa2",
  "ver":1,
  "vin_sz":1,
  "vout_sz":1,
  "lock_time":0,
  "size":135,
  "in":[
    {
      "prev_out":{
        "hash":"0000000000000000000000000000000000000000000000000000000000000000",
        "n":4294967295
      },
      "coinbase":"042194261a02f200"
    }
  ],
  "out":[
    {
      "value":"50.01000000",
      "scriptPubKey":"0452d1a02ffeacfc0c78fcf2ceeaf04d5416c15af1c65da13d9cdaa56844c825c1aa2f540e9439bf38a43419002d8441eea627cb56d6ed51e7848da5c3f6eee6ec OP_CHECKSIG"
    }
  ]
}
```

每一笔交易都会向整个P2P网络广播该货币的交易记录。通过投票机制，来决定该支付交易是否正常。如节点认为该交易记录是正常的那么就通过CPU计算POW(Proof-of-Work),然后广播，其它节点收到这个POW可以继续投票，形成Block 链（见挖矿）。如果节点收到不一致的两个交易记录，那么只信任链最长的。如果一笔Bitcoin被支出两次的情况广播出来，那么某些节点将先看到它第一次发生的支付交易，其他节点则看到的是它第二次发生的支付交易。究竟是哪一个支付交易“赢”了，则是由恰好创建了下一个block的那个节点来决定 —— 无论是哪个节点找到了“小的散列值”， 它的block中包含的那个支付交易被判断为有效的，其他的支付交易被视为无效。


接下来讲讲交易单的类型和交易验证的实现细节。

## 交易的类型与验证


交易单(Transaction)目前被bitcoin分为3种：

1. 按IP地址转账(Transfer)
2. 按接收地址转账(Transfer)
3. 造币(Generation)

通过前面对交易单的描述，我想大家应该已经知道，交易的验证是通过不断的追溯交易单来完成的。那么交易验证的细节是如何实现的，bitcoin的交易验证的实现细节是很意思的，它是通过脚本来实现验证的，这样bitcoin就实现了一个可被脚本扩展的行为，更加广义的"交易"，这可以保证足够的灵活性和可扩展，可以想象也许以后会有真正的分布式计算任务跑在上面作为一笔交易。因此要想讲清楚验证的细节，就不得不从脚本系统讲起了。


### 脚本系统


Bitcoin的脚本系统是使用类[FORTH](http://en.wikipedia.org/wiki/FORTH)语言（FORTH在嵌入式设备中是我最喜欢的一种语言）实现的，FORTH系统是面向栈的“高级机器”语言，它兼具了高级语言的特性（面向WORD）和机器语言的高性能与小尺寸，唯一的缺点就是可读性不高，基本上可以把FORTH当一种高级的机器语言吧。Bitcoin在实现上做了许多简化和特殊实现，所以只能算是类FORTH的系统。

在[FORTH](http://en.wikipedia.org/wiki/FORTH)系统中所有的命令(函数)都被称为单词（WORD），所有数据的处理都要压入数据栈上进行，所以FORTH被称为面向栈的语言。
比如 1和2相加，在FORTH系统中则是 `1 2 ＋`，数字 1，2 表示将它们压入到数据栈中（在FORTH解释器执行后实际指令会有`OP_PUSH`），＋的操作则是将栈顶和次栈顶的数字取出并相加，并将结果压回数据栈。

Bitcoin的脚本系统的所有的操作指令（单词）见后面的附录，不是所有的操作指令都能被执行支持，因为安全上的考虑有的操作指令被禁止掉了，比如大多数的字符串操作和乘除运算。

在FORTH系统中一般会定义该系统是8位FORTH, 16位FORTH还是32/64位FORTH，这和数据栈的值长有关。在Bitcoin中的脚本系统使用的堆栈是用（`vector<vector<unsigned char> >`）来模拟的，它在数据栈的每一项都是以字符串的形式存放，它的数值是统一用CBigNum来运算的（读到这里应该明白为啥bitcoin会限制乘除运算了），每一次从数据栈中压入(`CBigNum.getvch()`)或者取出数值(`CastToBigNum(stacktop[-1])`)都要进行一次转换。看着这样的实现，让我有点发怵，本能的不喜欢，怎么能把高效的FORTH搞成这个样子。Bitcoin的脚本系统与FORTH一样，有两个堆栈，一个数据栈，在Bitcoin中被称为main stack,一个返回栈，在Bitcoin中被称为alt stack（事实上在Bitcoin中将alt stack作为数据栈的中转而还没有作为FORTH意义上的返回栈）. Bitcoin的脚本系统没有实现单词定义，流程跳转，循环控制（FOR, WHILE），对IF的实现非常丑陋。事实上我对Bitcoin的脚本实现不是十分认可，堆栈采用变长的数据值，直接将big number 作为opcode，导致每一次opcode执行开销无法控制，由于没有完整实现FORTH的控制指令，导致用trick的方式来实现IF指令，在bitcoin中也因此无法定义新的WORD。总之我很不喜欢bitcoin的这个脚本引擎实现(参见script.cpp)。

下一篇将接着介绍下和交易验证相关的几个操作符：`OP_DUP, OP_HASH160, OP_EQUALVERIFY , OP_CHECKSIG` 的功能，现在有点倦了。

``` c
enum opcodetype
{
    // push value
    OP_0=0,
    OP_FALSE=OP_0,
    OP_PUSHDATA1=76,
    OP_PUSHDATA2,
    OP_PUSHDATA4,
    OP_1NEGATE,
    OP_RESERVED,
    OP_1,
    OP_TRUE=OP_1,
    OP_2,
    OP_3,
    OP_4,
    OP_5,
    OP_6,
    OP_7,
    OP_8,
    OP_9,
    OP_10,
    OP_11,
    OP_12,
    OP_13,
    OP_14,
    OP_15,
    OP_16,

    // control
    OP_NOP,
    OP_VER,
    OP_IF,
    OP_NOTIF,
    OP_VERIF,
    OP_VERNOTIF,
    OP_ELSE,
    OP_ENDIF,
    OP_VERIFY,
    OP_RETURN,

    // stack ops
    OP_TOALTSTACK,
    OP_FROMALTSTACK,
    OP_2DROP,
    OP_2DUP,
    OP_3DUP,
    OP_2OVER,
    OP_2ROT,
    OP_2SWAP,
    OP_IFDUP,
    OP_DEPTH,
    OP_DROP,
    OP_DUP,
    OP_NIP,
    OP_OVER,
    OP_PICK,
    OP_ROLL,
    OP_ROT,
    OP_SWAP,
    OP_TUCK,

    // splice ops
    OP_CAT,
    OP_SUBSTR,
    OP_LEFT,
    OP_RIGHT,
    OP_SIZE,

    // bit logic
    OP_INVERT,
    OP_AND,
    OP_OR,
    OP_XOR,
    OP_EQUAL,
    OP_EQUALVERIFY,
    OP_RESERVED1,
    OP_RESERVED2,

    // numeric
    OP_1ADD,
    OP_1SUB,
    OP_2MUL,
    OP_2DIV,
    OP_NEGATE,
    OP_ABS,
    OP_NOT,
    OP_0NOTEQUAL,

    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_MOD,
    OP_LSHIFT,
    OP_RSHIFT,

    OP_BOOLAND,
    OP_BOOLOR,
    OP_NUMEQUAL,
    OP_NUMEQUALVERIFY,
    OP_NUMNOTEQUAL,
    OP_LESSTHAN,
    OP_GREATERTHAN,
    OP_LESSTHANOREQUAL,
    OP_GREATERTHANOREQUAL,
    OP_MIN,
    OP_MAX,

    OP_WITHIN,

    // crypto
    OP_RIPEMD160,
    OP_SHA1,
    OP_SHA256,
    OP_HASH160,
    OP_HASH256,
    OP_CODESEPARATOR,
    OP_CHECKSIG,
    OP_CHECKSIGVERIFY,
    OP_CHECKMULTISIG,
    OP_CHECKMULTISIGVERIFY,

    // expansion
    OP_NOP1,
    OP_NOP2,
    OP_NOP3,
    OP_NOP4,
    OP_NOP5,
    OP_NOP6,
    OP_NOP7,
    OP_NOP8,
    OP_NOP9,
    OP_NOP10,

    // template matching params
    OP_PUBKEYHASH = 0xfd,
    OP_PUBKEY = 0xfe,

    OP_INVALIDOPCODE = 0xff
};
```

## 附录Bitcoin脚本系统单词列表




## 参见：[https://en.bitcoin.it/wiki/Script](https://en.bitcoin.it/wiki/Script)：




#### **常量**




#### 常量就是用来把数据压入栈中的单词：

| 单词             | 虚拟指令(opcode) | 输入       | 输出     | Description     |
| `OP_0, OP_FALSE` | 0                | Nothing.   | 0        | 压入数字0到栈中 |
| N/A              | 1-75             | (special)  | data     | 将紧随 _opcode_ 的data数据 opcode个字节压入到堆栈。opcode兼作数据长度指示。 |
| `OP_PUSHDATA1`   | 76               | (special)  | data     | 紧随该指令的下一个字节是被压入数据大小，然后是被压入数据 |
| `OP_PUSHDATA2`   | 77               | (special)  | data     | 紧随该指令的两个字节是被压入数据大小，然后是被压入数据. |
| `OP_PUSHDATA4`   | 78               | (special)  | data     | 紧随该指令的4个字节是被压入数据大小，然后是被压入数据. |
| `OP_1NEGATE`     | 79               | 无.        | -1       | 压入-1 |
| `OP_1, OP_TRUE`  | 81               | 无.        | 1        | 压入1. |
| `OP_2-OP_16`     | 82-96            | 无.        | 2-16     | 2－16被压入. |

### **控制流**


| 单词             | 虚拟指令(opcode) | 输入       | 输出     | Description     |
| `OP_NOP`         | 97               | 无         | 无       | 空指令.         |
| `OP_IF`          | 99               | <expression> if [statements] [else [statements]] endif | | If 判断指令，取出栈顶值，如果栈顶值为1, 则if后面的语句被执行，否则else中的语句被执行。 |
| `OP_NOTIF`       | 100              | <expression> ifnot [statements] [else [statements]] endif | | Ifnot 判断指令，取出栈顶值，如果栈顶值为0, 则if后面的语句被执行，否则else中的语句被执行。 |
| `OP_ELSE`        | 103              | <expression> if [statements] [else [statements]] endif | | 放置在 OP_IF 或OP_NOTIF 后的指令，当前面的条件不满足的时候执行 |
| `OP_ENDIF`       | 104              | <expression> if [statements] [else [statements]] endif |  | 结束  if/else 执行块. |
| `OP_VERIFY`      | 105              | True / false | Nothing / False | **标记交易单无效** 如果栈顶值不为真。当栈顶值为真，移除该栈顶值，否则保留该值。 |
| `OP_RETURN`      | 106              | Nothing      | Nothing  | **标记交易单无效**. |


### **堆栈操作**

| 单词              | opcode | 输入       | 输出         | Description      |
| `OP_TOALTSTACK`   | 107    | x1         | (alt)x1      | 从数据栈中弹出栈顶 数据，压入辅助栈。 |
| `OP_FROMALTSTACK` | 108    | (alt)x1    | x1           | 从辅助栈弹出栈顶数据压入到数据栈  |
| `OP_IFDUP`        | 115    | x          | x / x x      | 如果栈顶非0则复制栈顶  |
| `OP_DEPTH`        | 116    | Nothing    | <Stack size> | 获取堆栈数据个数 |
| `OP_DROP`         | 117    | x          | Nothing      | 丢弃栈顶数据. |
| `OP_DUP`          | 118    | x          | x x          | 复制栈顶数据. |
| `OP_NIP` | 119 | x1 x2 | x2 | 丢弃次栈顶数据 |
| `OP_OVER` | 120 | x1 x2 | x1 x2 x1 | 复制次栈顶数据到栈顶. |
| `OP_PICK` | 121 | xn ... x2 x1 x0 <n> | xn ... x2 x1 x0 xn | 复制第n项数据到栈顶. |
| `OP_ROLL` | 122 | xn ... x2 x1 x0 <n> | ... x2 x1 x0 xn | 将第n项数据移到栈顶. |
| `OP_ROT` | 123 | x1 x2 x3 | x2 x3 x1 | 栈顶3项数据向左旋转. |
| `OP_SWAP` | 124 | x1 x2 | x2 x1 | 栈顶2项数据交换. |
| `OP_TUCK` | 125 | x1 x2 | x2 x1 x2 | 栈顶数据复制并插入到次栈顶数据前 |
| `OP_2DROP` | 109 | x1 x2 | Nothing | 同 DROP，只是数据项是2项. |
| `OP_2DUP` | 110 | x1 x2 | x1 x2 x1 x2 | 同 DUP，只是数据项是2项. |
| `OP_3DUP`  | 111 | x1 x2 x3 | x1 x2 x3 x1 x2 x3 | 同 DUP，只是数据项是3项. |
| `OP_2OVER` | 112 | x1 x2 x3 x4 | x1 x2 x3 x4 x1 x2 | 同 OVER，只是数据项是2项. |
| `OP_2ROT` | 113 | x1 x2 x3 x4 x5 x6 | x3 x4 x5 x6 x1 x2 | 同 ROT，只是数据项是2项. |
| `OP_2SWAP` | 114 | x1 x2 x3 x4 | x3 x4 x1 x2 | 同 SWAP，只是数据项是2项. |


### **字符串处理**


字符串处理的大多数指令都被禁止了。


| 单词              | opcode | 输入       | 输出         | Description      |
| `OP_CAT` | 126 | x1 x2 | out |  Concatenates two strings. [禁止] |
| `OP_SUBSTR` | 127 | in begin size | out | Returns a section of a string. _[禁止]_ |
| `OP_LEFT` | 128 | in size | out | Keeps only characters left of the specified point in a string. _[禁止]_ |
| `OP_RIGHT` | 129 | in size | out | Keeps only characters right of the specified point in a string. _[禁止]_ |
| `OP_SIZE` | 130 | in | in size | 返回字符串长度 |


### **位运算**

| 单词              | opcode | 输入       | 输出         | Description      |
| `OP_INVERT` | 131 | in | out | Flips all of the bits in the input. _[禁止]_ |
| `OP_AND` | 132 | x1 x2 | out | Boolean _and_ between each bit in the inputs. _[禁止]_ |
| `OP_OR` | 133 | x1 x2 | out | Boolean _or_ between each bit in the inputs. _[禁止]_ |
| `OP_XOR` | 134 | x1 x2 | out | Boolean _exclusive or_ between each bit in the inputs. _[禁止]_ |
| `OP_EQUAL` | 135 | x1 x2 | True / false | Returns 1 if the inputs are exactly equal, 0 otherwise. |
| `OP_EQUALVERIFY` | 136 | x1 x2 | True / false | Same as OP_EQUAL, but runs OP_VERIFY afterward. |


### **数学运算**

| 单词              | opcode | 输入       | 输出         | Description      |
| `OP_1ADD` | 139 | in | out | 1 is added to the input. |
| `OP_1SUB` | 140 | in | out | 1 is subtracted from the input. |
| `OP_2MUL` | 141 | in | out | The input is multiplied by 2. _[禁止]_ |
| `OP_2DIV` | 142 | in | out | The input is divided by 2. _[禁止]_ |
| `OP_NEGATE` | 143 | in | out | The sign of the input is flipped. |
| `OP_ABS` | 144 | in | out | The input is made positive. |
| `OP_NOT` | 145 | in | out | If the input is 0 or 1, it is flipped. Otherwise the output will be 0. |
| `OP_0NOTEQUAL` | 146 | in | out | Returns 1 if the input is 0. 0 otherwise. |
| `OP_ADD` | 147 | a b | out | a is added to b. |
| `OP_SUB` | 148 | a b | out | b is subtracted from a. |
| `OP_MUL` | 149 | a b | out | a is multiplied by b. _[禁止]_ |
| `OP_DIV` | 150 | a b | out | a is divided by b. _[禁止]_ |
| `OP_MOD` | 151 | a b | out | Returns the remainder after dividing a by b. _[禁止]_ |
| `OP_LSHIFT` | 152 | a b | out | Shifts a left b bits, preserving sign. _[禁止]_ |
| `OP_RSHIFT` | 153 | a b | out | Shifts a right b bits, preserving sign. _[禁止]_ |
| `OP_BOOLAND` | 154 | a b | out | If both a and b are not 0, the output is 1. Otherwise 0. |
| `OP_BOOLOR` | 155 | a b | out | If a or b is not 0, the output is 1. Otherwise 0. |
| `OP_NUMEQUAL` | 156 | a b | out | Returns 1 if the numbers are equal, 0 otherwise. |
| `OP_NUMEQUALVERIFY` | 157 | a b | out | Same as OP_NUMEQUAL, but runs OP_VERIFY afterward. |
| `OP_NUMNOTEQUAL` | 158 | a b | out | Returns 1 if the numbers are not equal, 0 otherwise. |
| `OP_LESSTHAN` | 159 | a b | out | Returns 1 if a is less than b, 0 otherwise. |
| `OP_GREATERTHAN` | 160 | a b | out | Returns 1 if a is greater than b, 0 otherwise. |
| `OP_LESSTHANOREQUAL` | 161 | a b | out | Returns 1 if a is less than or equal to b, 0 otherwise. |
| `OP_GREATERTHANOREQUAL` | 162 | a b | out | Returns 1 if a is greater than or equal to b, 0 otherwise. |
| `OP_MIN` | 163 | a b | out | Returns the smaller of a and b. |
| `OP_MAX` | 164 | a b | out | Returns the larger of a and b. |
| `OP_WITHIN` | 165 | x min max | out | Returns 1 if x is within the specified range (left-inclusive), 0 otherwise. |

### **加密相关**

| 单词              | opcode | 输入       | 输出         | Description      |
| `OP_RIPEMD160`    | 166 | in | hash | The input is hashed using RIPEMD-160. |
| `OP_SHA1` | 167 | in | hash | The input is hashed using SHA-1. |
| `OP_SHA256` | 168 | in | hash | The input is hashed using SHA-256. |
| `OP_HASH160` | 169 | in | hash | The input is hashed twice: first with SHA-256 and then with RIPEMD-160. |
| `OP_HASH256` | 170 | in | hash | The input is hashed two times with SHA-256. |
| `OP_CODESEPARATOR` | 171 | Nothing | Nothing | All of the signature checking words will only match signatures to the data after the most recently-executed `OP_CODESEPARATOR`. |
| [OP_CHECKSIG](https://en.bitcoin.it/wiki/OP_CHECKSIG) | 172 | sig pubkey | True / false | The entire transaction's outputs, inputs, and script (from the most recently-executed `OP_CODESEPARATOR` to the end) are hashed. The signature used by `OP_CHECKSIG` must be a valid signature for this hash and public key. If it is, 1 is returned, 0 otherwise. |
| `OP_CHECKSIGVERIFY` | 173 | sig pubkey | True / false | Same as `OP_CHECKSIG`, but `OP_VERIFY` is executed afterward. |
| `OP_CHECKMULTISIG` | 174 | sig1 sig2 ... <number of signatures> pub1 pub2 <number of public keys> | True / False | For each signature and public key pair, OP_CHECKSIG is executed. If more public keys than signatures are listed, some key/sig pairs can fail. All signatures need to match a public key. If all signatures are valid, 1 is returned, 0 otherwise. |
| `OP_CHECKMULTISIGVERIFY` | 175 | sig1 sig2 ... <number of signatures> pub1 pub2 ... <number of public keys> | True / False | Same as `OP_CHECKMULTISIG`, but `OP_VERIFY` is executed afterward. |

### **伪词（Pseudo-words）**


下列词汇用于在内部使用，在脚本系统中实际上不存在的词。

| 单词              | opcode  | Description      |
| `OP_PUBKEYHASH` | 253 | 表示OP_HASH160 后的公开密钥散列 |
| `OP_PUBKEY` | 254 | 表示一个公开密钥（可以被 `OP_CHECKSIG`）. |
| `OP_INVALIDOPCODE` | 255 | |


### **保留词（Reserved words）**


没有被定义的opcode被保留以后使用，如果在脚本中使用这些保留词，要么被忽略，要么使得交易无效。

| Word | Opcode | When used... |
| `OP_RESERVED` | 80 | Transaction is invalid |
| `OP_VER` | 98 | Transaction is invalid |
| `OP_VERIF` | 101 | Transaction is invalid |
| `OP_VERNOTIF` | 102 | Transaction is invalid |
| `OP_RESERVED1` | 137 | Transaction is invalid |
| `OP_RESERVED2` | 138 | Transaction is invalid |
| `OP_NOP1-OP_NOP10` | 176-185 | The word is ignored. |

Ok，接着描述交易验证的具体的过程。

## 涉及的脚本命令（操作符）

首先讲讲涉及到的脚本命令（操作符），描述栈顶项的变化方式如下：(n1 n2 --  )  用 "--"分隔操作符执行前后的栈中元素的变化，左边表示操作前，右边表示操作后。最右边的项表示栈顶元素。这里例子中，n2 表示栈顶，n1表示次栈顶，操作后n1,n2均被弹出。

* OP_EQUAL(n1 n2 -- true/false): 判断栈顶两项是否相等的脚本命令，如果相等则压入true，否则false
* OP_VERIFY(true/false -- NOTHING/false):  如果栈顶项为true，标记改交易单为有效，否则失败，压入false并返回
* OP_CODESEPARATOR( -- ): 将当前执行PC(ProgramCount)保存到变量： pbegincodehash
* OP_CHECKSIG(<sig> <pubKey>-- true/false): 校验收入来源(in)的签名是否有效。栈顶是公开密钥(PubKey)，次栈顶是签名(Sig)。如果验证通过会压入True，否则压入False。
* `OP_EQUALVERIFY`(n1 n2 -- NOTHING/false): 等于 `OP_EQUAL` `OP_VERIFY` 两个操作符的联合。


## 交易验证


以最常见的接收地址交易转账为例描述交易验证的过程（SendMoneyToBitcoinAddress）

首先示例交易如下：

```json
{
  "hash":"23c9e8a3140938a65c73fa0712b1d8614c8eeef486a4ab14107fcce54fbf768c",
  "ver":1,
  "vin_sz":1,
  "vout_sz":2,
  "lock_time":0,
  "size":258,
  "in":[
    {
      "prev_out":{
        "hash":"0740c9ecdef03e46e4c0f74833db5af3cb24c7d48810ef73411662252046f9c6",
        "n":0
      },
      "scriptSig":"304502204028931b310bfec094bbd04275f69beba6bf5f44ab3dbbec9564c34ef9bc1ddc022100d37c214e978808099fc96006b41244d31b203eb4b1c69be9d57b0e2f843ad93501
      0481f6d0a51bfecb5112f223807ba668c67ac975fb096d07ef65b852a6864d9e9c18c9c16e5887c3f03be519fd42cae52f6d1a05d10a2fa7c783b19e9b74be07d6"
    }
  ],
  "out":[
    {
      "value":"12.99000000",
      "scriptPubKey":"OP_DUP OP_HASH160 ef055cb1e8e192cbd8b6a89ccf1eb73552d9764b OP_EQUALVERIFY OP_CHECKSIG"
    },
    {
      "value":"17.00000000",
      "scriptPubKey":"OP_DUP OP_HASH160 923f3cdf648c1755455a17097d22f0be6add7c7c OP_EQUALVERIFY OP_CHECKSIG"
    }
  ]
}
```

ScriptSig(<sig> <pubKey>): 中有两个值，一是当前拥有者的该交易单的签名，二是拥有者的公开密钥（用来验证签名）。

```
Sig: 304502204028931b310bfec094bbd04275f69beba6bf5f44ab3dbbec9564
c34ef9bc1ddc022100d37c214e978808099fc96006b41244d31b203eb4b1c69
be9d57b0e2f843ad93501

PubKey:0481f6d0a51bfecb5112f223807ba668c67ac975fb096d07ef65b852a6
864d9e9c18c9c16e5887c3f03be519fd42cae52f6d1a05d10a2fa7c783b19e9b7
4be07d6
```

脚本执行验证过程：

* 执行 scriptSig:
  * 压入 <sig> 和 <pubKey> : <sig> <pubKey>
* 执行 scriptPubKey:
* `OP_DUP` 复制栈顶<pubKey>: <sig> <pubKey> <pubKey>
* `OP_HASH160` 对栈顶项做HASH160（RIPEMD-160(SHA256(<pubKey>)）散列: <sig> <pubKey> <pubKeyhashA>
* <pubKeyHash> : 压入 <pubKeyHash>
* `OP_EQUALVERIFY`: 对栈顶两个元素 <pubKeyHashA> <pubKeyHash> 做是否相等校验，如果不相等那么标记交易单无效并返回，如果等于继续： <sig> <pubKey>
* `OP_CHECKSIG`: 校验收入来源的In的签名是否有效，根据pubKey去校验签名<sig>，签名的内容为交易单的Ins, Outs和脚本(从最近一次的 `OP_CODESEPARATOR` 到脚本结束的位置)的散列。 PubKey.Verify(SignatureHash(scriptCode, nIn, Outs), Sig)

![](./bitcoin-pubkey-sig.png)

```c
//nIn 当前的交易单的in的索引号
//scriptCode: 保存的当前执行的代码从OP_CODESEPARATOR（如果没有就从脚本开始） 到脚本结束。
uint256 SignatureHash(CScript scriptCode, const CTransaction& txTo, unsigned int nIn, int nHashType)
{
    if (nIn >= txTo.vin.size())
    {
        printf("ERROR: SignatureHash() : nIn=%d out of range\n", nIn);
        return 1;
    }
    CTransaction txTmp(txTo);

    // In case concatenating two scripts ends up with two codeseparators,
    // or an extra one at the end, this prevents all those possible incompatibilities.
    scriptCode.FindAndDelete(CScript(OP_CODESEPARATOR));

    // Blank out other inputs' signatures
    for (int i = 0; i < txTmp.vin.size(); i++)
        txTmp.vin[i].scriptSig = CScript();
    txTmp.vin[nIn].scriptSig = scriptCode;

    // Blank out some of the outputs
    if ((nHashType & 0x1f) == SIGHASH_NONE)
    {
        // Wildcard payee
        txTmp.vout.clear();

        // Let the others update at will
        for (int i = 0; i < txTmp.vin.size(); i++)
            if (i != nIn)
                txTmp.vin[i].nSequence = 0;
    }
    else if ((nHashType & 0x1f) == SIGHASH_SINGLE)
    {
        // Only lockin the txout payee at same index as txin
        unsigned int nOut = nIn;
        if (nOut >= txTmp.vout.size())
        {
            printf("ERROR: SignatureHash() : nOut=%d out of range\n", nOut);
            return 1;
        }
        txTmp.vout.resize(nOut+1);
        for (int i = 0; i < nOut; i++)
            txTmp.vout[i].SetNull();

        // Let the others update at will
        for (int i = 0; i < txTmp.vin.size(); i++)
            if (i != nIn)
                txTmp.vin[i].nSequence = 0;
    }

    // Blank out other inputs completely, not recommended for open transactions
    if (nHashType & SIGHASH_ANYONECANPAY)
    {
        txTmp.vin[0] = txTmp.vin[nIn];
        txTmp.vin.resize(1);
    }

    // Serialize and hash
    CDataStream ss(SER_GETHASH);
    ss.reserve(10000);
    ss << txTmp << nHashType;
    return Hash(ss.begin(), ss.end());
}
```


# 挖矿与块（Blocks）


接下来讲的是什么是挖矿，以及交易单在P2P网络上的存放，其实这个过程也是挖矿的过程。

所有的交易单是以Block的形式在Bitcoin P2P网络上存放的。每一个Block包含了最近所有的有效交易单。Block中最为重要数据为：

* 最近交易单集合
* Nonce随机数
* 前一个块的散列值


在造币的Node总在侦听网络，接收信息，然后各自将接收到的新交易打包到一个新block（CBlock Class in main.h）。在块交易单集合中的第一个交易单总是“造币单”：给创建该块的人以新的货币，节点只需要校验货币金额是否合法即可：形成一个合法的新块得到的回报是初始金额为50BTC，每产生210,000块的时候这个金额减半(大约每隔4年会发生一次)。产生合法的新块是不容易的，需要通过无数次的计算尝试得到，另外如果大家都在计算同一个新块，那么还存在竞争关系，这个时候只有最困难（Difficulty）的那个块（指整个块链的困难度值加起来最大的）才会被网络认可。另外如果块中的某笔交易size大于该块中交易单的平均size，那么该笔交易单会被收取一笔小的交易费用。


## 块的数据结构


块的数据结构可以分为块头（block header）和块体（block body）


### 块头（Block Header）


块头的数据是用于校验块、产生块ID（256位散列值），这个块ID也是决定块是否合法的数字。计算块ID的公式如下：

```java
BlockID = SHA256(SHA256(Block_Header));
```

块头(Block Header)的内容如下：

* ver: 版本号（4字节）
* prev_block: 前一个块的256位散列值
* mrkl_root: 所有交易单的256位散列
* time: 时间戳（4字节）
* Bits: 一个紧凑格式的4字节的数字，它表示一个256位的当前目标（Target）数值，这也表示困难度（Difficulty），最后产生块的ID值必须不大于目标值才能被接受（如果有多人同时产生同一个块，那么最困难的将被接受）。这个数值会每隔2016个block(网络大约每小时创建6个块，创建2016块大约2周)调整一次，当产生前一个2016块的时间大于2周的时候，难度值将会被调低，当小于两周的时候难度值将被调高（关于Target和Difficulty详见后述）。
* nonce: 32位随机数。节点在产生Block的时候，会增量尝试改变nonce的值，直到产生的块的散列值符合bits的要求




### 计算目标(Target)和困难度(Difficulty)


#### 计算目标（Target）


计算目标（Target）是一个256位的数值，块的散列值ID必须小于或等于该目标数值，放可被接受。块头中的BITS是一个用紧凑的4字节格式表示的目标（Target）数值，它表示一个256位的当前目标数值，方式如下：

```java
//假设BITS为：
BITS = 0x1B0406CC;
//那么target的数值则是：
Target = 0x0406CC * 2^(8*(0x1B-3))= 0x00000000000406CC000000000000000000000000000000000000000000000000;
```



#### 当前网络的目标值为：[Current target](http://blockexplorer.com/q/hextarget)。


#### 困难度(Difficulty)


困难度(`Difficulty`)表示该块ID的计算难度，值越大表示越困难，1表示最容易。

1困难度（`Difficulty`）的Target被定义为：

```
0x1D00FFFF(BITS)
```

展开后：

```
0x00FFFF * 2^(8*(0x1D - 3)) = 0x00000000FFFF0000000000000000000000000000000000000000000000000000
```

因此困难度的计算公式为：`1 困难度（Target） / 当前目标`

我们可以在这里查看当前网络的困难度：[Current difficulty](http://blockexplorer.com/q/getdifficulty)（BitCoin的 getDifficulty 接口输出）。也可以通过这个网站查看困难度值的变化情况图：[Graphs](http://bitcoin.sipa.be/)。

#### 块体（Block Body）

`Block Body` 实际上就是交易单的集合。

你可以在这个网站上看到当前网络所有的交易单（Blocks）:  [https://blockexplorer.com/](https://blockexplorer.com/)

一个具体的块的示例：

```json
{
   //hash: 自身ID的sha256散列值
  "hash":"0000000000001470ed62a9d73c1c74a4b3754e18db0abb057be5ad5ffed659bb",
  "ver":1,
  "prev_block":"000000000000158a4051185f339d59227b776ac6bfe6120fa18293b5c08644a8",
  "mrkl_root":"c5341062635c427b79a730dca8d4a5eb6a482fa21f82cc37c84ae01ea5945fc3",
  "time":1307565484,
  "bits":438145839,
  "nonce":2323396371,
  //交易单数量
  "n_tx":6,
  "size":2193,
  "tx":[
    {
      "hash":"67dbdbc6c4a49bc3364d34aebe76b6f470ced66eb731f9d099d0da6c58e466cf",
      "ver":1,
      "vin_sz":1,
      "vout_sz":1,
      "lock_time":0,
      "size":135,
      "in":[
        {
          "prev_out":{
            "hash":"0000000000000000000000000000000000000000000000000000000000000000",
            "n":4294967295
          },
          "coinbase":"042f931d1a022301"
        }
      ],
      "out":[
        {
          "value":"50.04000000",
          "scriptPubKey":"049db428c19890bb7706bebdcf69a93c192daef8a73eb7035e2600468b4e1f83d4c2134640f6c619e5521c2050ebc9be9e9c502fdab655a570236418e5c2e95137 OP_CHECKSIG"
        }
      ]
    },
    {
      "hash":"c96eb8f874d105e24121cdc5918440c85af27b797013679796fcc26e40938ad2",
      "ver":1,
      "vin_sz":1,
      "vout_sz":2,
      "lock_time":0,
      "size":258,
      "in":[
        {
          "prev_out":{
            "hash":"c8caedb7edb2665b8543916a1e6b1dee2bf1733f75b4604c423db08efa570d65",
            "n":0
          },
          "scriptSig":"3045022100b47c10ebd2413c575510563363fe9cad7f0fdcbefca9dd219bd345bcfeff98a1022049d7037c0be3493650cb2a410a655394678e75a28b8f4cd587644813ccee383801
          041f5853d9d43b81af0999a4add012e6580db5edc7dabf99bc2aff1a01b1296e7004b73b10a9e2d3ebe0d7377c545aacc56e24aff1c9b130e0721332315e414f72"
        }
      ],
      "out":[
        {
          "value":"3.98000000",
          "scriptPubKey":"OP_DUP OP_HASH160 22718315d786b8f64510be88ad590760de676a59 OP_EQUALVERIFY OP_CHECKSIG"
        },
        {
          "value":"0.01000000",
          "scriptPubKey":"OP_DUP OP_HASH160 d52804c9bc12e7a7186e53b41784dcd2afed9a92 OP_EQUALVERIFY OP_CHECKSIG"
        }
      ]
    },
    {
      "hash":"cd74421dd3d32346bdbef02cde4bc0ed19b5cc15621f761b465a869b2f51287c",
      "ver":1,
      "vin_sz":2,
      "vout_sz":2,
      "lock_time":0,
      "size":437,
      "in":[
        {
          "prev_out":{
            "hash":"e38b71a89071be2820ce95841da03ba8bac77d536d9ac5fe5347136e9bbca104",
            "n":1
          },
          "scriptSig":"3045022100ed5c3626adf84a6d364d7b58fb182ee3bd35758a883ebe2e642e83f4103e91cd022063f61a1d89c1a30f713c2ca277c08c1c4ceb585babef82301f738fdc2312329d01
          047b4277bb4c23988986c44552156130d4155a1020ec411ca4a07904191d9054de705ec2b79a46155a0d59e8a39b5d450ac73d485b082789b6dad55d5e2230f597"
        },
        {
          "prev_out":{
            "hash":"a6fc46a5a4a6b202c644cc4854feb2d8cf7befcf695ad810346c8dfb4cc18138",
            "n":1
          },
          "scriptSig":"304402207de219304bfca0e2d93524a2547767ce5044501bb0d9107e04d35cf3d644136d02201244a1ce47c2f3aab6c205e75e433371efb01dad5073d316bf68488ea1ad064301
          04d74d74c0f2bd415a94090c83bbe10b4949c7ee8f3bb957352d02fb50f3e1ddc5ab79a28b1228eaf2986339a3735e32869019d4894f34a46645288a68900ef6a5"
        }
      ],
      "out":[
        {
          "value":"0.01000000",
          "scriptPubKey":"OP_DUP OP_HASH160 e95281e139fc37bb2aabd84028835c6513a6ac99 OP_EQUALVERIFY OP_CHECKSIG"
        },
        {
          "value":"2.01000000",
          "scriptPubKey":"OP_DUP OP_HASH160 234c6c8644008de240d90753904789868100786c OP_EQUALVERIFY OP_CHECKSIG"
        }
      ]
    },
    {
      "hash":"9d4f130995dbc1ddc5346c109992c0779aa44122195eff51dc00109afc5cad7d",
      "ver":1,
      "vin_sz":1,
      "vout_sz":2,
      "lock_time":0,
      "size":258,
      "in":[
        {
          "prev_out":{
            "hash":"d84cd74d4b470f96379fa9737c43be544e4e57f33e83fc8bf26f232ec5ea97b5",
            "n":0
          },
          "scriptSig":"3045022100d8f3bbb19b4d2593649b4f6ac0074a772ff78fce1fb60e7957c7d99d2627931802205ad4774f58af0b52e37f87592bea7bae84c883c9230e722962f2e52e7eb061e201
          04732060c3f57ccc0703e05f86f442e45617b446ebca7e9f6c96ca1ec754b9d8a9f2bd727a15c7821cbca0498c2b7f60081873a450f29c5937e9593407166dc71b"
        }
      ],
      "out":[
        {
          "value":"30.26538895",
          "scriptPubKey":"OP_DUP OP_HASH160 7fa1d78819360231c6bc1b23ff644e9124da075f OP_EQUALVERIFY OP_CHECKSIG"
        },
        {
          "value":"4.76000000",
          "scriptPubKey":"OP_DUP OP_HASH160 847f4729a1464d7a2103796cca32022fe0481d58 OP_EQUALVERIFY OP_CHECKSIG"
        }
      ]
    },
    {
      "hash":"68050dc3810310e1e5e9eb3464b1581a353de523a6f26d8b978370bd63880eb7",
      "ver":1,
      "vin_sz":4,
      "vout_sz":1,
      "lock_time":0,
      "size":766,
      "in":[
        {
          "prev_out":{
            "hash":"07a39559553efb329af1538e0fc8a037f20048a83b2278a5041975054e425c3e",
            "n":17
          },
          "scriptSig":"3046022100c3ce1ee6c222d74ff9c97d5729e5c6702c3cabdb61ea0fb3ae8632eae36f03fb0221009cea5a9f94fe14e4673fd87f75750e1d151f6e846c371d8e4af72b5d213bb5c001
          04ee9e80055248ed804ca6724b2d784c91eec04abdc4ec00b14dc01e56c90513a85453026acf90f1cb1bdd3e3ca07035be40d0b3e3ac6076b5b12bd3234ac8c20b"
        },
        {
          "prev_out":{
            "hash":"07f95bfdd09e98bf7ce0543e8fdd82f9e8532449ab7167f69aa3d1f030399b96",
            "n":0
          },
          "scriptSig":"3044022011f922460d01986255a6f5e5ce88586bb3a9a32edc836e420d2347dae9df12e1022018d9d4e48dea2b821e01d3253dfaa03af801d01e79ab4eb3ef48f22f84f196aa01
          04398f321ea6140c6ad51fea724f7c13e1df6c43afb8e4f6f9ab2385b6e18d8eae52516a0b3487512a3dbeb36109d3fcb6391fbc156518c96f57467f97dc55d0a3"
        },
        {
          "prev_out":{
            "hash":"6c93900990b712fbf2a386ba53bc3aad8f5bcdda73b855a24628d7eae80cf3f9",
            "n":0
          },
          "scriptSig":"3046022100b688feeb1012f913b6366b5b9bd5313238d00b61b48a0e3956c33d1dffc9a1f2022100ed159808e8a732e646ba5af7ed5a0d896c7db0a10757aeccc9c58a67ec42ec7501
          047e79adbe50ae668041d2b08702c12de83fdaecb866b261755cbba27fe344c6fc67f3fc2593edc0bb053b0fde62c4d42d152b6525c10bde365d80a8d2d8d77a85"
        },
        {
          "prev_out":{
            "hash":"ed416acb1373bcce28ec63e6e600e0da7f8892b557591bc0386210c56e8c034f",
            "n":1
          },
          "scriptSig":"3046022100c1ffdf383d108a9b1e8e33ed3ef8bd6b368b1ed0584ac187eb0897c90422fc5b022100f7bfb8f0b17c3b121943622a4d04a8a818391c68028b6a63d9cd2536d9f3714501
          04ee9e80055248ed804ca6724b2d784c91eec04abdc4ec00b14dc01e56c90513a85453026acf90f1cb1bdd3e3ca07035be40d0b3e3ac6076b5b12bd3234ac8c20b"
        }
      ],
      "out":[
        {
          "value":"1.69000000",
          "scriptPubKey":"OP_DUP OP_HASH160 71b9ea593ba56d1159493cb2b37a03f368fb6c40 OP_EQUALVERIFY OP_CHECKSIG"
        }
      ]
    },
    {
      "hash":"4e6e47f0fa7a559219be309db20c5c17296956304cf47dc8c52910c24b505a92",
      "ver":1,
      "vin_sz":1,
      "vout_sz":2,
      "lock_time":0,
      "size":258,
      "in":[
        {
          "prev_out":{
            "hash":"897f67e6ec0b5a64b511c2052d05f0e2437811260041bb0915f2c40879025215",
            "n":1
          },
          "scriptSig":"304502200dbe53f77f947b12dfabb737e0862c1f2d37515f6293b06c08710ccdb69419d6022100b379ab597d8d17034f1654f20e68c72930050342884743869b6421ee7eaad83801
          04bdd996cd29ca3d34604306de8983d1fadf978ae43c12c1e832ce803ae57241cd7762a40dc1e5f6176ca3b0caac622c82e271b59c66fb1f8fa8225930a8807edf"
        }
      ],
      "out":[
        {
          "value":"0.04000000",
          "scriptPubKey":"OP_DUP OP_HASH160 50e44bb02555c7084e08cda95eb43a9c621fa0ac OP_EQUALVERIFY OP_CHECKSIG"
        },
        {
          "value":"0.03000000",
          "scriptPubKey":"OP_DUP OP_HASH160 ecd8f97222481950eed4f98db82455635ccb86b4 OP_EQUALVERIFY OP_CHECKSIG"
        }
      ]
    }
  ],
  "mrkl_tree":[
    "67dbdbc6c4a49bc3364d34aebe76b6f470ced66eb731f9d099d0da6c58e466cf",
    "c96eb8f874d105e24121cdc5918440c85af27b797013679796fcc26e40938ad2",
    "cd74421dd3d32346bdbef02cde4bc0ed19b5cc15621f761b465a869b2f51287c",
    "9d4f130995dbc1ddc5346c109992c0779aa44122195eff51dc00109afc5cad7d",
    "68050dc3810310e1e5e9eb3464b1581a353de523a6f26d8b978370bd63880eb7",
    "4e6e47f0fa7a559219be309db20c5c17296956304cf47dc8c52910c24b505a92",
    "f4462bd30c529d154dc1b35d8f68961441e09ffaceaa25da17eb1814101f8ad5",
    "1961263895b63d4760f81eda7ae94848eb68e2170b79a224ba704a3c21fd6feb",
    "0427a2dbd54fa6ec034d704336fa255f6c139e6d7b9bf803714cfbc9dcc61b85",
    "42441420d09c91336e69bae9f7eb39b1c6d90562028de3094bea5f675a25a082",
    "4af79ccb4bf857df3e75a50106b15ef35aa73a209efa5089f2f2193ff70ab93d",
    "c5341062635c427b79a730dca8d4a5eb6a482fa21f82cc37c84ae01ea5945fc3"
  ]
}
```

![bitcoin](./bitcoin-logo.jpg)
趁今早，把以前零碎的分析给整理出来作为问题和展望，就算对开源Bitcoin P2P 电子货币系统内幕最后一篇的小结。


# 问题


Bitcoin目前存在的问题其实是非常多的，目前Bitcoin的主要成就是解决了数字货币的两个核心问题，并在线上做了验证，取得了一定的实际经验。


## 已经解决的问题


Bitcoin 目前较好的解决了数字货币的两个核心问题：

* 货币伪造复制
* 货币重复花费

## 尚未解决的问题


在我看来 Bitcoin 其实只是一次试水，看看方案到底是否可行，从当前的试验结果看来，方案是可行的。这已经令人非常high了，但是这个方案现在看来还是比较粗糙的，许多细节需要完善，这里只提下最严重的问题。目前随着交易量的日益增加，当下最为严重的两个问题是关于存储和流量。


### 存储和流量问题


* 存储：目前每个节点上文件数据是684M(我记得上个月已经上G，初步猜测脚本算法终于增加了pruning算法，把存储和流量给降了下来)，但是这始终会随着交易量的增加而持续增加的。
* 流量：上个月，当连接数在115-130的时候，节点3小时内的流量大约143M。当在PC新安装Bitcoin客户端后全部获取900M交易单信息花了8小时。这个月因为算法改进，有所好转。
不过一旦参与的人数越来越多，交易日益频繁，这个上限依然存在。

目前Bitcoin网络上Block的总数为：137741 http://blockexplorer.com/q/getblockcount
平均块大小为：25460 http://blockexplorer.com/q/avgblocksize
那么所有块的总大小为：137741*25460=3506885860(bytes)=3344.427MB =3.266GB

Visa组织目前平均每年大约处理28.4*1000000000(Billion)笔交易，也就是平均每秒大约处理54000笔交易([参阅此处](http://www.creditcards.com/credit-card-news/credit-card-industry-facts-personal-debt-statistics-1276.php))。
而Bitcoin网络目前的最大处理能力只有每秒7笔交易。如果按照目前的处理方式，假设要每秒处理2000笔交易，
那么每秒的数据流量就会达到大约1G Bytes的样子。([参阅此处](https://en.bitcoin.it/wiki/Scalability))

存储和流量问题的根本原因在于：目前是完全对等的P2P交易系统，对于交易并没有分布式处理机制，
每一个节点都必须保持所有的历史交易单，而不是每一个节点上分担一部分。

这需要采用分布式处理(Map-Reduce)方式对交易进行处理，不需要所有的节点都保持所有的数据。
我以为可以设定如下的分布Mapping方式：

1. 保持自己相关的交易数据：只保持自己钱包中的货币相关交易。
2. 保持临近节点的交易数据：只对邻居节点服务
3. 保持交换的交易数据信息：如果对方节点保存了自己的相关交易则也为对方他的交易数据
4. 按远近程度决定服务对象：越远服务费高
5. 按远近切分成若干小网络：形成当地BTC货币，通过兑换维持各个网络之间的流通


### 断网的疑问


这是曹晓刚同学提出的，善意的说就是当海底光纤断掉后，两个网络之间没有别的连接通道的情况下
的重复花费问题。很遗憾，目前的Bitcoin体系中没有解决这样的问题。问题简化描述如下：

```
1A  2A
|   |
1B--2B
|   |
1C  2C
```

比如将节点1A上的钱包有25000BTC数据复制到了节点2A。
1A,1B,1C和2A,2B,2C两个网络之间仅仅通过节点1B和2B连接。现在1B,2B之间的连接断了。
在1A上的花费，和在2A上的花费就成了重复花费。

可能的解决办法：

1. 1A上得来的钱，广播验证，首先是本网络的节点做的验证居多。那么如果移到2A，并且断网，大部分验证的节点必然就不再存在。
2. 实名交易
3. Bitcoin 不再是一个大网，而是按网络远近切分的若干小网，见上述的分布式处理机制方案

通过兑换机制: A1B1C1产生的独立货币1，A2B2C2产生独立货币2，自由兑换。


### 囤积操纵市场问题


这几乎不算一个严重的问题，不过如果是限制了BTC总量（目前的算法是这样做的）。那么如果BTC被囤积操作市场，总感觉不对。
如何避免被BTC囤积？另外，Bitcoin币仅仅存在于wallet.dat文件中，如果该文件丢了，那么该wallet中的所有货币也就丢了。
如果足够长的时间内某一笔货币没有交易流通，那么就可以等效于失去了。

1. 也许回收长时间没有流通的BTC币是一个法子。
2. 也许刺激赋予活跃度高的BTC更高的价值也是一个法子。
3. 也许不应该限制BTC 总量，只需要能在网络中调控保持稳定的增加速率即可。

不过，这一块也许专门研究货币金融的专家才更有资格说话。


# 展望与未来


目前Bitcoin进入现实货币体制并能取代之，还为之过早，不过在私下的一些特殊场合可以取得一定现实货币的地位。

类似Bitcoin P2P虚拟货币体系的目前最大的应用场景也许是在游戏（非实体）世界上。这样使用者的利益可以得到最大限度的保障，不用担心公司的倒闭，也不用担心公司随意增发虚拟货币。更加方便快捷，可以在任意的游戏或者非实体体系中使用。

1. 游戏（虚拟）世界的主流货币
2. 分布式计算能力交换的计量单位
3. 自动化的分布式的兑换体系
4. 去中心化的钱包(decentralized wallet)
5. P2P的担保人（中间人）体系
6. 去中心化的认证体系(Decentralized OpenID)




