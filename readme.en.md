日本語説明は[こちら](README.md)

# About DeviceConnect iOS

Device Connect WebAPI in WebAPI which operates as a virtual server on the smartphone, it can be easy to use in a uniform description of various wearable devices and IoT devices from a Web browser and apps.
Device Connect iOS will be the platform of DeviceConnect of iOS version.

In this guide I will continue to discuss the following.

* Build Device Connect SDK
* Project description
* Development of Device Connect app
* Generate a Doxygen of Device Connect SDK
* Build Manuals
* Xcode version to support


# Build Device Connect SDK
Download DeviceConnect-Android source code.

```
$ curl -LkO https://github.com/DeviceConnect/DeviceConnect-iOS/archive/master.zip
$ unzip master.zip
```

Build Device Connect SDK

```sh
$ cd DeviceConnect-iOS-master/dConnectSDK/dConnectSDKForIOS/
$ xcodebuild -scheme DConnectSDK_framework -configuration Release
```

The framework and bundle are generated in `DeviceConnect-iOS-master / dConnectSDK / dConnectSDKForIOS / bin` folder.


# Project description
## dConnectDevicePlugin
| Project Name|Content  |
|:-----------|:---------|
|dConnectDeviceAllJoyn|Device Plug-in for AllJoyn.|
|dConnectDeviceAWSIoT|Device Plug-in for AWSIoT|
|dConnectDeviceChromeCast|Device Plug-in for Chromecast.|
|dConnectDeviceHitoe|Device Plug-in for Hitoe.|
|dConnectDeviceHost|Device Plug-in for iOS.|
|dConnectDeviceHue|Device Plug-in for Hue.|
|dConnectDeviceIRKit|Device Plug-in for IRKit.|
|dConnectDeviceLinking|Device Plug-in for Linking.|
|dConnectDevicePebble|Device Plug-in for Pebble.|
|dConnectDeviceSonyCamera|Device Plug-in for SonyCamera such as QX10.|
|dConnectDeviceSphero|Device Plug-in for Sphero.|
|dConnectDeviceTheta|Device Plug-in for THETA.|
|dConnectDeviceTest|Device plug-in for test of DeviceConnect.|
|DCMDevicePluginSDK|Common proprietary extension Profile library. |

## dConnectSDK
| Project Name|Content  |
|:-----------|:---------|
|dConnectBrowser| Browser app for DeviceConnect.|
|dConnectBrowserForIOS9| Browser app for DeviceConnect. For iOS9 after.|
|dConnectSDKForIOS|DeviceConnect library for the platform body. Want to use this library when you want to create a device plug-ins and native apps.|
|dConnectSDKSample|App to execute JavaScript for testing DeviceConnect.|


# Development of Device Connect app
Application and using the DeviceConnect, regard the development of the application, please refer to the following pages.

* [Application Development Manual](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/ApplicationManual-20)<br>
If you want to develop an application that uses the Device Connect Manager, please refer to this device plug-in development manual.

* [Device plug-in development manual](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/DevicePluginManual-20)<br>
If you want to develop a plug-in device that corresponds to the Device Connect Manager, please refer to this device plug-in development manual.


# Generate a Doxygen of Device Connect SDK
Execute the following command to output Doxygen.

```
$ cd DeviceConnect-iOS-master/dConnectSDK/dConnectSDKForIOS
$ doxygen Doxyfile
```

# Build Manuals
To install the dConnectBrowser to iOS terminal, first finished the Developer registration of Xcode installation and iOS, please keep in create an environment that can actual transfer.<br>

In this state, please start the DeviceConnect.xcworkspace. In the workspace that is started, a list of device plug-ins and dConnectBrowser of projects that have been implemented in the dConnectBrowser appears.<br>

Basically, you work with start-up of dConnectBrowser only, such as when you make changes to the other device plug-ins please refer to the following build instructions.

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


# Xcode version to support
Device plug-ins DeviceConnect does not support the build execution other than Xcode referred to below.

|Device Plug-in Name|Xcode version|
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
|Hitoe|7.2.1 or under|
|AWSIoT|8.0|
