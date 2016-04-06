---
author: riceball
date: 2012-05-12 13:55:43+00:00
title: DIY与云计算（三）之 云存储与开源 ZFS 文件系统
category :
  - Thinking
  - Cloud Computing
tags:
  - cloud computing
  - diy
  - zfs
---

## ZFS 介绍


首先ZFS是"Zettabyte File System"的首字母缩写。ZFS 源自于Sun Microsystems为Solaris操作系统开发的文件系统。
ZFS是一个具有高存储容量、文件系统与卷管理概念整合、崭新的磁盘逻辑结构的轻量级文件系统，同时也是一个便捷的存储池管理系统。ZFS使用CDDL开源协议条款授权。后来被移植到FreeBSD和NetBSD系统上。

ZFS是一个128位的文件系统，这意味着它能存储1800亿亿（18.4 × 10^18）倍于当前64位文件系统的数据。窃以为目前ZFS文件系统是云存储以及NoSQL数据库的最佳首选。


### 特性

* Data integrity 数据完整性

保障数据完整性是ZFS的主要功能和任务。ZFS使用了许多技术来检测和
修复毁坏的数据，以此保障数据的完整性。代价是要求比普通RAID文件
系统更多的CPU处理能力。

* Storage pool 存储池

ZFS建立在虚拟的“zpools”的存储池之上。每个存储池由若干虚拟设备
（virtual devices， vdevs）组成。这些虚拟设备可以是原始磁盘，
也可能是一个RAID1镜像设备，或是非标准RAID等级的多磁盘组。

* Read-only Snapshot support (it is possible to get a read-write copy of them, those are named clones)
* Built-in RAID-5-like-over-steroid capabilities known as RAID-Z and RAID-6-like-over-steroid capabilities known as RAID-Z2. RAID-Z3 (triple parity) also exists.
* Copy-on-Write transactional filesystem
* Meta-attributes support (properties) allowing you to you easily drive the show like "That directory is encrypted", "that directory is limited to 5GiB", "That directory is exported via NFS" and so on. Depending on what you define, ZFS takes the appropriates actions!
* Dynamic striping to optimize data throughput
* Variable block length
* Data duplication
* Automatic pool re-silvering
* Transparent data compression / encryption (later requires Solaris 11)


### 代价和劣势

* CPU开销较大(目前的CPU性能来说足已)
* 内存开销大，为了获得更好的性能，而需要更多的内存
* 1TB大约需要1GB 内存
* 启用 dedup 需要巨量内存或者SSD，否则性能变差，1TB大约需要32GB RAM或SSD.
* 缺乏"Block Pointer rewrite functionality" 功能(已计划开发), 因为没有该功能所以不能:
* 没有能力整理磁盘碎片(Pool defragmentation) (已通过COW技术来缓解该问题)
* 没有能力动态扩大或缩小(Pool Resize)存储池
* 数据压缩 (已解决)
* 无法添加新的单块设备到现有的RAID-Z/Z2/Z3 存储池，用以增加池的大小(不过，可以通过同时
替换该池中的设备来扩展 RAID-Z/Z2/Z3 大小，还可以添加另一组同样大小的虚拟设备到现有池的形式扩展)
* 没有类似Lustre, GFS or OCFS2集群文件系统
* 单个存储设备上不能保障数据完整(健康)性(损害依然可以被检测到), 避免方法是设置数据强制重复。
* 修复(Resilver)损害的磁盘时间长，磁盘越大，所需时间越多，一般5或者6TB的磁盘需要几天来修复。
这意味着最好Raidz1(RAID-5)当心这样的修复，因为在修复的过程中，会给原有的所有磁盘相当的压力。
在这么长的修复时间如果另一个磁盘也crash了，那数据就彻底完蛋了。所以对于大于3TB的磁盘，最好
是用Raidz2(允许2个磁盘同时失效)或Raidz3(允许3个磁盘同时失效)
* IOPS 性能会随ZFS阵列的配置不同差异很大，8磁盘的raidz2阵列，写性能会很差，等于单磁盘写的性能，
但是读性能则可以达到所有8个磁盘性能之和。在ZFS中正确配置阵列是关键。


## ZFS on Linux


如果你是在用Linux/Gentoo 发行版本:

