# DeviceConnect-iOS について

DeviceConnect-iOSはiOS版のDeviceConnectのプラットフォームになります。

このガイドでは以下のことについて解説していきます。

* プロジェクトの説明]
* dConnectBrowserのビルドと起動
* DeviceConnectアプリの開発
* サポートするXcodeのバージョン

# DeviceConnectSDKのビルド

DeviceConnect-iOS のソースコードをダウンロードし、解凍します。

```
$ curl -LkO https://github.com/DeviceConnect/DeviceConnect-iOS/archive/master.zip
$ unzip master.zip
```

DeviceConnectSDK をビルドします。

```sh
$ cd DeviceConnect-iOS-master/dConnectSDK/dConnectSDKForIOS/
$ xcodebuild -scheme DConnectSDK_framework -configuration Release
```

`DeviceConnect-iOS-master/dConnectSDK/dConnectSDKForIOS/bin` フォルダに framework と bundle が生成されます。

# プロジェクトの説明
## dConnectDevicePlugin
| プロジェクト名|内容  |
|:-----------|:---------|
|dConnectDeviceAllJoyn|AllJoynのデバイスプラグイン。|
|dConnectDeviceAWSIoT|AWSIoTのデバイスプラグイン。|
|dConnectDeviceChromeCast|Chromecastのデバイスプラグイン。|
|dConnectDeviceHitoe|Hitoeのデバイスプラグイン。|
|dConnectDeviceHost|iOS端末のデバイスプラグイン。|
|dConnectDeviceHue|Hueのデバイスプラグイン。|
|dConnectDeviceIRKit|IRKitのデバイスプラグイン。|
|dConnectDeviceLinking|Linkingのデバイスプラグイン。|
|dConnectDevicePebble|Pebbleのデバイスプラグイン。|
|dConnectDeviceSonyCamera|QX10などのSonyCameraのデバイスプラグイン。|
|dConnectDeviceSphero|Spheroのデバイスプラグイン。|
|dConnectDeviceTheta|THETAのデバイスプラグイン。|
|dConnectDeviceTest|DeviceConnectのテスト用のデバイスプラグイン。|
|DCMDevicePluginSDK|共通の独自拡張Profileライブラリ。 |

## dConnectSDK
| プロジェクト名|内容  |
|:-----------|:---------|
|dConnectBrowser|DeviceConnect用のBrowserアプリ。|
|dConnectBrowserForIOS9|DeviceConnect用のiOS9以降用Browserアプリ。|
|dConnectSDKForIOS|DeviceConnectのプラットフォーム本体用ライブラリ。このライブラリをデバイスプラグインやネイティブアプリを作成するときに使用する。|
|dConnectSDKSample|DeviceConnectのJavaScript用テストを実行するためのアプリ。|

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
DeviceConnectのデバイスプラグインは、下記に記すXcode以外でのビルド・実行をサポートしていません。

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
