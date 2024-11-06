#!/bin/bash

export PATH="$PATH:/opt/homebrew/bin"

doWork() {
	swiftformat --config .swiftformat.yml . --swiftversion 5.6
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

