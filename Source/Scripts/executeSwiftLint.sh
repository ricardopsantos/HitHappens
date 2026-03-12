#!/bin/bash

clear

export PATH="$PATH:/opt/homebrew/bin"

doWork() {
	if which swiftlint >/dev/null; then
		swiftlint ../Source --config ../.swiftlint.yml
		exit 0
	else
		echo "Not installed"
    	exit 1
	fi
}

if [ "$USER" == "runner" ]; then
	echo "AppCenter build. Ignored."
	exit 1
else
	doWork
fi

