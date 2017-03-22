---
author: riceball
date: 2017-03-21 19:35:00+08:00
title: MQTT 服务 - IoT界的消息订阅发布服务
categories:
  - Thinking
  - Architecture
  - MQTT
tags:
  - mqtt
  - network
  - pubsub
  - push
  - message
---

# MQTT 服务 - IoT界的消息订阅发布

关于消息推送服务PaaS云，这才发现国内几乎所有的消息推送服务都是基于广告，对用
户画像，打标签，针对用户推送，没有纯粹的基于订阅发布消息推送服务，难怪免费居多，
相当于你帮他们植入了常驻设备的推送后门。

只有自驾了。我选择了MQTT。

MQTT本是用于物联网设备的消息推送协议，具有体积小，协议简单，通信高效省电的特点。
用在手机设备最好不过。


## MQTT 协议简单介绍

MQTT 协议使用最少的方法指示要在特定主题(Topic)上实施的操作，进而实施发布/订阅模式。
MQTT是发布订阅(Publish/Subscribe)模式的消息协议，与HTTP协议请求响应(Request/Response)模式是不同的。

### 消息与主题 Topic

MQTT发布者与订阅者之间通过”主题”(Topic)进行消息推送，主题(Topic)格式类似URL或文件路径，通过"/"分隔层级，
例如:

```
sensor/1/temperature
chat/room/subject
presence/user/feng
sensor/1/#
sensor/+/temperature
uber/drivers/joe/inbox
```

MQTT主题(Topic)支持’+’, ‘#’的通配符，’+’通配一个层级，’#’通配多个层级(必须在末尾)。
MQTT消息发布者(Publisher)只能向特定’名称主题’(不支持通配符)发布消息，订阅者(Subscriber)
通过订阅’过滤主题’(支持通配符)来匹配消息。

注意：必须要转义’+’, ‘#’。

MQTT支持推送消息的QoS(服务质量)。在MQTT 中有三个等级的 QoS：

* QoS 0: 该等级表示“最多一次”交付（最佳状况）。 消息不会得到确认，因而，这是一种一劳永逸的方法。
* QoS 1: 该等级表示“至少一次”交付。 用户可能不止一次获得消息，但是允许收到的人确认已经收到。
* QoS 2: 该等级表示“刚好一次”交付。最慢但是最有保障的服务质量等级。确保用户只收到一次消息，
  并包含四个阶段的交付握手。该等级最慢，但是最安全。

#### MQTT遗愿消息(Last Will)

MQTT客户端向服务器端CONNECT请求时，可以设置是否发送遗愿消息(Will Message)标志，和遗愿消息主题(Topic)与内容(Payload)。

MQTT客户端异常下线时(客户端断开前未向服务器发送DISCONNECT消息)，MQTT消息服务器会发布遗愿消息。

#### MQTT保留消息(Retained Message)

MQTT客户端向服务器发布(PUBLISH)消息时，可以设置保留消息(Retained Message)标志。保留消息(Retained Message)会驻留在消息服务器，后来的订阅者订阅主题时仍可以接收该消息。

保留消息(Retained Message)有两种清除方式:

* 客户端向有保留消息的主题发布一个空消息:
* 消息服务器设置保留消息的超期时间。

#### 共享订阅(Shared Subscription)

共享订阅是非标准MQTT约定，不过大多数开源MQTT服务器已经实现。
共享订阅(Shared Subscription)支持在多订阅者间采用分组负载平衡方式派发消息:
也就是订阅相同共享订阅(Shared Subscription)的客户根据负载平衡方式只有1人收到。
这个场景可以用于：集群执行分布式任务（1个人接了活，其他人就不要接了）。


```
                            ---------
                            |       | --Msg1--> Subscriber1
Publisher--Msg1,Msg2,Msg3-->|  EMQ  | --Msg2--> Subscriber2
                            |       | --Msg3--> Subscriber3
                            ---------
```

共享订阅支持两种使用方式:

| 订阅前缀 |	使用示例 |
| ------  |  ------ |
| `$queue/` |	`mosquitto_sub -t ‘$queue/topic’` |
| `$share/<group>/` |	`mosquitto_sub -t ‘$share/group/topic’` |


#### 本地订阅(Local Subscription)

本地订阅也是非标准MQTT约定。

本地订阅(Local Subscription)只在本节点创建订阅与路由表，不会在集群节点间广播全局路由，非常适合物联网数据采集应用:

```bash
mosquitto_sub -t '$local/topic'
mosquitto_pub -t 'topic'
```

使用方式: 订阅者在主题(Topic)前增加’$local/’前缀。


### MQTT会话(Clean Session)

MQTT支持Session(会话)，当MQTT客户端向服务器发起CONNECT请求时，可以通过’Clean Session’标志设置会话。

* ‘Clean Session’设置为0，表示创建一个持久会话，在客户端断开连接时，会话仍然保持并保存离线消息，直到会话超时注销。
* ‘Clean Session’设置为1，表示创建一个新的临时会话，在客户端断开时，会话自动清除销毁。



MQTT 方法定义很简单：

