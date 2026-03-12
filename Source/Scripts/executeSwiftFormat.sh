#!/bin/bash

export PATH="$PATH:/opt/homebrew/bin"
#if [[ "$(uname -m)" == arm64 ]]; then
#    export PATH="/opt/homebrew/bin:$PATH"
#fi

doWork() {
	if which swiftformat > /dev/null; then
		#swiftformat --config ../.swiftformat.yml --swiftversion 6.0.2 --verbose
        swiftformat ../Source --config ../.swiftformat.yml --swiftversion 6.0.2 --verbose
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



