---
author: riceball
date: 2022-05-04 16:38:18+08:00
updated: 2023-03-09 18:08:54+08:00
title: 智能家居硬件采购避坑指要(一) Zigbee设备
categories:
  - Open Source
  - Hardware
  - SmartHome
tags:
  - thinking
  - open source
  - hardware
  - iot
  - smarthome
  - homeassistant
  - ha
  - zigbee
---

![](./zigbee-smart-home.jpg)

# 智能家居硬件采购避坑指要(一) Zigbee设备

注意: [Home Assistant](https://www.home-assistant.io/) 简称 HA, 后面我就用简称了.

## Zigbee设备的特性

为啥要以Zigbee设备为主,这就要从它的特性谈起:

1. 低功耗：由于节点常常休眠，zigbee是比较省电的,一般1-2年
2. 短时延，设备激活快，点播中的消息确认是微秒级别；不过路径长的话会增加延时
3. 可靠,安全,数据通讯是加密的
4. 网络容量大：实际CC2530组建的网络基本能达到100个节点
5. 自组织和自愈性，协调器自动建立网络，有节点故障时网络可以自我修复
6. 近距离，单个节点通讯范围最多是100米以内
7. 支持的设备的多: 因为Zigbee设备的协议基本透明(或破解)了,大多可以**直接接入**HA.

## 蹚坑记录

这里**注意**: 不要通过什么各类`**多模网关**`(如:小米/绿米)来接入,它们只能接入`大桶`内的zigbee设备!而且他们不停的向互联网发送采集到的设备数据,并能从网络上**直接接管**您的设备.

我最初买的就是**小米多模网关**和**绿米M1S网关**,试用后退掉了**小米多模网关**,留下了**绿米M1S网关**,图它的彩灯,没想到这个坑货,我一旦屏蔽**绿米M1S网关**连接互联网,那绿米的破彩灯不一会儿就闪个不停关掉停一会儿又闪. 后来发现了 **Zigbee2MQTT(Z2M) USB网关**,把我所有的Zigbee设备转到新的Z2M USB上去,才终于清静了.

请购买使用开源的 [Zigbee2MQTT(Z2M)][Z2M] 网关接入,价格也不贵. [Z2M][Z2M] 支持的硬件网关列表: https://www.zigbee2mqtt.io/guide/adapters/

我买的是[SONOFF USB Dongle Plus](https://sonoff.tech/product/diy-smart-switch/sonoff-dongle-plus/)万能通用网关(基于CC2652P芯片)价位在￥70左右, 该网关通过[Z2M][Z2M]能支持2千余种的Zigbee设备. **值得推荐**

[![sonoff-dongle-plus](./sonoff-dongle-plus.png)](https://sonoff.tech/product/diy-smart-switch/sonoff-dongle-plus)

[Z2M][Z2M]具体支持的设备列表请看这里: https://www.zigbee2mqtt.io/supported-devices/. 够让你挑花眼的, 我买的绝大部分Zigbee设备在Z2M均能正常使用,包括绿米/小米的Zigbee设备,反而是在SONOFF(易微联)的温度计和按钮上碰到了点小问题.

先说说碰到的问题吧:

首先涂鸦的设备质量参差不齐,因为涂鸦主要是卖方案的,所以实际上设备要看各个厂家的品控.购买要多加小心. 我试过三家的涂鸦人体PIR传感器,其中有一家发过来的全是坏的:一个能配对,但是工作一会就没有数据了,另一个根本不工作,配对都不行. 另外两家的还行.我买涂鸦的设备总量比较少.

SONOFF(易微联SNZB-02)的温湿度计配对使用没啥问题,但是如果你再次配对到另一个Zigbee网关,然后再配对回原来的网关,你会发现,尽管配对成功,信号也正常,但就是没有数据,后来我发现当把这货配对到M1S网关,尽管M1S会报告该设备无法配对,拒绝配对后,我再配对回原来的网关,数据居然有了.
![sonoff-snzb-02](./sonoff-snzb-02-s.jpg)

SONOFF(易微联SNZB-01)的按钮配对和使用也没啥问题,问题出在`绑定`上,Zigbee有个功能可以将按钮设备`绑定`到另一个设备(如开关)上,这样就算没有HA中枢,按钮也能控制另一个设备(如开关),当易微联的按钮配对时,会自动绑定一个设备(开关),这很烦,而当我在Z2M上操作解除绑定的时候,发现竟然无法解绑.而与此同时也无法绑定新设备.
![sonoff-snzb-01](./sonoff-snzb-01-s.jpg)

涂鸦(Lonsonho ZB-RGBCW)全彩灯泡 如果长时间关闭电源,灯泡就会彻底掉线,需要再次重新配对join.
![tuya-zb-rgbcw](./tuya-zb-rgbcw-tiny.jpg)

绿米的品控不错,但是贵,另外绿米的人体PIR传感器(RTCGQ11LM),虽然带了温度和光强,但是温度根本不准,温度差了6度,这货光强照度和M1S网关的一样在弱光下根本没值,就是0,强光下变化倒是明显,没鸟用,在[Z2M][Z2M]配置光强照度以及温度为精度为小数点后2位,但根本不生效,没有小数后面的数字,配置里只有温度校准有用.

现在用的Zigbee设备列表:

1. SONOFF(易微联SNZB-02)的温湿度计 小问题 不推荐
   ![sonoff-snzb-02](./sonoff-snzb-02.jpg)
2. SONOFF(易微联SNZB-01)的按钮    小问题 不推荐
   ![sonoff-snzb-01](./sonoff-snzb-01.jpg)
3. SONOFF(易微联SNZB-03) 人体PIR传感 推荐
   ![sonoff-snzb-03](./sonoff-snzb-03.jpg)
4. SONOFF(易微联SNZB-04) 门磁 推荐 ![sonoff-snzb-04](./sonoff-snzb-04.jpg)
5. [SONOFF(易微联) USB Dongle Plus](https://sonoff.tech/product/diy-smart-switch/sonoff-dongle-plus/) 万能通用网关(基于CC2652P芯片) 推荐 ![sonoff-dongle-plus](./sonoff-dongle-plus.png)
6. 涂鸦(Lonsonho ZB-RGBCW)灯泡 不推荐 ![tuya-zb-rgbcw](./tuya-zb-rgbcw.jpg)
7. 涂鸦(TuYa TS0203) 门磁 ![ts0203](./tuya-ts0203.jpg)
8. 涂鸦(TuYa TS0202) 人体PIR传感 ![ts0202](./tuya-ts0202.jpg)
9. 涂鸦(TuYa TS0601_motion_sensor) 人体毫米波雷达传感 性价比太差,不如买IP摄像头 ![tuya-ts0601_motion_sensor](./tuya-ts0601_motion_sensor.jpg)
10. 绿米(Xiaomi QBCZ11LM)86插座 可中继 ![Aqara_QBCZ11LM](./Aqara_QBCZ11LM.jpg)
11. 绿米(Xiaomi WSDCGQ11LM) 温湿度计 ![Aqara_WSDCGQ11LM](./Aqara_WSDCGQ11LM.jpg)
12. 绿米(Xiaomi RTCGQ11LM) 人体PIR传感 带温度和光强 它的温度和光强没法用,不推荐 ![Aqara_RTCGQ11LM](./Aqara_RTCGQ11LM.jpg)
13. 小米魔方(Xiaomi MFKZQ01LM) 控制器(玩具) ![Aqara-MFKZQ01LM-Cube](./Aqara-MFKZQ01LM-Cube.jpg)

所有的Zigbee灯泡都不推荐,因为几乎都是固定死的,根本无法拆解无法更换,还是买 `LED Controller`, 或买`开关/通断器`(最好带电量统计)比较划算.

## 避免与WIFI 2.4G信道干扰的问题

Zigbee和Wi-Fi 2.4G信道可以互相影响，因为它们都使用了相同的频段（2.4GHz频段）。在使用Wi-Fi 2.4G信道的同时使用Zigbee设备时，可能会发生以下问题：

1. 干扰问题：当Wi-Fi和Zigbee设备同时使用2.4G信道时，它们会相互干扰，导致信号质量下降、数据传输速度变慢等问题。
2. 传输距离问题：Wi-Fi信号较强，如果Wi-Fi设备的信号覆盖区域较大，可能会导致Zigbee设备的信号被遮蔽或干扰，从而影响其正常工作。

为了解决这些问题，可以采取以下措施：

1. 避免使用相同信道：在使用Wi-Fi和Zigbee设备时，应尽量避免它们使用相同的2.4G信道，以避免干扰和冲突。
2. 选择合适的设备：在选购Wi-Fi和Zigbee设备时，应选择具有良好的抗干扰能力和传输距离的设备，以减少冲突的发生。
3. 优化网络布局：在使用Wi-Fi和Zigbee设备时，应合理规划和布局网络，避免设备之间的信号干扰和遮蔽。
4. 调整信道设置：在出现干扰和冲突的情况下，可以尝试调整Wi-Fi和Zigbee设备的信道设置，以减少干扰和冲突的发生。

具体来说,就是 Wi-Fi和Zigbee设备在2.4GHz频段内使用的信道有一些重叠，这些信道的中心频率有可能会相互干扰：

* Wi-Fi使用的信道：1、6、11、以及在部分国家可用的信道14
* Zigbee使用的信道：11、15、20、25
  * 所有Zigbee设备都支持11信道,其它信道不一定是所有Zigbee设备都支持.

因此，最佳方案是让WIFI避开11信道,如果实在避不开,可以让Zigbee网关尝试选择其它信道.只要不是太老的Zigbee设备就没啥问题,自行尝试.

[Z2M]: https://www.zigbee2mqtt.io/
