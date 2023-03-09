---
author: riceball
date: 2022-05-05 16:38:18+08:00
updated: 2023-03-09 18:08:54+08:00
title: 智能家居硬件采购避坑指要(二) Wifi设备
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
  - wifi
---

# 智能家居硬件采购避坑指要(二) Wifi设备

![](./wifi-smart-home.jpg)

## Wifi 特性

1. 穿墙性能好(与Zigbee和蓝牙相比)
2. 高带宽(与Zigbee和蓝牙相比)
3. Wifi模块便宜
4. 需要考虑路由器的带机量,一般家用路由器的带机量都不大.
5. 最好选择直接供电(非电池)的Wifi设备,避免频繁更换电池的麻烦

Zigbee2MQTT的低功耗是源于它的低速,但某些场合则要求高带宽,比如`IP摄像头`. 而对IP摄像头来说支持 `ONVIF(Open Network Video Interface Forum)` 协议是必须的,不支持开放网络视频协议的都是在耍流氓,当用户是羊!比如:**萤石**私有协议,看似可以接入HA,你不知道的是所有的控制都要去他们公司云上绕一圈才回来,为了达到偷窥家庭的目的,特意废弃一贯支持的`ONVIF`,搞了萤石私有协议,让他们公司的有权限的人可以随时随地观看场景剧甚至动作片,不旺一番苦心.

另,就算商家告诉你支持`ONVIF`也不要掉以轻心,因为`ONVIF`也是可深可浅,浅的就只有选择个分辨率,控制录像,深的则可以控制云台,控制麦克风语音,以及触发运动事件等. 乐橙号称支持`ONVIF`, 但是居然把Web管理端给去掉了!导致要用Wifi就不能修改设备密码,只能使用设备固定初始的安全码(真的安全吗?),如果要改密码只能在复位后,通过网口连上后用大华的IP配置工具修改,然后Wifi配置就没辙了,只能用有线网络,还有他的 ntp 授时服务配置根本没有用,用的是自家的端口号10000的一个鬼服务,这个端口一屏蔽时间就完蛋,然后就是录制视频上的**时间和乐橙LOGO**居然无法取消.

其它Wifi设备最好使用能刷 开源[ESPHome](https://esphome.io/) 或 [Tasmota](https://tasmota.github.io/)固件的设备, 这样就能完全掌控该设备:

* [ESPHome 支持的设备列表](https://www.esphome-devices.com/)
* [Tasmota 支持的设备列表](https://templates.blakadder.com/)

## 我买过的WIFI设备

* 乐橙(IMou TP7S-4M)IP摄像头: 坑货,如果不是因为半价,勉强可用(支持`ONVIF`云台控制)就退了,所谓AI人脸识别,追踪全是联机服务和产品无关 不推荐
  * 当然更坑的是**萤石**,连`ONVIF`也不支持,海康威视不敢坑企业和政府,于是专门成立**萤石**出来坑普通消费者的,而**乐橙**则是大华专门成立出来坑的.
* SONOFF(易微联 NSPanel) 智能面板, 带温度,小喇叭,两路继电器,两个实体按钮及触摸屏, 可刷开源 ESPHome 固件,**推荐**
  * ![nsPanel](./nspanel.jpg)
  * [易微联 SONOFF NSPanel 智能面板刷 ESPHome 固件 接入 HA 入坑指南](https://bbs.hassbian.com/thread-15932-1-1.html)
* 博联 RM Pro 万能遥控器: 支持红外,以及 RF315/433 很久以前买的
  * ![Broadlink RM Pro](./rmpro.jpg)
* 博联 SPMini3 Wi-Fi插座（10A） 很久以前买的
  * ![sp_mini3](./sp_mini3.jpg)
* 小米路由器CR6608（移动定制版）: 已刷开源OpenWRT固件
  * ![cr6608](./cr6608.jpg)
* 树莓派 Zero/w BCM2835 1GHz 主频 ARM11 32位单核, 512 MB DDR2
  * ![RaspberryPi Zero/w](./raspberrypi_zerow.jpg)
* Banana PI BPI-M2 Zero Allwinner H2+, 32位 Quad-core Cortex-A7 1.2GHz, Mali400 MP2 @600MHz, 512MB DDR 3 SDRAM
  * ![Banana-PI-BPI-M2-Zero](Banana-PI-BPI-M2-Zero.jpg)
* Lichee RV 86 Panel 基于平头哥玄铁C906处理器,主频1GHz 512MB DDR3内存
  * ![Sipeed-Lichee-RV-86-Panel](./Sipeed-Lichee-RV-86-Panel.jpg)
* RockPi S With PoE Hat Rockchip RK3308 512MB DDR3,4G NAND
  * ![RockPi S With PoE Hat](./RockPi-S-With-PoE-Hat-Shell.jpg)
* Rock5 Model B RK3588 16GB RAM
  * Quad-core ARM Cortex-A76 MPCore processor and quad-core ARM Cortex-A55 MPCore processor
  * Embedded ARM Mali-G610 MP4 3D GPU
  * The build-in NPU supports INT4/INT8/INT16/FP16 hybrid operation and computing power is up to 6TOPs
  * ![Rock5B](./rock5b.jpg)
* NanoPi R4S
  * ![Nanopi-R4S](./Nanopi-R4S.jpg)
* HK1 Box
  * ![HK1-Box](./HK1-Box.jpg)
* NanoPC T4 Box
  * ![NanoPC-T4-Box](./NanoPC-T4-Box.jpg)
* CubieTruck Box
  * ![CubieTruck](./CubieTruck.jpg)
* 以及ESP32/ESP8266板子若干


## 开源 ESPHome 和 Tasmota 固件比较

[ESPHome][ESPHome] 和 [Tasmota][Tasmota] 都是基于 ESP8266 或 ESP32 的开源固件，用于控制智能家居设备的固件。它们都提供了很多功能，例如支持 MQTT、HTTP、WebSocket，以及对各种传感器和执行器的支持。

然而，它们在以下几个方面有所不同：

1. 设计哲学：ESPHome 的设计哲学是通过 YAML 文件进行配置，以使用户可以轻松地定义其设备的功能，而无需编写任何代码。另一方面，Tasmota 侧重于使用 Web 界面进行配置，其界面和配置选项更为复杂。
   1. ESPHome的固件是按需编译,体积更小
   2. 而Tasmota的固件是将所有功能都预先编译内置在固件中,体积大
2. 设备支持：ESPHome 目前支持更多的设备，而且它提供了对许多设备的官方支持。 Tasmota 虽然支持许多设备，但某些设备需要使用非官方固件或插件才能使用。
3. 社区支持：ESPHome 和 Tasmota 都有活跃的社区，但 ESPHome 的社区更加友好和活跃，并且有更多的文档和示例可供参考。
4. 集成性：ESPHome 的集成性更好，可以轻松地将其与 Home Assistant 和其他智能家居平台集成。Tasmota 也可以集成到 Home Assistant 中，但需要更多的设置和调整。

[ESPHome]: https://esphome.io/
[Tasmota]: https://tasmota.github.io/
