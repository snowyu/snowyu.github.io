---
author: riceball
date: 2017-02-26 19:35:00+08:00
title: Ubuntu Tips
categories:
  - Linux
  - Ubuntu
tags:
  - linux
  - ubuntu
  - network
  - dnsmasq
  - iptables
  - iproute2
  - dns
  - ipset
  - shadowsocks
---

# Ubuntu 16.10

Ubuntu 现在基本可以替代Windows做日常使用的主力——只要不玩游戏。
不过对SSD还是要需要调教一二。使用 Linux 还有一个好处是可以自带
策略路由，对于域名IP流量精确转发，变得so easy。

这里记录下 Ubuntu 16.10 以上版本的碰到的一些tips。

## Shell

我比较习惯 zsh, 下载安装zsh:

```bash
$> sudo apt install zsh
$> sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
$> echo "source $HOME/.profile" >> ~/.zshrc
$> chsh /usr/bin/zsh
$> echo "export LC_ALL=en_US.UTF-8">> ~/.profile
```

然后修改.zshrc文件，添加你自己的pulgins：

```
plugins=(git github git-flow cp systemd docker gem meteor rvm ruby perl python pip rsync sbt ubuntu gradle nvm npm node coffee yarn go golang)
```

## dnsmasq

ubuntu自带，用于域名解析，并且是自动加在 /etc/resolve.conf中（127.0.1.1）
是随NetworkManager启动的，dnsmasq的配置在 /etc/NetworkManager/dnsmasq.d/
需要加上对上游DNS服务器的查询，否则你可能会发现DOMAIN NOT FOUND：


```bash
$>cat /etc/resolv.dnsmasq.conf
# Google's nameservers, for example
nameserver 8.8.8.8
nameserver 8.8.4.4

$>cat /etc/NetworkManager/dnsmasq.d/resolv.conf
resolv-file=/etc/resolv.dnsmasq.conf

#启用 /etc/hosts
$>cat /etc/NetworkManager/dnsmasq.d/host.conf
addn-hosts=/etc/hosts

$>sudo systemctl restart NetworkManager
```

## ipset

ipset 配合 iptables 可实现基于域名的策略路由。

ipset 可以将一组ip放入到一个集合中供iptables进行处理。这样可以很好的解决大量ip规则的匹配
性能问题。

当然，首先你要安装: `sudo apt install ipset`

### 黑名单方式

Dnsmasq 从 2.66 版本之后就支持将域名的查询结果放进 ipset 中，这样就可以对这些域名对应的 IP
使用 iptables 处理。

只转发名单内的IP, 可以配合gfwlist对指定的域名IP做重定向处理

下载: [gfwlist_ipset.conf](https://github.com/cokebar/gfwlist2dnsmasq/releases)文件，
放在: /etc/NetworkManager/dnsmasq.d/ 目录中即可。

你需要修改文件中的域名服务器地址，最简单的方法是在代理服务器上自建一个域名服务器（用非标准端口）。

```yaml
#使用不受污染干扰的DNS解析该域名 可以将此IP改为自己使用的DNS服务器
server=/google.com/127.0.0.1#5353
#将解析出来的IP保存到名为gfwlist的ipset表中
ipset=/google.com/gfwlist
```

或者，你可以[下载执行这个脚本](https://github.com/cokebar/gfwlist2dnsmasq)自动抓取gfwlist转换为：dnsmasq_gfwlist_ipset.conf

```bash
$> sudo bash gfwlist2dnsmasq.sh -d your-dns-server-ip -p your-dns-server-port -s gfwlist  -f /etc/NetworkManager/dnsmasq.d/gfwlist_ipset.conf
```

然后创建`gfwlist`ipset规则集:

```bash
ipset -N gfwlist hash:ip
```

### 白名单方式

收集国内IP，除了国内IP放行外，其它IP一律转发。

* 获取国内 IP 列表

接下来我们需要获取中国的 IP 列表。这里我们放在了 `~/chnroute/`目录下：

```bash
CHNROUTE_DIR=$HOME/chnroute
mkdir $CHNROUTE_DIR
curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > $CHNROUTE_DIR/chnroute.txt
```
这是来自 [ChinaDNS](https://github.com/shadowsocks/ChinaDNS) 的指令。

创建ipset并导入：

```bash
#!/bin/bash

# Setup the ipset
ipset -N chnroute hash:net maxelem 65536

for ip in $(cat '$HOME/chnroute/chnroute.txt'); do
  ipset add chnroute $ip
done
```

注意：这里`ipset类型`必须是hash:net,而不是hash:ip。因为 chnroute.txt 是一个 IP 段列表，
而中国持有的 IP 数量巨大，所以如果使用 hash:ip 来导入会内存溢出。


## shadowsocks-libev

    apt install shadowsocks-libev


```bash
$> cat /etc/shadowsocks-libev/config.json
{
    "server":"[123.22.33.13]", # your shadowsocks server ip
    "server_port":1293,
    "local_port":1080,
    "password":"12345",
    "timeout":60,
    "method":"aes-256-cfb"
}
```

启用 shadowsocks-libev.service 之前，需要做些修改，将服务改为透明转发`ss-redir`：

```bash
$>cat /lib/systemd/system/shadowsocks-libev.service
[Service]
Type=simple
EnvironmentFile=/etc/default/shadowsocks-libev
User=root
LimitNOFILE=32768
# modify ss-server to ss-redir
ExecStart=/usr/bin/ss-redir -a $USER -c $CONFFILE $DAEMON_ARGS

$>systemctl enable shadowsocks-libev
$>systemctl daemon-reload
$>systemctl start shadowsocks-libev
```

## iptables

下面开始在iptables上做转发：

首先为shadowsocks创建NAT表:

```bash
# create a nat named SHADOWSOCKS:
iptables -t nat -N SHADOWSOCKS

# Ignore your shadowsocks server's addresses
# It's very IMPORTANT, just be careful.
iptables -t nat -A SHADOWSOCKS -d [your-shadowsocks-server-ip] -j RETURN

# 忽略局域网：
# Ignore LANs and any other addresses you'd like to bypass the proxy
# See Wikipedia and RFC5735 for full list of reserved networks.
# See ashi009/bestroutetb for a highly optimized CHN route list.
iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN
```

### 黑名单

```bash
# Anything matched gfwlist ipset should be redirected to shadowsocks's local port
iptables -t nat -A SHADOWSOCKS -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports 1080
# Apply the rules
iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS
```

### 白名单

```bash
# Allow connection to chinese IPs
iptables -t nat -A SHADOWSOCKS -p tcp -m set --match-set chnroute dst -j RETURN

# Others Redirect to Shadowsocks
iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-port 1080

# Apply the rules
iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS
```

### 清除iptables规则

```bash
#!/bin/bash

iptables -t nat -D OUTPUT -p tcp -j SHADOWSOCKS
iptables -t nat -F SHADOWSOCKS
iptables -t nat -X SHADOWSOCKS

# 如果是黑名单:
ipset destroy gfwlist
# 如果是白名单:
ipset destroy chnroute
```
