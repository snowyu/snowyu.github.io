---
author: riceball
date: 2017-12-08 12:53:56+08:00
updated: 2019-11-26 13:00:00+08:00
title: Ionic Framework
category:
  - JavaScript
  - Framework
  - App
tags:
  - nodejs
  - javascript
  - app
  - mobile
  - framework
  - creation
---


# Ionic Framework

Ionic 4 已经彻底解耦用户界面和框架,你可以在`angular`和`react`(甚至`vue`)之间选择.

    npm i -g ionic

已经是用angluar-cli(angular6配套的)。已经使用了angular的route.

https://update.angular.io 从老版本Angular升级到Angular6的指南。


现在可以大致介绍下使用方法。更完整的教程请自行阅读：

* [Ionic 2 With TypeScript 入门](https://yanxiaodi.gitbooks.io/ionic2-guide/content/)
* [ionic2学习笔记《一》](https://meiminjun.github.io/2016/08/01/ionic2学习笔记《一》/)

如果与上述的教程有冲突，请留意文档时间，以最新的为准。

环境要求

* Node LTS版本(官方推荐)

首先安装

    npm install -g ionic cordova

## 创建应用

**注意：如果是windows下，请勿在cygwin或msys2终端下运行 `ionic` 命令行工具。**

通过脚手架工具`ionic`创建您的H5应用。

    ionic start --type=angular MyApp conference

>conference 参数的意思是下载 [tutorial](https://github.com/ionic-team/ionic-conference-app) 模板来初始化项目，如果不指定这个参数的话，默认会使用 [tabs](https://github.com/ionic-team/ionic-starter-tabs) 模板。
>MyApp 可以替换成你的应用程序名称。
>--type 表示当前生成的是 angular 的应用。
>`ionic start --list` 可以查看所有starting项目模板。

这个命令将下载项目模板，安装 npm modules，设置 Cordova 的相关信息。

如果安装npm 模块失败，你可以手动进入项目目录安装：

```bash
cd MyApp
npm install
```

你的项目代码在src目录下。

## 在浏览器运行

```bash
cd MyApp
ionic serve -l
```

>`-l`(--lab) 参数将在浏览器中模拟多个手机设备。

接下来 CLI 会编译项目，接着浏览器会打开一个地址为 http://localhost:8100 的窗口，端口号根据当前PC的实际情况可能会有变化，如果8100被占用了会使用8101等。


## 代码结构

* ./src/ 当我们运行`ionic serve`命令的时候，在`src/`目录下的typescript文件会被译成JavaScript
* ./src/index.html 是h5的主入口文件，设置脚本和CSS，运行整个App。
* ./src/app/app.module.ts 是angular2 应用的入口。
* ./src/app/app.html 是应用的模板文件

## 添加页面


    ionic g page login


Note: 懒加载的Page为独立的Module。
Ionic的懒加载Page很愚蠢，是编译时刻由ionic的app-scripts处理的(deep links config)，
必须是page.moudle.ts与page.compnent.ts分开文件（否则app-scripts会报错）

另外tab控件产生的url丑陋： https://github.com/ionic-team/ionic/issues/9012

如果不要`IonicPage`注解可以这：

```ts
export const deepLinkConfig: DeepLinkConfig = {
  links: [
    { component: OnlineCoursesPage, name: 'OnlineCourses', segment: '' },
    { component: CartPage, name: 'Cart', segment: 'cart' },
    { component: CheckoutPage, name: 'Checkout', segment: 'checkout' },
    { component: ThankYouPage, name: 'ThankYou', segment: 'thanks' },
    { component: AccountPage, name: 'Account', segment: 'account' },
    { component: RegisterPage, name: 'Register', segment: 'register' },
    { component: ForgotPasswordPage, name: 'ForgotPassword', segment: 'account' },
    { component: ForgotUsernamePage, name: 'ForgotUsername', segment: 'account' },
    { component: OnlineCoursesPage, name: 'OnlineCourses', segment: ':statename/:licensetypename/online-course-results' },
    { component: CorrespondencePage, name: 'Correspondence', segment: ':statename/:licensetypename/correspondence' },
    { component: LiveSeminarsPage, name: 'LiveSeminars', segment: ':statename/:licensetypename/search-seminars-list' },
    { component: LiveWebinarsPage, name: 'LiveWebinars', segment: ':statename/:licensetypename/webinar' },
    { component: LicensingInfoPage, name: 'Licensing', segment: ':statename/:licensetypename/licensing-info' }
  ]
};

  imports: [
    IonicModule.forRoot(MyApp, { locationStrategy: 'path' }, deepLinkConfig)
  ],
```
目前ionic 在分支core上在重构(使用Web Component)，支持angular5 router: https://github.com/ionic-team/ionic/tree/core/packages/demos/ng-tab-routing

* https://github.com/apoterenko/ngx-dynamic-template
* https://github.com/gund/ng-dynamic-component


或不用ionic-cli，改用 angluar-cli:

* https://github.com/ngx-rocket/generator-ngx-rocket
  * UI: 支持 Bootstrap 4, ionic, angular-material
  * mobile: 支持 cordova
  * 但是lighthouse性能评分极差
  * 不过ngx可以作为自己的cli 命令行app产生器参考。
* https://github.com/Robinyo/ionic-angular-schematics
  * 绑定在ionic，算是ionic的angular-cli替代。
  * 有 Dynamic Theme Support 代码可以参考。


ionic 4将使用Web Component(通过stencil编译)的方式，来改变目前绑定在Angular框架的局面，
这样ionic的组件就和框架无关了，你可以用在任何框架上面使用， vue, react 都不是问题.

## [Announcing PWA support in Ionic2](http://blog.ionic.io/announcing-pwa-support-in-ionic-2/)

We also provide the service worker registration code in your index.html file.

```js
if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('service-worker.js')
        .then(() => console.log('service worker installed'))
        .catch(err => console.log('Error', err));
}
```

To enable the service worker, you can simply uncomment that registration code, and you’ll be ready to go! You’ll find the service-worker.js file in the www folder of your Ionic project.

For examples of service workers, check out the [ServiceWorker Cookbook](https://serviceworke.rs/) by Mozilla and the Google Chrome team’s [repo of example service workers](https://github.com/GoogleChrome/samples/tree/gh-pages/service-worker).

We’re very excited to start supporting PWA’s out of the box with Ionic and plan on steadily improving this support in the future. We are currently considering support for server-side rendering to get a blazing-fast first render and convenient hosting with the Ionic Cloud. Our service worker support will also be evolving in the near future to allow for automatic configuration of service workers. This will give your PWA offline support right out of the box, without you having to write any code. We cannot wait to see the awesome PWAs that you build! Stay tuned to our blog and our docs for updates!


## Best Practise

src/app 存放本应用下的公用部分，以及app模块本身。

### Main App Module

该模块为主页面的入口

src/app/app.module.ts
src/app/app.comonent.ts
src/app/app.scss
src/app/app.html

### Shared Module

在本应用的其它Module中需要用到的模块统一放在此处。

src/shared/app.imports.ts   本应用内所有要导入的组件，指令，模块，pipe

```ts
export const MODULES = [
  SwingModule,
  BrowserModule,
  HttpClientModule,
];

export const PROVIDERS = [
  AlertService,
  ToastService,
  AppState,
  CameraProvider,
  NativeGoogleMapsProvider,

  // Ionic native specific providers
  BarcodeScanner,
  Camera,
  Diagnostic,
  Geolocation,
  CardIO,
  StatusBar,
  SplashScreen,
  GoogleMaps,
];

export const DIRECTIVES = [
  SlidingDrawer,
  Autosize,
];
```

src/shared/shared.module.ts

```ts
import { PipesModule } from '../pipes/pipes.module';
import { ComponentsModule } from '../components/components.module';
import { DIRECTIVES } from './app.imports';
import { NgModule } from '@angular/core';
import { IonicModule } from 'ionic-angular';

@NgModule({
  declarations: [
    DIRECTIVES,
  ],
  imports: [
    IonicModule,
    PipesModule,
    ComponentsModule,
  ],
  exports: [
    ComponentsModule,
    PipesModule,
  ]
})

export class SharedModule { }
```

shared/ 这是第三方的库

### MicroApp


## Capacitor

如果想试用 `capacitor` 代替 Cordavo：

    npm install --save @capacitor/core @capacitor/cli

Next init Capacitor by running the following command with your ap information

    npx cap init ionic-capacitor-app com.techiediaries.myapp

Make sure to use your app name for the first parameter and your app id for the second parameter ( `npx cap init [appName] [appId]` ).

This command will add a capacitor.config.json inside your project folder with the following content

```js
{
  "appId": "com.techiediaries.myapp",
  "appName": "ionic-capacitor-app",
  "bundledWebRuntime": false,
  "webDir": "www"
}
```

Now you need to generate the www folder with the Ionic app built files by running the build command:

    npm run build


### Adding the Android Platform

before you can run your app you need to add a platform either android, ios or web so let's add the Android platform

```bash
npx cap add android
npx cap sync
```

You can also use the copy command instead of sync

    npx cap copy

The difference is that copy will only copy the web assets but sync will also update native dependencies so use it if you have added any native dependencies.

Now you can open your Android project using the Android Studio using:

    npx cap open

This will prompt you to choose a platform to open android, ios or web select android for Android.

If that doesn't open Android Studio you can simply open Android Studio manually and then File->Open... command then navigate to your project and open the android folder.

You can now use Android Studio to launch your app using an emulator or a real device.

Next we'll see how to use Capacitor plugins to access native device features such as the Camera and Geolocation.


## 问题

https://leifwells.github.io/2017/08/27/testing-in-ionic-configure-existing-projects-for-testing/
https://robferguson.org/blog/2017/11/28/testing-your-ionic-3-app/

### /asserts/html/index.html 连接不成功(can not unsuccessful connect)，(webview)

里面的脚本太多加载超时导致。
在java中加入:

```java
super.setIntegerProperty("loadUrlTimeoutValue", 700000);
```

或者在项目根目录 `config.xml`的 `andorid platform` 中加入:

```xml
<preference name="loadUrlTimeoutValue" value="700000" />
```



### ionic-angular 的每一个版本总是和对应的angular版本绑定的

不要轻易变动，除非你知道对应的angular版本。

    "ionic-angular": "^2.0.0-rc.3-201612080433",
    "@angular/core": "2.2.1",

否则报错：

    __WEBPACK_IMPORTED_MODULE_0__angular_core__.Version is not a constructor



### Can not import constants!

https://github.com/driftyco/ionic-app-scripts/issues/439

Ask:
In my case i've got a regular ionic projekt.
i npm install a second project (which is typescript only - no js bundles, no transpiled JS) in my ionic project.
the second project contains interfaces, enums, constants... which i share between two projects (node server and ionic app).
when i import interfaces -> no problem.
when i import constants --> Cannot read property 'content' of undefined.

Answer:
Here's what you would need to do:

Create the library of Typescript for Ionic
Transpile the Typescript to Javascript
Use NPM (or NPM link) to get your library in node_modules
Code as normal

We can't support Typescript from a third party library at this time. It's gotta be converted to Javascript because that is how libraries are distributed 99% of the time.



### Click Delays 点击延迟问题

熟悉前端的应该都知道，某些元素在click事件会有300ms的延迟，
在ionic里也是只有button和a可以立即响应的。如果要给其他的
元素比如div增加click事件，给该元素加上`tappable`属性即可解决。


### http请求跨域问题

在ionic2里使用angular2的HTTP请求api时，如果在浏览器里运行，经常会遇到跨域问题，比如：

    XMLHttpRequest cannot load http://www.xxx.com/clt/jsp/v3/channelContList.jsp?n=25950&WD-UUID=864819028898243&pageidx=1. No 'Access-Control-Allow-Origin' header is present on the requested resource. Origin 'http://localhost:8101' is therefore not allowed access.

这是因为chrome不允许跨域访问。解决方法很简单，给chrome装一个ripple扩展，然后点击ripple，
选择启用，就可以跨域访问了。

如果是自己同时开发api和app，很有可能api也是部署在本机上，比如api地址是http://localhost/api，
`ionic serve`跑起来后是http://localhost:8100，这样在调用的时候又会遇到Internet Server Error的问题，比如：

    Error code is:xhr_proxy?tinyhippos_apikey=ABC&tinyhippos_rurl=http%3A//localhost%3A30673/ap‌​i/user/Get%3Fjson rippleapi.herokuapp.com Status Code:500 Internal Server Error I'am getting data from my localhost post adress:localhost:30673/api/user/Get'; It is working well in browser . And getting data from localhost:30673/api/user/Get. But in ripple it tries to get data from There: xhr_proxy?tinyhippos_apikey=ABC&tinyhippos_rurl=http%3A//localhost%3A30673/api/u‌​ser/Get%3Fjson rippleapi.herokuapp.com

解决方法也很简单，ripple设置右上角有一个Cross Domain Proxy，有三个选择，Disabled、Local和Remote，
通过字面意思就可以看出来分别对应禁用、本地和远程访问，如果是访问本机的api的话，一般设置为Disabled就可以了。
如果访问远程主机的api，一般要设置为Remote或Disabled。


### 引用第三方js库的问题

开发过程中不可避免的要用到第三方js库，如果直接在TypeScript里写的话，编译器是认不出来的，
会报错，编译也通不过。外部的类必须要import进来才可以用。TypeScript需要一个声明文件 d.ts
来知道第三方库的接口。可参考 https://zhongsp.gitbooks.io/typescript-handbook/content/doc/handbook/Writing%20Definition%20Files.html

如果用流行的库的话，不用我们自己写d.ts，有个开源的项目已经做好了：https://github.com/DefinitelyTyped/DefinitelyTyped
自己写的话很麻烦，特别是我用了一个项目平台的库，函数也不少，自己写的话也费时间，后来想到一个办法，

TypeScript的编译器支持自动生成d.ts，可以用命令`tsc --declaration my.ts`来生成，这个命令是给ts文件生成声明的，
但TypeScript原生支持js，可以把第三方的js改后缀名为ts，tsc也可以生成。这里我又遇到一个问题，我的库里又调用了
Cordova的一些函数，编译的话tsc找不到，解决办法是复制一份js，将所有认不出的东西都注释掉，再生成就可以了。
反正这个命令只是生成一个声明文件，具体的js只要引入进来就可以用。用这个命令很快就可以生成一份声明了，然后在用
到的地方用

    /// <reference path="../sdk.d.ts"/>

这样的方式引用。注意一定要写在文件第一行。

### 开发模式选择

这个问题只是我做的项目的特殊情况，可能大部分人遇不到。我们的平台封装了Cordova的http请求，调用api必须用指定的
方法才可以。但在chrome里调试的时候是加载不到Cordova的，于是我想了一个办法，增加一个全局的isDebug变量，封装一
个全局的http方法，在debug模式时调用angular2的HTTP来请求，正式运行时才用Cordova的。其他的service都要调用这个方
法，就无需关注是什么模式了，如果真机运行的话就改一下isDebug的值就可以了。

放一段代码：

 ```js
 /// <reference path="../sdk.d.ts"/>
 import {Injectable, Component} from '@angular/core';
 import {HTTP_PROVIDERS, Http, Response} from '@angular/http';
 import {Headers, RequestOptions} from '@angular/http';
 import {AppGlobal} from '../app-global';  6

 /**
   * HttpRequestService
   */
@Injectable()
@Component({
  providers: [HTTP_PROVIDERS,Http]
})
export class HttpRequestService {
  constructor(private http: Http) {}
  /**
    * get方法 获取json对象
    *
    * @template T
    * @param {string} server
    * @param {string} url
    * @returns {Promise<T>}
    */
  get4Json<T>(server: string, url: string): Promise<T> {
    if (AppGlobal.getInstance().isDebug) {
      return this.http.get(server + url).toPromise()
      .then(response => response.json());
    }
    else {
      let promise: Promise<T> = new Promise<T>((resolve, reject) => {
        //由于SDK必须要求传入一个参数数组，因此必须传递一个空数组作为参数
        let paramJson = [];
        SDKRequest.get4Json(server, url, paramJson, function (resp) {
          resolve(resp);
        }, function (error) {
          reject(error);
        });
      });
      return promise;
    }
  }
 }

```
angular2的http是用的Promise，但平台提供的方法用的callback，于是需要在这里将回调函数的方式改为Promise的方式，
不管是不是debug模式都返回一个Promise，这样上层调用的时候就方便了。我是看的这里：

https://basarat.gitbooks.io/typescript/content/docs/promise.html

在angular2的官方文档中，是推荐用Observable模式的，但我还没有搞明白怎么将callback转为Observable，目前也没有时间
仔细研究这块，所以还是继续用Promise好了。


### 单例模式

单例是经常用到的，我参考一个老外的代码用了一个单例，用来保存一些全局变量：

```js
import {UserInfo} from './model/user';

/** * AppGlobal 全局定义 单例模式 */
export class AppGlobal {
  private static instance: AppGlobal = new AppGlobal();
  /**是否是调试状态 */
  isDebug: boolean = true;
  server: string = this.isDebug ? "http://localhost" : "http://www.xxx.com";
  apiUrl: string = "/MobileApi/api";
  /**当前用户信息 */
  currentUserInfo: UserInfo = new UserInfo();
  /**分页页数 */
  pageSize: number = 10;

  constructor() {
    if (AppGlobal.instance) {
      throw new Error("错误: 请使用AppGlobal.getInstance() 代替使用new.");
    }
    AppGlobal.instance = this;
  }
  /**
    * 获取当前实例 *
    * @static * @returns {AppGlobal}
    */
  public static getInstance(): AppGlobal { return AppGlobal.instance; }
}
```

### Lazy loading

https://github.com/didinj/ionic3-angular4-sample-app

每一个页面都是一个 Module，通过pageModule来实现懒加载。
Angluar4本身的router loadChildren也是这样做的。


### 程序的自动更新

既然是html自然可以自动更新

支持Android和iOS:
* https://github.com/nordnet/cordova-hot-code-push
  * https://github.com/nordnet/cordova-hot-code-push/issues/131 (比较文档)
* https://github.com/phonegap/phonegap-plugin-contentsync
* https://github.com/markmarijnissen/cordova-app-loader (纯js实现)

只支持 Android 是apk更新:
* https://ionicframework.com/docs/native/app-update/


https://codepureandsimple.com/implementing-cordova-hot-code-push-in-your-ionic-app-247cda24d6d4

准备用的是: cordova-hot-code-push

```bash
ionic start chcp-example blank
cd .\chcp-example
npm install -g lite-server
ionic cordova platform add android
# When prompted to install the @ionic/cli-plugin-cordova, select “Yes”.
ionic cordova plugin add cordova-hot-code-push-plugin
npm install -g cordova-hot-code-push-cli
```

```bash
~/dev/chcp-example>cordova-hcp init
Running init
Please provide: Enter project name (required):  chcp-example
Please provide: Amazon S3 Bucket name (required for cordova-hcp deploy):
Please provide: Path in S3 bucket (optional for cordova-hcp deploy):
Please provide: Amazon S3 region (required for cordova-hcp deploy):  (us-east-1)
Please provide: IOS app identifier:
Please provide: Android app identifier:
Please provide: Update method (required):  (resume) start
Please provide: Enter full URL to directory where cordova-hcp build result will be uploaded:  http://169.254.80.80:3000/updates
Project initialized and cordova-hcp.json file created.
If you wish to exclude files from being published, specify them in .chcpignore
Before you can push updates you need to run "cordova-hcp login" in project directory
```

cordova-hcp.json file in the root of your project :

```js
{
    "name": "chcp-example",
    "ios_identifier": "",
    "android_identifier": "",
    "update": "start",
    "content_url": "http://169.254.80.80:3000/updates"
}
```

Edit your `config.xml` file to turn off automatic download and automatic install. We will do this via application code:

```xml
<chcp>
    <config-file url=”http://169.254.80.80:3000/updates/chcp.json"/
    <auto-download enabled=”false” />
    <auto-install enabled=”false” />
</chcp>
```

go to your `/chcp-example/src/pages/home/home.html` file and set its contents to the following:

```html
<ion-header>
    <ion-navbar>
        <ion-title>Cordova Hot Code Push Test</ion-title>
    </ion-navbar>
</ion-header>
<ion-content padding>
    {{ foo }} {{ bar }}
</ion-content>
```

`/chcp-example/src/pages/home/home.ts`

```ts
import { Component } from '@angular/core';
import { NavController } from 'ionic-angular';
@Component({
    selector: 'page-home',
    templateUrl: 'home.html'
})
export class HomePage {
    foo: number = 1;
    bar: number = 2;
    constructor(public navCtrl: NavController) {}
}
```

/chcp-example/src/app/app.component.ts:

```ts
import { Component } from '@angular/core';
import { Platform, ModalController, AlertController } from 'ionic-angular';
import { StatusBar } from '@ionic-native/status-bar';
import { SplashScreen } from '@ionic-native/splash-screen';
import { HomePage } from '../pages/home/home';
declare var chcp: any;
@Component({
    templateUrl: 'app.html'
})
export class MyApp {
  rootPage:any = HomePage;
  constructor(platform: Platform,
  statusBar: StatusBar,
  splashScreen: SplashScreen,
  private modalCtrl: ModalController,
  private alertCtrl: AlertController) {
  platform.ready().then(() => {
    statusBar.styleDefault();
    splashScreen.hide();
    window["thisRef"] = this;
    this.fetchUpdate();
  });
}
fetchUpdate() {
  const options = {
    'config-file': 'http://169.254.80.80:3000/updates/chcp.json'
  };
  chcp.fetchUpdate(this.updateCallback, options);
}
updateCallback(error, data) {
  if (error) {
    console.error(error);
  } else {
    console.log('Update is loaded...');
    let confirm = window["thisRef"].alertCtrl.create({
      title: 'Application Update',
      message: 'Update available, do you want to apply it?',
      buttons: [
       {text: 'No'},
       {text: 'Yes',
         handler: () => {
           chcp.installUpdate(error => {
             if (error) {
               console.error(error);
               window["thisRef"].alertCtrl.create({
                 title: 'Update Download',
                 subTitle: `Error ${error.code}`,
                 buttons: ['OK']
               }).present();
             } else {
               console.log('Update installed...');
             }
           });
         }
       }
      ]
    });
    confirm.present();
   }
 }
}
```

#### Build and Run in the Android Emulator

From Android Studio, click the Tools menu, point to Android, click Android Virtual Device (AVD) Manager, and then start your virtual device. Open another command line and build the application, run the Hot Code Plugin build, and then run the application in the Android emulator:


```bash
npm run build --prod
cordova-hcp build
cordova emulate android
```

Keep your application running in the emulator, but let’s change the `/chcp-example/src/pages/home/home.ts` variables to the following to increase our chances of getting seed money from some investors:

```ts
foo: number = 4;
bar: number = 2;
```

After you update your variable values, edit the version number in your `package.json` file to increment the number to “version”: “0.0.2” and then rebuild the project and use the Hot Code Plugin CLI to rebuild our updates. If you do not update the version number, the code will not get updated, you will not get any money from any VCs, and all of your friends and LinkedIn contacts will laugh at you.

The updated code will be created in the www folder of your application.


```bash
npm run build --prod
cordova-hcp build
mkdir ../code-server
cp -r www ../code-server/updates
cd ../code-server
http-server
```



### Problems

* https://forum.ionicframework.com/t/about-to-give-up-with-ionic-3-simple-native-like-chat-page-not-possible/87548/29
  * https://github.com/driftyco/ionic/issues/7149#issuecomment-296457305

https://github.com/alexmady/KeyboardTest
https://github.com/HsuanXyz/ionic3-chat

https://github.com/mojofit/imojo
https://github.com/mojofit/node-mojo

https://github.com/jdnichollsc/Ionic-ElastiChat-with-Images
https://github.com/terikon/photo-library-demo-ionic2
https://github.com/driftyco/ionic-starter-super


