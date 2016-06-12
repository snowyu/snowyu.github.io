---
author: riceball
date: 2012-05-01 10:01:27+00:00
title: DIY与云计算（二）之 DIY自己的开源NAS
category :
  - Thinking
  - Cloud Computing
tags:
  - cloud computing
  - diy
  - nas
---

对于云计算存储而言，家用NAS存储是云计算存储的一个子集，它不用考虑迁移，LB，远程mount，存储集群的管理等等。相对与公共服务的云计算，家庭NAS就相当于家庭的数据中心了。家庭的各种数据能安全存放在NAS中。利用NAS家庭的其它电脑能方便的对它进行访问使用，以及在后面以极低的功耗默默下载，就算不在家，也能远程管理家里的下载，看到任何资源就能随时下载管理。
NAS提供给我们的功能有：

文件共享服务：现在很多人家中的电脑都不止一台，这样视频，照片、音乐、文件等数据资源分散在不同的电脑中，要去找出会很麻烦。通过家用NAS，家中的各个成员可以将想分享或共用的照片、音乐、影片或其他文件档案，分门别类地放在同一个网络硬盘中，避免相同的资料在每部电脑里浪费同样的空间。

数据备份服务：NAS一般都具有多种备份功能，包括本地备份、异地备份和NAS间备份等等。另外NAS还具有一键备份功能，将USB存储设备(如闪盘和外置硬盘)插入NAS上特定USB接口，就能把USB存储设备上的文件备份到NAS中。

家庭服务中心：通过把打印机与NAS相连，开启NAS网络打印机功能，我们就能在局域网中共同使用这台打印机，通过在NAS上建立Web服务，把照片和录像存放在NAS网络存储器的指定目录中，就能通过浏览器登陆NAS的Web网站进行观看，就像访问网络相册一样。另外在NAS中使用UPnP-AV功能(或称流媒体功能)，在网络中可以被Windows MCE系统、Xbox360和PS3等设备发现，无须额外的操作就能播放存储在NAS中的多媒体文件。同时我们还可以用NAS网络存储器搭建iTunes服务器，让iTunes软件和iPod等设备从NAS上获得音乐和视频。

## DIY NAS

技术要点：

* ITX 主板：节约空间，采用17x17 cm的小主板
* 低功耗(<=30W): NAS是要长年开机，为了尽可能的降低成本，节约起见，主板CPU功耗不高于30W
* 热插拔(>=4 盘位)：为了便于更换硬盘以及Raid5的要求，盘位要求>=4。
* Sata3接口：保护投资，为以后硬盘升级(SSD)准备
* 千兆网卡: 这是必须的，如果想直接在nAS上传输播放高清影片。
* CPU：性能至少要能保证软组Raid
* 内存(>=8G)：至少支持8G。


对于服务器而言如果是1U机箱可以塞4块ITX主板，甚至可以塞到6块ITX主板；如果是塞1块ITX主板，那么可以塞5－6块3.5的硬盘。

目前4盘位的NAS空机（不含硬盘）价格：


* 巴法络/buffalo LS-QVL/E-AP： 1400¥
  * 最大容量 8TB, 4xSata2, 2xUsb2, 1.6Ghz Marvell(88F6282A0C160) processor and 512MB of RAM.
* 群晖synology DS411j: 3000¥
  * 最大容量12TB, 4xSata2, 2xUsb2, CPU 1.2G, DDR2 128M RAM
* D-Link DNS-343: 2150¥
  * 4xSata2, CPU Marvell 88F5281-D0 C500Mhz, 128MB
* Century世特力裸族CRIB35NAS: 1980¥
  * 最大容量 12TB, unkown



从上述商业NAS系统来看，CPU大都是采用ARM芯片，内存也少得可怜，但是价格不菲。


## 我采购的硬件清单：

### 机箱：


* 4盘位热插拔机箱 498¥ 毛重 3.5Kg，1个12cm风扇，只能上半高的卡（可能以后扩硬Raid卡有问题)
* 6盘位热插拔机箱 849¥ 毛重 5 kg, 有足够的空间固定硬Raid卡，2个可调速9cm风扇。但是太重。性价比也不高(备选)


目前正在团购，上述为团购价格，应该在清理存货，机箱的问题：热插拔盒塑料有些薄，没有锁，机箱做工不够精细。


### 主板：


目前我在淘宝上看到的Intel Atom(D525) Mini-ITX平台(15W)上全部是Sata3支持的很少，混合Sata3和Sata2，太会节约成本了。而且最关键的是最大内存只到4G。可能Intel不希望有人把主板拿去做低功耗的文件服务器吧，故目前几乎不用考虑Intel的东西。

AMD的E350平台功耗大约在18W-20W，至少支持4个Sata3口，内存最大可以到8G，也有到16G的，两个DDR3 PC内存槽。

* ASROCK/华擎E350M1
  * 4Sata3口，
  * 1eStata3，
  * 内存DDR3 1066 最大16G,
  * 1xPCIe2.0x16,
  * 12xUSB2,
  * 1PCIEx1GNetwork,
  * 无USB3
  * 价格500¥上下