* 连接 - 建立与 MQTT 经纪人（Broker）之间的连接。
* 断开连接 - 断开与 MQTT 经纪人（Broker）之间的连接。
* 发布 - 在 MQTT 经纪人（Broker）上发布主题。
* 订阅 - 从 MQTT 经纪人（Broker）上订阅主题。
* 退订 - 从 MQTT 经纪人（Broker）上退订主题。


## Open Source MQTT Server

* [VerneMQ](https://vernemq.com) Erlang
* [EMQ](http://emqtt.com) Erlang
  * 文档：http://emqtt.com/docs/v2/getstarted.html
* [Mosca](https://github.com/mcollina/mosca) NodeJS
* [Mosquitto](https://github.com/eclipse/mosquitto) C



### EMQ

支持MQTT 3.1.1协议。
EMQ 2.0消息服务器默认占用的TCP端口包括:

* 1883  MQTT协议端口
* 8883  MQTT(SSL)端口
* 8083  MQTT(WebSocket), HTTP API端口
* 18083 Dashboard管理控制台端口


https://github.com/emqtt/emq-docker
https://github.com/eclipse/paho.mqtt.android


* 用户登陆绑定
* 用户权限绑定，只能订阅或者发送本组织下的


## 客户端

### Android

[Eclipse Paho Android Service](http://www.eclipse.org/paho/clients/android/)

#### Install

```java
repositories {
    maven {
        url "https://repo.eclipse.org/content/repositories/paho-releases/"
    }
}


dependencies {
    compile 'org.eclipse.paho:org.eclipse.paho.client.mqttv3:1.1.0'
    compile 'org.eclipse.paho:org.eclipse.paho.android.service:1.1.1'
}
```


The Paho Android Service needs the following permissions to work:

```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```

#### Usage


```java
Log.i(LOGTAG, "MQTT Start");

//如果是走 "ssl://192.168.0.13:8883"
final MqttAndroidClient mqttAndroidClient = new MqttAndroidClient(
  getApplicationContext(), "tcp://192.168.0.13:1883", clientId);


//设置回调，在这里接收订阅的消息
mqttAndroidClient.setCallback(new MqttCallbackExtended() {
  @Override
  public void connectComplete(boolean reconnect, String serverURI) {

      if (reconnect) {
          Log.i(LOGTAG, "Reconnected to : " + serverURI);
          // if Clean Session is true, we need to re-subscribe
          // subscribe('SampleTopic');
      } else {
          Log.i(LOGTAG, "Connected to: " + serverURI);
      }
  }

  @Override
  public void connectionLost(Throwable cause) {
      Log.i(LOGTAG, "The Connection was lost.");
  }

  @Override
  public void messageArrived(String topic, MqttMessage message) throws Exception {
      Log.i(LOGTAG, "Incoming message: " + new String(message.getPayload()));
  }

  @Override
  public void deliveryComplete(IMqttDeliveryToken token) {
  }
});

MqttConnectOptions mqttConnectOptions = new MqttConnectOptions();
mqttConnectOptions.setAutomaticReconnect(true);
mqttConnectOptions.setCleanSession(false);
mqttConnectOptions.setUserName("USERNAME");
mqttConnectOptions.setPassword("PASSWORD".toCharArray());
try {
  //第二个参数是可选的object,可以传递给回调函数
  client.connect(mqttConnectOptions, null, new IMqttActionListener() {
    @Override
    public void onSuccess(IMqttToken mqttToken) {
      Log.i(LOGTAG, "Client connected");
      Log.i(LOGTAG, "Topics="+mqttToken.getTopics());
      subscribe('sampleTopic');
    }

    @Override
    public void onFailure(IMqttToken arg0, Throwable arg1) {
      // TODO Auto-generated method stub
      Log.i(LOGTAG, "Client connection failed: "+arg1.getMessage());
    }
  });
}

public void subscribe(String topic){
  try {
    mqttAndroidClient.subscribe(topic, 0, null, new IMqttActionListener() {
      @Override
      public void onSuccess(IMqttToken asyncActionToken) {
          Log.i(LOGTAG, "Subscribed!");
      }

      @Override
      public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
          Log.i(LOGTAG, "Failed to subscribe");
      }
    });

    // THIS DOES NOT WORK!
    mqttAndroidClient.subscribe(topic, 0, new IMqttMessageListener() {
      @Override
      public void messageArrived(String topic, MqttMessage message) throws Exception {
          // message Arrived!
          System.out.println("InMessage: " + topic + " : " + new String(message.getPayload()));
      }
    });

  } catch (MqttException ex){
    System.err.println("Exception whilst subscribing");
    ex.printStackTrace();
  }
}

public void unsubscribe(String topic){
  try {
    mqttAndroidClient.unsubscribe(topic, 0, null, new IMqttActionListener() {
      @Override
      public void onSuccess(IMqttToken asyncActionToken) {
          Log.i(LOGTAG, "unsubscribed!");
      }

      @Override
      public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
          Log.i(LOGTAG, "Failed to unsubscribed");
      }
    });

  } catch (MqttException ex){
    System.err.println("Exception whilst subscribing");
    ex.printStackTrace();
  }
}

public void publishMessage(String topic, String msg){
  try {
    MqttMessage message = new MqttMessage();
    message.setQos(0);
    message.setRetained(false);
    message.setPayload(msg.getBytes());
    mqttAndroidClient.publish(topic, message);
    Log.i(LOGTAG, "Message Published");
    if(!mqttAndroidClient.isConnected()){
      Log.i(LOGTAG, mqttAndroidClient.getBufferedMessageCount() + " messages in buffer.");
    }
  } catch (MqttPersistenceException e) {
    // TODO Auto-generated catch block
    e.printStackTrace();

  } catch (MqttException e) {
    // TODO Auto-generated catch block
    System.err.println("Error Publishing: " + e.getMessage());
    e.printStackTrace();
  }
}

public void disconnect(){
  try {
      IMqttToken disconToken = client.disconnect();
      disconToken.setActionCallback(new IMqttActionListener() {
          @Override
          public void onSuccess(IMqttToken asyncActionToken) {
              // we are now successfully disconnected
          }

          @Override
          public void onFailure(IMqttToken asyncActionToken,
                                Throwable exception) {
              // something went wrong, but probably we are disconnected anyway
          }
      });
  } catch (MqttException e) {
      e.printStackTrace();
  }
}
```

Demo:

* [简单DEMO](https://github.com/eclipse/paho.mqtt.android/tree/develop/paho.mqtt.android.example)
* [复杂DEMO](https://github.com/eclipse/paho.mqtt.android/tree/develop/org.eclipse.paho.android.sample)


#### IOS


[MQTT Client Framework](https://github.com/ckrey/MQTT-Client-Framework)

```objc
#import "MQTTClient.h"

MQTTSession *session = [[MQTTSession alloc] init];

//specifies the protocol to be used.
//The value of the Protocol Level field for the version 3.1.1 of the protocol is 4.
//The value for the version 3.1 is 3.
session.protocolLevel = 4;
session.clientId = @"clientId";
session.cleanSessionFlag = NO;
session.userName = @"myname";
session.password = @"secret";

[session connectToHost:@"192.168.0.1" port:1883 usingSSL:NO];
```

启用SSL use a custom security

```objc
NSString* certificate = [[NSBundle bundleForClass:[MQTTSession class]] pathForResource:@"certificate" ofType:@"cer"];
session.securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeCertificate];
session.securityPolicy.pinnedCertificates = @[ [NSData dataWithContentsOfFile:certificate] ];
session.securityPolicy.allowInvalidCertificates = YES;
[session connectToHost:@"192.168.0.1" port:8883 usingSSL:YES];

//Use  client certificates:
NSString *path = [[NSBundle bundleForClass:[MQTTClientTests class]] pathForResource:parameters[@„client"] ofType:@"p12"];

session.certificates = [MQTTSession clientCertsFromP12:path passphrase:@„secret“];

[session connectToHost:@"192.168.0.1" port:8883 usingSSL:YES];
```

```objc
[session publishData:[@"Sample Data" dataUsingEncoding:NSUTF8StringEncoding]
    topic:@"example/data"
    retain:NO
    qos:0];
[session subscribeToTopic:@"example/#" atLevel:2]; //atLevel is QoS level
[session unsubscribeTopic:@"example/#"];
[session close];
```

Demo: https://github.com/ckrey/MQTTChat

#### Nodejs

    npm install mqtt


https://github.com/mqttjs/MQTT.js

```coffee
mqtt = require('mqtt')
client  = mqtt.connect('mqtt://127.0.0.1', clientId: 'MQTTCLI1', clean:false,username:'',password:'')

client.on 'connect', ->
  console.log('connect')
  client.subscribe 'presence', (err, granted)->
    return client.end() if err
    console.log 'subscribe ok', granted
    # client.publish 'presence', 'Hello mqtt', (err)->
    #   console.log 'publish'
    #   console.log 'pub', err if err

client.on 'error', (error)->
  console.log error

# received messages:
client.on 'message', (topic, message)->
  # message is Buffer
  console.log(topic, message.toString())
  # client.end()
```

SSL:

```js
var mqtt = require('mqtt')
var fs = require('fs')
var path = require('path')
var KEY = fs.readFileSync(path.join(__dirname, '/tls-key.pem'))
var CERT = fs.readFileSync(path.join(__dirname, '/tls-cert.pem'))
var TRUSTED_CA_LIST = fs.readFileSync(path.join(__dirname, '/crt.ca.cg.pem'))

var PORT = 8443
var HOST = 'stark'

var options = {
  port: PORT,
  host: HOST,
  key: KEY,
  cert: CERT,
  rejectUnauthorized: true,
  // The CA list will be used to determine if server is authorized
  ca: TRUSTED_CA_LIST
}

var client = mqtt.connect(options)

client.subscribe('messages')
client.publish('messages', 'Current time is: ' + new Date())
client.on('message', function (topic, message) {
  console.log(message)
})

client.on('connect', function () {
  console.log('Connected')
})
```

Demo: https://github.com/mqttjs/MQTT.js/tree/master/examples
