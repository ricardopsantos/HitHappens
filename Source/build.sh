#!/bin/bash

clear

displayCompilerInfo() {
    printf "\n"
    echo -n "### Current Compiler"
    printf "\n"
    eval xcrun swift -version
    eval xcode-select --print-path
}

build() {
    xcodebuild build -project HitHappens.xcodeproj -scheme "HitHappens Dev" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
}

test() {
    local simulator_id=$1
    if [ -n "$simulator_id" ]; then
        xcodebuild clean test -project HitHappens.xcodeproj -scheme "HitHappens Dev" -destination "id=$simulator_id" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
    else
        echo "No simulator ID provided."
    fi
}

openSimulator() {
    # Close all open simulators
    killall "Simulator"

    sleep 1

    # Open the iOS simulator
    open -a Simulator && xcrun simctl boot 'iPhone 15 Pro'

    # Wait a few seconds to ensure the simulator is fully opened
    sleep 5

    # List all simulators and extract the ID of the booted simulator
    BOOTED_SIMULATOR_ID=$(xcrun simctl list | grep -m1 '(Booted)' | awk -F '[()]' '{print $2}')

    # Check if a booted simulator was found
    if [ -n "$BOOTED_SIMULATOR_ID" ]; then
        echo "Booted Simulator ID: $BOOTED_SIMULATOR_ID"
    else
        echo "No booted simulator found."
    fi
}

openSimulatorAndtest() {
    openSimulator
    test "$BOOTED_SIMULATOR_ID" 
}

manualOptions() {
    echo "### Build"
    echo " [1] : Build"
    echo " [2] : Skip (Default)"
    echo -n "Option? "
    read -r option
    case $option in
        1 ) build ;;
        * ) echo "Ignored..." ;;
    esac

    printf "\n"

    echo "### Test"
    echo " [1] : Test"
    echo " [2] : Skip (Default)"
    echo -n "Option? "
    read -r option
    case $option in
        1 ) 
            openSimulatorAndtest ;;
        * ) echo "Ignored..." ;;
    esac
}

################################################################################

printf "\n"

if [ "$1" = "build" ]; then
    build
elif [ "$1" = "test" ]; then
    openSimulatorAndtest
else
    manualOptions
fi
