# DeviceConnect iOS について


Device Connect WebAPIはスマートフォン上で仮想サーバとして動作するWebAPIで、様々なウェアラブルデバイスやIoTデバイスをWebブラウザやアプリから統一的な記述で簡単に利用することができます。
Device Connect iOSはiOS版のDeviceConnectのプラットフォームになります。

動作確認などに関しましては、[こちら](https://github.com/DeviceConnect/DeviceConnect-Docs)を参照してください。

このガイドでは以下のことについて解説していきます。

* プロジェクトの説明


# プロジェクトの説明
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