* 华硕E35M1-I（备选）
  * 6个Sata3口，
  * 内存DDR3 1066 最大8G，
  * 1个PCIe2.0x16(x4mode),
  * 12个Usb2，
  * 无Usb3,
  * eSata,
  * 1PCIEx1GNetwork
  * 淘宝上暂时买不到,只能买到 E35M1-I/E45M1 Dexlue 版本。



更多的内存还是更多的sata3口，这是个选择问题，而我选择了更多的内存。


E350的GPU为 ATI HD 6310 隶属于 Radeon™ HD 6300M Series Graphics：


* 80 个处理单元
* DX11
* OpenGL 4.1
* OpenCL™ 1.1
* DirectCompute 11


### 电源

采用 DC-ATX 电源：

计算功率：

单块硬盘

 * 开机功率：20w (12V*1.75A=21W)
 * 稳态功率：10w (5.3W)

>西数绿盘 WD20EARX 读/写功耗 5.30瓦; Idle: 3.3W; 速度： 110M/s


估算系统其它功耗：

* APU Idle(TDP) = 9-18W
* A51M(Hudson-M1) Chipsets = 4.7W
* CPU Fan= 5W
* Case Fan=3W
* eSata = 3W
* mouse = 1W
* keyboard =1W
* DDR3 1333 = 1W *2


按照4块硬盘全部插满的情况下估算：

* 开机总功率 ~ 21W*4+33W = 117W
* 稳态总功率 ~ 10W*4+29W(全负荷) = 69W

因此选用输出功率为130W的DC-ATX板:

* 输入: 11.7~13.6V
* 输出功率：额定130W，峰值150W
* 价格：58¥


电源适配器

* 12V 10A电源适配器(65¥): 在开机功率90W，平时功率50W负荷下，但是这个所谓120W的电源工作不了几天就歇菜了，退掉了。
* 12V 18A DELL的二手电源适配器(110¥): 目前运行良好，温度也还可以，还没有出问题。


内存条：

* Kingbox/黑金刚单条8G DDR3 1333 台式机内存(331¥)

总计花费：

* 机箱总价523 ＋ 主板(含APU) 513 ＋ 内存条 331 + DC-ATX 58 ＋ DC适配器 110 ＝ 1535¥

得到的是一个双核1.6G AMD CPU/GPU， 8G DDR3（可扩展为16G），全 SATA3 带高清播放支持的4盘位NAS机器。

正在DIY: 图已经丢失

组装完成，试机：图已经丢失


## 软件系统


如果只把它作为文件存储系统，那么因为ZFS的缘故，IllumOS(开源Solaris) 操作系统无疑是非常合适的，但是以这样的CPU性能来说，只作为文件存储系统，未免太浪费了。Linux社区的BTRFS文件系统进展缓慢（尤其是在软Raid功能上），而ZFS是由Sun开发的新型文件系统, 应用于Solaris上，后来被移植到FreeBSD和NetBSD系统上。

基于Solaris内核的NAS系统:

* OpenIndiana: [http://openindiana.org/](http://openindiana.org/)
* Nexentastor: 闭源，免费版最大支持16TB.

Linux Soft Raid:

* [BTRFS](https://btrfs.wiki.kernel.org/index.php/Main_Page)
* [OpenFiler]( https://www.openfiler.com/community/openfiler-community)
* [Native ZFS on Linux](http://zfsonlinux.org)

正巧最近看到国外社区已经有人在Native ZFS on Linux上做了几个月的小白鼠，还算稳定，而更凑巧的是，这家伙也是选的AsRock E350M1主板，So，我最后还是选择了Linux，这样可以1机两用：NAS 和 媒体中心。

操作系统: 为了能压榨出硬件的最后一点性能，我选用 Linux 的 Gentoo 发行版, Gentoo 可以使得我自己配置调整编译内核。


# 更新(2016-06-12)

光阴似箭，眨眼4年过去了，Intel 推出了Micro Server——志强D系列, 而 AMD 却依然在原地踏步。
4年前，支持ECC RDIMM内存的ITX主板根本找不到，现在超微，AsRock都有了基于志强D系列的ITX MicroServer主板。
NAS机箱也多起来。超微甚至出了带机箱的准系统，但性价比太低。

* 6盘位DIYNAS机箱，可定制LOGO,有防尘网。
  * 机箱=499
  * 机箱+技嘉150W DC电源=768
  * 机箱+益横的 250W=840
  * 机箱+全汉电源 270W=880元
  * 益衡 Enhance ENP 7025B FLEX 250W=245元 淘宝价
  * 全汉电源 小1U 270W=108元 淘宝价
  * 需要了解限高问题，内存条，插卡等。
* 超微X10SDV-4C+-TLN4F（128G ECC RDIMM DDR4 2133, M.2 PCIe3.0x4 2242/2280）
  + 志强D-1518(4核，6MCache, 2.20Ghz) 35W ￥3720
  + 志强D-1541(8核，6MCache, 2.20Ghz) 45W ￥6880
  * 可惜是基于Broadwell, 还是得等明年(2017年)的Skylake 。
* 三星 32G DDR4 2133 RDIMM 服务器内存: ￥1060


499+108+3720+1060=5387