```bash
$sudo -s
#emerge --sync
#echo "sys-fs/zfs **" > /etc/portage/package.keywords/zfs
#echo "sys-kernel/spl **" >> /etc/portage/package.keywords/zfs
#emerge -v =sys-kernel/spl-9999 =sys-fs/zfs-9999
```

如果你用Ubuntu那就更简单了：

```bash
$ sudo -s
# apt-add-repository ppa:zfs-native/daily
# apt-get update
# apt-get install debootstrap ubuntu-zfs
```

如果不出意外的话，这样ZFS就安装好了，检查是否安装OK：

```bash
# modprobe zfs
# dmesg | grep ZFS:
ZFS: Loaded module v0.6.0-rc8, ZFS pool version 28, ZFS filesystem version 5
```

如果要玩Boot From ZFS Root Filesystem，那么这个比较复杂，还是等进阶后，再去详细了解吧。


## 使用 ZFS


ZFS有四个主要的概念，理清这些概念非常重要：
虚拟设备(`vdevs`)，存储池(`Storage Pool`), 卷(`Volume`)，快照(`Snapshot`)

虚拟设备由若干块设备配置的指定阵列构成，块设备可以是文件，磁盘分区或者磁盘(推荐整盘使用)。
存储池(`Storage Pool`)由若干虚拟设备构成。卷可以树状目录的形式在存储池中被任意的创建。然后我们可以为卷创建任意时刻的快照。

如果你的所有磁盘都是完全同样的大小，并且只准备使用同一阵列模式，那么你可以将整盘作为虚拟设备加入。
否则你需要分区你的磁盘，除了条带(stripe)阵列外，要求同一阵列的分区大小必须相同，如果大小不同，那么存储池实
际容量将会以最小的分区作为基准计算。

ZFS 支持条带(stripe)阵列，镜像(Mirror)阵列，Raidz(raidz1,raidz2,raidz3)阵列。

* 条带(stripe)阵列性能最好，空间利用率最大(容量=所有磁盘之和)，但是数据完整性最差。
* 镜像(Mirror)阵列性能最差(几乎等同于单盘性能)，空间利用率最小(容量=单个磁盘)，但是数据完整性最好。
* Raidz(RAID5/6/7)阵列是一种折衷选择，性能居中，空间利用率居中，
但是数据完整性居中(Raidz1允许1个磁盘同时失效, Raidz2允许2个磁盘同时失效，Raidz3允许3个磁盘同时失效)。
Raidz至少要3块盘。Raidz2至少4块盘。假设磁盘块数为N，大小为X，那么Raidz的实际使用空间＝`(N-1)*X, Raidz2的实际使用空间=(N-2)*X`

假设你有四个同样大小的sata磁盘: /dev/sda /dev/sdb /dev/sdc /dev/sdd


### 创建ZFS Raidz 存储池：



```bash
    $ sudo zpool create myzpool /dev/sda /dev/sdb /dev/sdc /dev/sdd
    $ sudo zfs list
    NAME      USED  AVAIL  REFER  MOUNTPOINT
    myzpool  96.5K   146M  31.4K  /myzpool
    $
```



### 查看存储池属性



```bash
    $ sudo zfs get all myzpool
    NAME     PROPERTY              VALUE                  SOURCE
    myzpool  type                  filesystem             -
    myzpool  creation              Sat Nov 13 22:43 2010  -
    myzpool  used                  96.5K                  -
    myzpool  available             146M                   -
    myzpool  referenced            31.4K                  -
    myzpool  compressratio         1.00x                  -
    myzpool  mounted               yes                    -
    myzpool  quota                 none                   default
    myzpool  reservation           none                   default
    myzpool  recordsize            128K                   default
    myzpool  mountpoint            /myzpool               default
    myzpool  sharenfs              off                    default
    myzpool  checksum              on                     default
    myzpool  compression           off                    default
    myzpool  atime                 on                     default
    myzpool  copies                1                      default
    myzpool  version               4                      -
    ...
    myzpool  primarycache          all                    default
    myzpool  secondarycache        all                    default
    myzpool  usedbysnapshots       0                      -
    myzpool  usedbydataset         31.4K                  -
    myzpool  usedbychildren        65.1K                  -
    myzpool  usedbyrefreservation  0                      -
    $
```



