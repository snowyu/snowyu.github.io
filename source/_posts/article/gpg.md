---
author: riceball
date: 2019-11-27 09:27:00+08:00
updated: 2019-11-27 09:27:00+08:00
title: OpenPGP 密钥(GnuPG软件)安全随笔
category:
  - Security
  - PGP
tags: [openpgp, pgp, gpg, openpgp, public key]
---

GnuPG软件（简称GPG） -- OpenPGP

# 历史介绍 History

## PGP (Pretty Good Privacy)

最早是由PGP Inc.公司拥有原始的PGP加密软件的版权，后来它被赛门铁克公司（Symantec Corp.）收购。
后续由赛门铁克公司继续开发维护PGP品牌。

## OpenPGP

Zimmerman(最早的PGP开发人员)于1997年向IETF（互联网工程任务组）提交了[开源PGP（OpenPGP）标准提案](https://tools.ietf.org/html/rfc4880)。如今，OpenPGP成为了PGP的标准规范，是供公众使用的开源代码，并且该术语可用于描述支持OpenPGP系统的任何程序。

## GPG (GNU Privacy Guard)

GnuPGP由Werner Koch开发的开源加密工具软件，并于1999年发布，以替代现有的Symantec加密工具软件套件。 它可以免费下载，并且基于IETF建立的OpenPGP标准，因此可以与Symantec的PGP工具和支持OpenPGP标准的软件互操作。GPG可以打开和解密任何PGP和OpenPGP标准的文件。

## Keys

在公开密钥算法中，一个Key(密钥)包括两个部分：公钥和私钥。公钥类似于印鉴，而私钥类似于印章。

## [Subkeys](https://wiki.debian.org/Subkeys)

在OpenPGP标准中你的钥匙包括一个主钥(master key)和若干子钥(subkeys)。在OpenPGP标准中主钥，子钥(Subkey)是必需理解，非常关键的概念，可以极大的提升安全性。

* 主钥的主要作用是用于签发和吊销其它密钥、签名或用户Id，从安全角度考虑，主钥的私钥应该完全保持离线。
* 子钥：根据设置用途可以用于加密或签名，一旦子钥泄密可以用主钥吊销该子钥。
  * GPG会随机选择用于加密或签名(GPG默认策略会挑选钥匙size最大的，以及创建时间最近的)。

而就内部结构上看，子钥和主钥没啥不同的，只是PacketId上有差别，另外子钥要求有绑定主钥的签名包（见后面描述Binding Signatures）。

* Public-Subkey Packet Tag 是 14
* Secret-Subkey Packet Tag 是 7

### Subkey Usage

OpenPGP subkeys 用于不同的设想：

* 可以保持主键始终处于离线安全状态，您的主键不需要存放在线上(online)，可以只存放在本地的安全设备上。一旦有子键泄露，可以立刻使用主键轻松的吊销该子键，而没有撤销主键的麻烦（需要再次分享新的键,获取新的签名...）。Being able to store the primary key offline or a more secure device. If a machine with a subkey is harmed, you can easily revoke the subkey without all the hassles of revoking your primary key (sharing a new key, getting new signatures, ...).
* 可以在不同的机器上使用不同的子键。例如在构建服务器上使用单独的子键。记住，吊销单独的子键非常容易。Having different subkeys on different machines, for example a signing subkey on a build server. Again, revoking single keys is easy.
* 使用较大尺寸的密钥作为主键长时间使用，而使用短而快速的子键，可以每天一换。Using a larger primary key for long lifetime, and shorter, but faster subkeys for day-to-day usage.
* 某些算法不能同时支持加密和签名，例如: DSA 主密钥只能签名，因此它需要另一个密钥来加密，通常DSA与ElGamal算法成对使用。Some algorithms do not support both encrypting and signing. For example, a DSA primary key requires another key for encryption, typically paired with ElGamal.

### Binding Signatures

There are special signature subtypes to bind subkeys to primary keys (and vice verse), listed in [RFC 4880, OpenPGP, 5.2.1 Signature Types](http://tools.ietf.org/html/rfc4880#section-5.2.1):

0x18: Subkey Binding Signature

This signature is a statement by the top-level signing key that indicates that it owns the subkey. This signature is calculated directly on the primary key and subkey, and not on any User ID or other packets. A signature that binds a signing subkey MUST have an Embedded Signature subpacket in this binding signature that contains a 0x19 signature made by the signing subkey on the primary key and subkey.

0x19: Primary Key Binding Signature

This signature is a statement by a signing subkey, indicating that it is owned by the primary key and subkey. This signature is calculated the same way as a 0x18 signature: directly on the primary key and subkey, and not on any User ID or other packets.


OpenPGP 更进一步的支持 `subkeys`, 它像普通的钥匙,但 subkeys 是和一个 master 钥匙绑定的，子钥 可以用于签名或加密。子钥可以独立于主钥匙进行撤销和存放。

换句话说，子钥像单独的钥匙对，但是自动与您的主钥匙关联。

GnuPG 实际上用一个签名(signing-only)钥匙作为主钥匙。然后自动创建了一个用于加密的子钥。 Without a subkey for encryption, you can't have encrypted e-mails with GnuPG at all. Debian requires you to have the encryption subkey so that certain kinds of things can be e-mailed to you safely, such as the initial password for your debian.org shell account.

主钥仅当在以下情况下才被使用：

* when you sign someone else's key or revoke an existing signature,
* when you add a new UID or mark an existing UID as primary,
* when you create a new subkey,
* when you revoke an existing UID or subkey,
* when you change the preferences (e.g., with setpref) on a UID,
* when you change the expiration date on your master key or any of its subkey, or
* when you revoke or generate a revocation certificate for the complete key.


看 openpgpjs 的代码，好像可以独立使用subkey,但是必须存在 master key的公钥。

```bash
gpg --help
gpg --gen-key
gpg --expert --gen-key # 可以打开ECC等其它加密算法的支持, or --full-gen-key

　　gpg (GnuPG) 1.4.12; Copyright (C) 2012 Free Software Foundation, Inc.
　　This is free software: you are free to change and redistribute it.
　　There is NO WARRANTY, to the extent permitted by law.
　　请选择您要使用的密钥种类：
　　　(1) RSA and RSA (default)
　　　(2) DSA and Elgamal
　　　(3) DSA (仅用于签名)　
　　　(4) RSA (仅用于签名)
　　您的选择？

# 生成一张"撤销证书"，以备以后密钥作废时，可以请求外部的公钥服务器撤销你的公钥。
gpg --gen-revoke [用户ID]

gpg --list-keys --list-options show-keyring

/home/XXX/.gnupg/pubring.kbx
---------------------------------
pub   rsa4096 2016-10-05 [SC]
      72ECF46A56B4AD39C907BBB71646B01B86E50310
uid           [ unknown] Yarn Packaging <yarn@dan.cx>
sub   rsa4096 2016-10-05 [E]
sub   rsa4096 2016-10-05 [S] [expires: 2017-10-05]
sub   rsa4096 2016-10-30 [S]

pub   rsa4096 2017-04-17 [SC]
      EAD16A2C6AE2C4C70344D76855C2BF1FD36EBB60
uid           [ultimate] Riceball LEE <snowyu.lee@gmail.com>
sub   rsa4096 2017-04-17 [E]

# 输出密钥,armor参数可以将其转换为ASCII码显示。
gpg --armor --output public-key.txt --export [用户ID]
gpg --armor --output private-key.txt --export-secret-keys
# 上传公钥 公钥服务器是网络上专门储存用户公钥的服务器
gpg --send-keys [用户ID]

# 除了生成自己的密钥，还需要将他人的公钥或者你的其他密钥输入系统。这时可以使用import参数。
gpg --import [密钥文件]

# 为了获得他人的公钥，可以让对方直接发给你，或者到公钥服务器上寻找。
gpg --search-keys [用户ID]

# encrypt参数用于加密。
gpg --recipient [用户ID] --output demo.en.txt --encrypt demo.txt

# 解密 GPG允许省略decrypt参数。
gpg --decrypt demo.en.txt --output demo.de.txt

# 对文件签名 当前目录下生成demo.txt.gpg文件 -a 将为ascii armored 输出 demo.txt.asc
# -o demo.txt.sig 自定义输出文件名
gpg --detach-sig demo.txt
# 生成ASCII码的签名文件
gpg --clearsign demo.txt

#  验证签名
gpg --verify demo.txt.asc demo.txt


# 增加 subkey 启用 ECC 支持

gpg --expert --edit-key YOURMASTERKEYID
gpg> addkey
  Please select what kind of key you want:
    (3) DSA (sign only)
    (4) RSA (sign only)
    (5) Elgamal (encrypt only)
    (6) RSA (encrypt only)
    (7) DSA (set your own capabilities)
    (8) RSA (set your own capabilities)
    (10) ECC (sign only)
    (11) ECC (set your own capabilities)
    (12) ECC (encrypt only)
    (13) Existing key
  Your selection? 10
  Please select which elliptic curve you want:
    (1) Curve 25519
    (3) NIST P-256
    (4) NIST P-384
    (5) NIST P-521
    (6) Brainpool P-256
    (7) Brainpool P-384
    (8) Brainpool P-512
    (9) secp256k1
  Your selection? 9
gpg> save
```

### 导出密钥

应用签名等需要。

`openpgp2ssh` 测试成功，其余失败,搞定。

```bash
sudo apt install monkeysphere
# 弄之前先解密需要导出的密钥
# 10F15E84852CB868 是subkey的id,可以用 gpg --list-keys 看到
gpg --export-secret-subkeys youmasterid@gmail.com | openpgp2ssh 10F15E84852CB868 > id_rsa
openssl rsa -in id_rsa -outform pem > key.pem
# 将子密钥转为 pkcs8 格式。
openssl pkcs8 -topk8 -outform DER -in key.pem -inform PEM -out key.pk8 -nocrypt
# 产生请求签名的证书文件,发给签名方签名形成签名证书。
openssl req -new -key key.pem -out request.pem
# 签名方进行签名，产生签名证书。
# 这样一来变成了自签名的，而不是主钥签名的。如果要主钥签名，首先得导出主钥。
openssl x509 -req -days 9999 -in request.pem -signkey key.pem -out certificate.pem
# 使用 Android 提供的 SignApk.jar 进行 apk签名
java -jar SignApk.jar certificate.pem key.pk8 Application.apk Application_signed.apk
# 可以用这个脚本转到keytool去用java的 jarsigner, -p keystore-password
keytool-importkeypair -k ~/.android/debug.keystore -p android -pk8 key.pk8 -cert certificate.pem -alias platform
# 使用 java自带的签名工具进行签名
jarsigner -verbose -keystore ~/.android/debug.keystore Application_unsign.apk platform
```

https://github.com/getfatday/keytool-importkeypair

```bash
# keytool-importkeypair
# 将pkcs8 转回 pem 格式
openssl pkcs8 -inform DER -nocrypt -in "${pk8}" -out "${key}"
# 将密钥绑定签名证书，使用 keystore的密码加密
openssl pkcs12 -export -in "${cert}" -inkey "${key}" -out "${p12}" -password pass:"${passphrase}" -name "${alias}"
# 导入keystore
keytool -importkeystore -deststorepass "${passphrase}" -destkeystore "${keystore}" -srckeystore "${p12}" -srcstoretype PKCS12 -srcstorepass "${passphrase}"
```

------
以下为测试失败的一些方法：

It’s separate key storage: `gpg` has `~/.gnupg/pubring.gpg`, `gpgsm` has `~/.gnupg/pubring.kbx`
So keys added with gpgsm aren’t usable with gpg; gpg doesn’t read ~/.gnupg/pubring.kbx.


```bash
gpg -o secret-key.p12 --export [key id] --export-format pkcs12 --cert
```

`pkcs12` Only binary blocks are output; the default file extension is .p12; a signed key must be paired; and input must match exactly one key. In this case, --cert is required.

`--cert` This option is the X.509 issuer long name or the 32-bit or 64-bit key ID, if the signing key is available.


And there is an option concerning the charset of the exported key, which often is a problem with (especially older) windows programs:

`--p12-charset` name gpgsm uses the UTF-8 encoding when encoding passphrases for PKCS#12 files. This option may be used to force the passphrase to be encoded in the specified encoding name. This is useful if the application used to import the key uses a different encoding and thus will not be able to import a file generated by gpgsm. Commonly used values for name are Latin1 and CP850. Note that gpgsm itself automagically imports any file with a passphrase encoded to the most commonly used encodings.


It contains keys and certificates. Then you can split them with openSSL and transform it in .pem at the same time

```bash
openssl pkcs12 -in secret-key.p12 -out gpg-certs.pem -clcerts -nokeys -passin 'pass:P@s5w0rD'
openssl pkcs12 -in secret-key.p12 -out gpg-key.pem -nocerts -nodes

openssl pkcs12 -in secret-key.p12 -nocerts -out gpg-key.pem
openssl pkcs12 -in secret-key.p12 -nokeys -out gpg-certs.pem
```

还发现一个工具可以： openpgp2ssh http://manpages.ubuntu.com/manpages/natty/man1/openpgp2ssh.1.html

但是只支持rsa以及没有密码的key.

`gpg --edit-key $KEYID` 然后用 `passwd` 子命令移除密码。
然后

`gpg --export-secret-key $KEYID | openpgp2ssh $KEYID > id_rsa`


然后可以建立 Certificate Signing Request (CSR):

openssl req -new -key id_rsa -out id_rsa.csr


id_rsa.csr's content should look like:

```
-----BEGIN CERTIFICATE REQUEST-----
MIIC9jCCAd4CAQAwgZkxCzAJBgNVBAYTAkRFMRMwEQYDVQQIEwpTb21lLVN0YXRl[...]
-----END CERTIFICATE REQUEST-----
```

然后发给CA，CA签名后发给你证书文件:

```
-----BEGIN CERTIFICATE-----
MIIFRjCCAy6gAwIBAgIDCuP8MA0GCSqGSIb3DQEBBQUAMHkxEDAOBgNVBAoTB1Jv[...]
-----END CERTIFICATE-----
```

你把`id_rsa`和证书合并在一起：

```
-----BEGIN CERTIFICATE-----
MIIFRjCCAy6gAwIBAgIDCuP8MA0GCSqGSIb3DQEBBQUAMHkxEDAOBgNVBAoTB1Jv[...]
-----END CERTIFICATE-----
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0s2wNIWuUzuBYU9U0cK/mGa4LMtsWTEZEFTQhHj2eg4ZHmdt[...]
-----END RSA PRIVATE KEY-----
```

最后创建a PKCS#12 container:

openssl pkcs12 -export -in email@address.pem -out email@address.pem.p12



[Creating a new X.509 certificate from your PGP key pair](http://wiki.cacert.org/ConvertingPgpKeyToCertificate)




```bash
# 失败，没有 p12-export参数了！！！
/usr/lib/gnupg/gpg-protect-tool --p12-export -P <passphrase> ~/.gnupg/private-keys-v1.d/[keygrip] >foo.p12
```

`[keygrip]` is the hash of the key.  you can find it by:

```bash
gpg --with-keygrip --list-key
```

prepend the above line by space to avoid login the passphrase in history.

then (as per this guide, in fact)

```
openssl pkcs12 -in foo.p12 -nocerts -out foo.pem
chmod 0600 foo.pem
mv foo.pem ~/.ssh/id_rsa
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
```


## PGP 信任方式

PGP（Pretty Good Privacy）最初是用传统公钥密码学加密email信息的，之后又被用于加密本地文件。

注意：PGP和WoT(Web of Trust)不是同一样事务，PGP采用了WoT的方式。

PGP没有可信任的中心权威（第三方机构），但是相对应的是，系统中的每个人都可以签发自己的公钥并通过证书签名建立起自己的信任网。

一、公钥证书

公钥证书是PGP的重要核心。每个证书包含公钥所有者的用户ID（通常使用email地址），公钥，密钥ID，日期以及创建时间。证书需要被多个“介绍人”签名，“介绍人”是指用户完全信任的实体。PGP信任网的每个实体的主要标识是其公钥ID，而非与证书相关的用户ID号(这是因为用户ID号不稳定而公钥ID全局唯一且稳定不变)。但是公钥ID难以记忆，这也是唯一的问题（目前尚未完全解决）。

二、信任的定义

在PGP中有两个方面来定义信任：

1. 公钥证书的有效性；
2. 介绍人的可信度。

在此做个说明：一是所谓公钥之间的“介绍”其实就是“介绍人”对“被介绍人”的公钥证书上进行签名，其它人通过证书上的签名判断“被介绍人”的可信度，后面会讲到如何判断；二是公钥的有效性是指公钥通过证书上完全可信的签名将其与对应的公钥ID号紧密相连，如果失联则有效性消失。

首先介绍公钥证书有效性的层级：

* 未定义有效（undefined）:公钥的有效性无法判断；
* 边际有效（marginal）：公钥可具有一定的有效性，但是无法完全确认；
* 完全有效（complete）：公钥完全有效。

“介绍人”可信度主要定义的是用户认为某公钥所有者作为其它公钥的“介绍人”的可信任度。

下面再介绍“介绍人”可信度的层级：

* 完全可信（full）：该公钥介绍其它公钥是完全值得信任的；
* 边际可信(marginal)：该公钥可以介绍其它公钥，但其可信度值得怀疑；
* 不可信(untrustworthy)：该公钥完全不值得信任，它为其它公钥所做的签名可忽略不计；
* 可信未知（don't know）：该公钥介绍其它公钥的可信度仍属未知状态。

然而以上的有效性和可信度定义得十分模糊，PGP就想办法使其更具实际指导意义。PGP赋予用户自行调节标准的能力，它定义了两个参数：COMPLETES_NEEDED（完全需要数量）和MARGINALS_NEEDED（边际需要数量）。前者定义为使公钥证书完全有效时所需的完全可信签名的数量，后者定义为使公钥部分有效时所需的边际签名的数量。这两个参数都是需要用户根据自身情况定的。

三、信任评估算法

当PGP评估一个公钥证书的可信度时，它需要运用如下算法，即信任评估算法（用伪代码表示）：

```
1. For each signature do

// scan signatures

2. if signature is completely valid then

3. if key trust ∈{undefined,unknown,untrusted} then

4. ignore signature

5. if key trust is marginal then

6. accumulate marginals_counter

7. if key trust is complete then

8. accumulate completes_counter

9. else

10. ignore signature

// decision

11. if (marginals_counter>0) or (completes_counter>0) then

12. if (marginals_counter>=MARGINALS_NEEDED) or

13.(completes_counter>=COMPLETES_NEEDED) then

14. mark key validity as 'complete'

15. else

16. mark key validity as 'marginal'
```

其中：

* line 6: marginals_counter  计算该公钥证书的边际信任签名个数；
* line 8: completes_counter 计算该公钥证书的完全信任签名个数；
* line 10:非完全有效的签名将被忽略，即便它是由可信任的“介绍人”提出；
* lines 11,12,13: COMPLETES_NEEDED（完全需要数量）和MARGINALS_NEEDED（边际需要数量）均大于1。

四、介绍人

PGP是通过证书的签名人来证明公钥的有效性的，这些签名人又被称为“介绍人”，即，一个用户通过用自己的私钥签名一个新的公钥证书来向其它用户证明该证书中包含的公钥的有效性。如果一个用户有幸被划分为“完全可信介绍人”，则其被人完全信任，它在介绍其它公钥证书时影响力更大，介绍的人不需更多；若该用户被划分为“边际可信介绍人”，则其影响力就不足，需要更多这样的人来签名证书作证明。其中每个介绍人的可信度都是根据用户的考虑和隐私的需求结合起来定义的。

在PGP中，信任是不可以传递的。即在下图的介绍人（证书）链中，Carol不能假设Eric 的证书是有效的，除非通过介绍人的介绍。

    Carol --> Alice --> Bob --> Eric

```mermaid
graph LR
  Carol --> Alice
  Alice --> Bob
  Bob --> Eric
```

在PGP中的CERT_DEPTH参数尽管定义了证书链长度的最大值，但是也不能用其确定出证书的有效性。

也就是说，这些链的作用仅在于寻求用户之间的直接信任关系，帮助减少关系网的冗余度，使关系网更加清晰。

信赖网路机制比S/MIME方案的集中管理的公钥基础设施有优势，但是没有被网络普通大众普遍采用，一般只在Unix-like的爱好者、开源软体界、和对隐私特别注意而且有电脑知识的人群之间使用。如何使一般用户容易并且乐意使用、接收证书然后手动的验证它们的有效性，这些潜在的推广阻碍目前还没有满意的解决方案。

## Key Server

https://roll.urown.net/server/pgp-keyserver.html


## References

[Subkeys: howto choose which does what]: https://www.enigmail.net/forum/viewtopic.php?f=3&t=375
[5.5. Key Material Packet]: https://tools.ietf.org/html/rfc4880#section-5.5
