# DeviceConnect iOS について


Device Connect WebAPIはスマートフォン上で仮想サーバとして動作するWebAPIで、様々なウェアラブルデバイスやIoTデバイスをWebブラウザやアプリから統一的な記述で簡単に利用することができます。
Device Connect iOSはiOS版のDeviceConnectのプラットフォームになります。


このガイドでは以下のことについて解説していきます。

* [プロジェクトの説明](#section1)
* [dConnectBrowserのビルドと起動](#section2)
* [動作確認](#section3)
* [DeviceConnectアプリの開発](#section4)


# <a name="section1">プロジェクトの説明</a>
## dConnectDevicePlugin
| プロジェクト名|内容  |
|:-----------|:---------|
|DCMDevicePluginSDK|共通の独自拡張Profileライブラリ。 |
|dConnectDeviceChromeCast|Chromecastのデバイスプラグイン。|
|dConnectDeviceHost|iOS端末のデバイスプラグイン。|
|dConnectDeviceHue|Hueのデバイスプラグイン。|
|dConnectDeviceIRKit|IRKitのデバイスプラグイン。|
|dConnectDevicePebble|Pebbleのデバイスプラグイン。|
|dConnectDeviceSonyCamera|QX10などのSonyCameraのデバイスプラグイン。|
|dConnectDeviceSphero|Spheroのデバイスプラグイン。|
|dConnectDeviceTest|DeviceConnectのテスト用のデバイスプラグイン。|


## dConnectSDK
| プロジェクト名|内容  |
|:-----------|:---------|
|dConnectBrowser| DeviceConnect用のBrowserアプリ。|
|dConnectSDKForIOS|DeviceConnectのプラットフォーム本体用ライブラリ。このライブラリをデバイスプラグインやネイティブアプリを作成するときに使用する。|
|dConnectSDKSample|DeviceConnectのJavaScript用テストを実行するためのアプリ。|



# <a name="section2">dConnectBrowserのビルドと起動</a>
　dConnectBrowserをiOS端末へインストールするには、まずXcodeのインストールとiOSのDeveloper登録を済ませ、実機転送ができる環境を整えておいてください。<br>
　その状態で、DeviceConnect.xcworkspaceを起動してください。起動されるワークスペースには、dConnectBrowserに実装されているデバイスプラグインとdConnectBrowserのプロジェクトの一覧が表示されます。<br>
　基本的には、dConnectBrowserのみの起動でも動作しますが、他のデバイスプラグインに変更を加えた場合などは以下のビルド手順書を参考にしてください。
　
* [dConnectBrowser](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/2.1.dConnectBrowser)
* [ChromeCast](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/2.2.ChromeCast)
* [Host](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/2.3.Host)
* [Hue](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/2.4.Hue)
* [IRKit](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/2.5.IRKit)
* [Pebble](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/2.6.Pebble)
* [SonyCamera](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/2.7.SonyCamera)
* [Sphero](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/2.8.Sphero)


# <a name="section3">動作確認</a>
 dConnectBrowserのアドレスバーに`http://localhost:4035/gotapi/availability`を入力してください。<br>
以下のようなJSONのレスポンスが返って来れば、DeviceConnectが動作していることを確認することができます。<br>
 
 <center><a href="https://raw.githubusercontent.com/wiki/DeviceConnect/DeviceConnect-iOS/imageX.PNG" target="_blank">
<img src="https://raw.githubusercontent.com/wiki/DeviceConnect/DeviceConnect-iOS/imageX.PNG" border="0"
 width="320" height="550" alt="" /></a></center>
 
 リクエスト
 
 ```
 GET http://localhost:4035/gotapi/availability
 ```
 
 レスポンス
 
 ```
 {
     "product":"Device Connect Manager",
     "version":"x.x",
     "result":0,
}
 ```
 
 
  availability以外のAPIには、基本的にはアクセストークンが必要になるためにdConnectBrowserのアドレスでは簡単に確認することができません。
Device Connect の APIを使用してアプリケーションを作成する場合には、[こちら](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/1.1.ApplicationManual)のサンプルをご参考にしてください。
 
 
 
# <a name="section4">DeviceConnectアプリの開発</a>
 DeviceConnectを使ったアプリケーションおよび、アプリケーションの開発に関しましては、以下のページを参考にしてください。
 
 * [アプリケーション開発マニュアル](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/1.1.ApplicationManual)
 <br>
 Device Connect Managerを使用したアプリケーションを開発したい場合には、こちらのデバイスプラグイン開発マニュアルをご参照ください。
 
 * [デバイスプラグイン開発マニュアル](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/1.2.DevicePluginManual)<br>
Device Connect Managerに対応するデバイスプラグインを開発したい場合には、こちらのデバイスプラグイン開発マニュアルをご参照ください。
