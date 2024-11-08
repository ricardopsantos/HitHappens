#!/bin/bash

clear

doWork() {
	if which periphery >/dev/null; then
        periphery scan --project "SmartApp.xcodeproj" --schemes "SmartApp Production" --targets "SmartApp" --format xcode
	else
		echo "warning: Periphery not installed, download from https://github.com/peripheryapp/periphery"
		exit -1
	fi
}

if [ -n "$USER" ]; then
	if [ "$USER" == "runner" ]; then
		echo "AppCenter build. Ignored."
		exit 0
	else
		doWork
	fi
else
	echo "\$USER not set. Ignored."
fi


