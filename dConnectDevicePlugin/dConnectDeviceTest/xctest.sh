#!/bin/sh

xcodebuild -scheme dConnectDeviceTest -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6' clean test OBJROOT=build SYMROOT=build 2>&1 | ocunit2junit
ant -f xctest-report.xml