### ZFS的文件压缩能力



```bash
    $ sudo zfs create myzpool/myzdev
    $ sudo zfs list
    NAME             USED  AVAIL  REFER  MOUNTPOINT
    myzpool          139K   146M  31.4K  /myzpool
    myzpool/myzdev  31.4K   146M  31.4K  /myzpool/myzdev
    $ sudo zfs set compression=on myzpool/myzdev
    $ ls /myzpool/myzdev/
    $ sudo cp ../linux/Documentation/devices.txt /myzpool/myzdev/
    $ ls -la ../linux/Documentation/devices.txt
    -rw-r--r-- 1 mtj mtj 118144 2010-05-16 14:17 ../linux-2.6.34/Documentation/devices.txt
    $ ls -la /myzpool/myzdev/
    total 5
    drwxr-xr-x 2 root root      3 2010-11-20 22:59 .
    drwxr-xr-x 3 root root      3 2010-11-20 22:55 ..
    -rw-r--r-- 1 root root 118144 2010-11-20 22:59 devices.txt
    $ du -ah /myzpool/myzdev/
    60K /myzpool/myzdev/devices.txt
    62K /myzpool/myzdev/
    $ sudo zfs get compressratio myzpool
    NAME     PROPERTY       VALUE  SOURCE
    myzpool  compressratio  1.55x  -
    $
```
### 查看Pool的状态

```bash
$ sudo zpool status myzpool
  pool: myzpool
 state: ONLINE
 scrub: none requested
config:

    NAME        STATE     READ WRITE CKSUM
    myzpool     ONLINE       0     0     0
      raidz1    ONLINE       0     0     0
        sda     ONLINE       0     0     0
        sdb     ONLINE       0     0     0
        sdc     ONLINE       0     0     0
        sdd     ONLINE       0     0     0

errors: No known data errors
$
```
### Pool中一个磁盘损害后的修复

首先弄坏一个磁盘的数据:

```bash
$ dd if=/dev/zero of=/dev/sdd bs=64M count=1
1+0 records in
1+0 records out
67108864 bytes (67 MB) copied, 1.84791 s, 36.3 MB/s
$
```

然后检查Pool:

```bash
$ sudo zpool scrub myzpool
$ sudo zpool status myzpool
  pool: myzpool
 state: ONLINE
status: One or more devices could not be used because the label is missing or
    invalid.  Sufficient replicas exist for the pool to continue
    functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: http://www.sun.com/msg/ZFS-8000-4J
 scrub: scrub completed after 0h0m with 0 errors on Sat Nov 20 23:15:03 2010
config:

    NAME        STATE     READ WRITE CKSUM
    myzpool     ONLINE       0     0     0
      raidz1    ONLINE       0     0     0
        sda     ONLINE       0     0     0
        sdb     ONLINE       0     0     0
        sdc     ONLINE       0     0     0
        sdd     UNAVAIL      0     0     0  corrupted data

errors: No known data errors
$ wc -l /myzpool/myzdev/devices.txt
3340 /myzpool/myzdev/devices.txt
$
```

使用replace修复:



```bash
$ sudo zpool replace myzpool sdd sdd
$ sudo zpool status myzpool
  pool: myzpool
 state: ONLINE
 scrub: resilver completed after 0h0m with 0 errors on Sat Nov 20 23:23:12 2010
config:

    NAME        STATE     READ WRITE CKSUM
    myzpool     ONLINE       0     0     0
      raidz1    ONLINE       0     0     0
        sda     ONLINE       0     0     0
        sdb     ONLINE       0     0     0
        sdc     ONLINE       0     0     0
        sdd     ONLINE       0     0     0  59.5K resilvered

errors: No known data errors
$ sudo zpool scrub myzpool
$ sudo zpool status myzpool
  pool: myzpool
 state: ONLINE
 scrub: scrub completed after 0h0m with 0 errors on Sat Nov 20 23:23:23 2010
config:

    NAME        STATE     READ WRITE CKSUM
    myzpool     ONLINE       0     0     0
      raidz1    ONLINE       0     0     0
        sda     ONLINE       0     0     0
        sdb     ONLINE       0     0     0
        sdc     ONLINE       0     0     0
        sdd     ONLINE       0     0     0

errors: No known data errors
$
```



