#!/bin/bash

clear

doWork() {
	xcrun simctl shutdown all
	exit 0
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
