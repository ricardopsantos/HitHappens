#!/bin/bash

clear

doWork() {
	rm -rf "Pods/TspEdgeIOVSDK/TspEdgeIOVSDK.framework"
	cp -f "Frameworks-PreCompiled/TspEdgeIOVSDK.zip" "Pods/TspEdgeIOVSDK"
	cd Pods/TspEdgeIOVSDK
	unzip TspEdgeIOVSDK.zip
	rm TspEdgeIOVSDK.zip
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

