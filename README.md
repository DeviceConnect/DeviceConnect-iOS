Click [here](readme.en.md) for description of English. 

# DeviceConnect-iOS について

DeviceConnect-iOSはiOS版のDeviceConnectのプラットフォームになります。

このガイドでは以下のことについて解説していきます。

* Device Connect SDKのビルド
* プロジェクトの説明
* Device Connectアプリケーションの開発
* Device Connect SDKのDoxygen出力
* ビルドマニュアル
* サポートするXcodeのバージョン

# Device Connect SDKのビルド

DeviceConnect-iOS のソースコードをダウンロードし、解凍します。

```
$ curl -LkO https://github.com/DeviceConnect/DeviceConnect-iOS/archive/master.zip
$ unzip master.zip
```

Device Connect SDK をビルドします。

```sh
$ cd DeviceConnect-iOS-master/dConnectSDK/dConnectSDKForIOS/
$ xcodebuild -scheme DConnectSDK_framework -configuration Release
```

`DeviceConnect-iOS-master/dConnectSDK/dConnectSDKForIOS/bin` フォルダに framework と bundle が生成されます。

# プロジェクトの説明
## dConnectDevicePlugin
| プロジェクト名|内容  |
|:-----------|:---------|
|dConnectDeviceAllJoyn|AllJoynのプラグイン。|
|dConnectDeviceAWSIoT|AWSIoTのプラグイン。|
|dConnectDeviceChromeCast|Chromecastのプラグイン。|
|dConnectDeviceHitoe|Hitoeのプラグイン。|
|dConnectDeviceHost|iOS端末のプラグイン。|
|dConnectDeviceHue|Hueのプラグイン。|
|dConnectDeviceIRKit|IRKitのプラグイン。|
|dConnectDeviceLinking|Linkingのプラグイン。|
|dConnectDevicePebble|Pebbleのプラグイン。|
|dConnectDeviceSonyCamera|QX10などのSonyCameraのプラグイン。|
|dConnectDeviceSphero|Spheroのプラグイン。|
|dConnectDeviceTheta|THETAのプラグイン。|
|dConnectDeviceTest|DeviceConnectのテスト用のプラグイン。|
|DCMDevicePluginSDK|共通の独自拡張Profileライブラリ。 |

## dConnectSDK
| プロジェクト名|内容  |
|:-----------|:---------|
|dConnectBrowser|DeviceConnect用のBrowserアプリ。|
|dConnectBrowserForIOS9|DeviceConnect用のiOS9以降用Browserアプリ。|
|dConnectSDKForIOS|DeviceConnectのプラットフォーム本体用ライブラリ。このライブラリをプラグインやネイティブアプリを作成するときに使用する。|
|dConnectSDKSample|DeviceConnectのJavaScript用テストを実行するためのアプリ。|


# Device Connectアプリケーションの開発
iOS版Device Connectを使用したアプリケーション開発および、プラグイン開発に関しましては、以下のページを参考にしてください。

* [アプリケーション開発マニュアル](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/ApplicationManual-20)<br>
Device Connect Managerを使用したアプリケーション開を開発したい場合には、こちらのアプリケーション開発マニュアルをご参照ください。

* [プラグイン開発マニュアル](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/DevicePluginManual-20)<br>
Device Connect Managerに対応したプラグインを開発したい場合には、こちらのプラグイン開発マニュアルをご参照ください。

# Device Connect SDKのDoxygen出力
以下のコマンドを実行することで、Doxygenを出力します。

```
$ cd DeviceConnect-iOS-master/dConnectSDK/dConnectSDKForIOS
$ doxygen Doxyfile
```

# ビルドマニュアル

* [dConnectBrowser](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/dConnectBrowser-Build)
* [dConnectBrowserForIOS9](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/dConnectBrowserForIOS9-Build)
* [AllJoyn](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/AllJoyn-Build)
* [ChromeCast](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/ChromeCast-Build)
* [Host](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Host-Build)
* [Hue](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Hue-Build)
* [IRKit](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/IRKit-Build)
* [Linking](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Linking-Build)
* [Pebble](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Pebble-Build)
* [SonyCamera](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/SonyCamera-Build)
* [Sphero](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Sphero-Build)
* [Theta](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Theta-Build)
* [Hitoe](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Hitoe-Build)
* [AWSIoT](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/AWSIoT-Build)

# サポートするXcodeのバージョン
DeviceConnectのプラグインは、下記に記すXcode以外でのビルド・実行をサポートしていません。

|プラグイン名|Xcodeバージョン|
|:--|:--|
|ChromeCast|8.0|
|Host|8.0|
|Hue|8.0|
|IRKit|8.0|
|Pebble|8.0|
|SonyCamera|8.0|
|Sphero|8.0|
|Theta|8.0|
|AllJoyn|8.0|
|Linking|8.0|
|Hitoe|7.2.1以下|
|AWSIoT|8.0|
