# DeviceConnect-iOS
* 日本語説明はこちら
https://github.com/DeviceConnect/DeviceConnect-iOS/blob/master/readme.ja.md

# About DeviceConnect WebAPI
"DeviceConnect WebAPI" is WebAPI which operates as a virtual server on a smart phone. It can use easily various wearable devices and an IoT device by unific description from a web browser or an application.

# About DeviceConnect iOS

Device Connect WebAPI in WebAPI which operates as a virtual server on the smartphone, it can be easy to use in a uniform description of various wearable devices and IoT devices from a Web browser and apps.
Device Connect iOS will be the platform of DeviceConnect of iOS version.

In this guide I will continue to discuss the following.

* [Project description](#section1)
* [Build and start-up of dConnectBrowser](#section2)
* [Operation check](#section3)
* [Development of DeviceConnect app](#section4)

# <a name="section1">Project description</a>
## dConnectDevicePlugin
| Project Name|Content  |
|:-----------|:---------|
|dConnectDeviceAllJoyn|Device Plug-in for AllJoyn.|
|dConnectDeviceChromeCast|Device Plug-in for Chromecast.|
|dConnectDeviceHost|Device Plug-in for iOS terminal.|
|dConnectDeviceHue|Device Plug-in for Hue.|
|dConnectDeviceIRKit|Device Plug-in for IRKit.|
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
|dConnectSDKForIOS|DeviceConnect library for the platform body. Want to use this library when you want to create a device plug-ins and native apps.|
|dConnectSDKSample|App to execute JavaScript for testing DeviceConnect.|

# <a name="section2">Build and start-up of dConnectBrowser</a>
To install the dConnectBrowser to iOS terminal, first finished the Developer registration of Xcode installation and iOS, please keep in create an environment that can actual transfer.<br>

In this state, please start the DeviceConnect.xcworkspace. In the workspace that is started, a list of device plug-ins and dConnectBrowser of projects that have been implemented in the dConnectBrowser appears.<br>

Basically, you work with start-up of dConnectBrowser only, such as when you make changes to the other device plug-ins please refer to the following build instructions.

* [dConnectBrowser](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/dConnectBrowser-Build)
* [AllJoyn](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/AllJoyn-Build)
* [ChromeCast](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/ChromeCast-Build)
* [Host](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Host-Build)
* [Hue](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Hue-Build)
* [IRKit](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/IRKit-Build)
* [Pebble](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Pebble-Build)
* [SonyCamera](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/SonyCamera-Build)
* [Sphero](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Sphero-Build)
* [Theta](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/Theta-Build)


# <a name="section3">Operation check</a>
 To dConnectBrowser the address bar `http://localhost:4035/gotapi/availability` Please enter the.<br>
If this response is returned in the following, such as JSON, you will be able to make sure that DeviceConnect is running.<br>

 <center><a href="https://raw.githubusercontent.com/wiki/DeviceConnect/DeviceConnect-iOS/imageX.PNG" target="_blank">
<img src="https://raw.githubusercontent.com/wiki/DeviceConnect/DeviceConnect-iOS/imageX.PNG" border="0"
 width="320" height="550" alt="" /></a></center>

 Request

 ```
 GET http://localhost:4035/gotapi/availability
 ```

 Response

 ```
 {
     "product":"Device Connect Manager",
     "version":"x.x",
     "result":0,
}
 ```

The API of the non-availability, you will not be able to easily check is basically to dConnectBrowser of address in order to access token is required to.
If you want to create an application using the API of Device Connect, please refer to us a sample of [here] (https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/ApplicationManual).

# <a name="section4">Development of DeviceConnect app</a>
Application and using the DeviceConnect, regard the development of the application, please refer to the following pages.

* [Application Development Manual](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/ApplicationManual)
 <br>
If you want to develop an application that uses the Device Connect Manager, please refer to this device plug-in development manual.
* [Device plug-in development manual](https://github.com/DeviceConnect/DeviceConnect-iOS/wiki/DevicePluginManual)<br>
If you want to develop a plug-in device that corresponds to the Device Connect Manager, please refer to this device plug-in development manual.
