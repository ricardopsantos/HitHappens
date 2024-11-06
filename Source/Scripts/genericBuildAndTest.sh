#!/bin/bash

clear

PROJECT_PATH="$1"
SCHEME="$2"
TEST_DEVICE="iPhone 16 Pro"
BOOTED_SIMULATOR_ID=""

if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH="Source/HitHappens.xcodeproj"
fi

if [ -z "$SCHEME" ]; then
    SCHEME="HitHappens Dev"
fi

displayCompilerInfo() {
    printf "\n"
    echo -n "### Current Compiler"
    printf "\n"
    eval xcrun swift -version
    eval xcode-select --print-path
}

build() {
	#xcodebuild clean -project $PROJECT_PATH
	printf "\n"
	echo -n "### Will build"
	printf "\n"
    xcodebuild clean build -project "$PROJECT_PATH" -scheme "$SCHEME" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -quiet | xcpretty --error
    printf "\n"
	echo -n "### Will build: Done"
    printf "\n"
}

testUsingBootedSimulator() {

    printf "\n"
	echo -n "### Will test"
	printf "\n"
    
    if [ -n "$BOOTED_SIMULATOR_ID" ]; then
        xcodebuild clean test -project "$PROJECT_PATH" -scheme "$SCHEME" -destination "id=$BOOTED_SIMULATOR_ID" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
    else
        echo "No simulator ID provided."
        xcodebuild clean test -project "$PROJECT_PATH" -scheme "$SCHEME" -destination 'platform=iOS Simulator,name="$TEST_DEVICE",OS=latest' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -only-testing:UnitTests
    fi
    
    printf "\n"
    echo -n "### Will test: Done"
	printf "\n"
}

openSimulator() {

    printf "\n"
	echo -n "### Will open Simulator"
	printf "\n"

    # Close all open simulators
    killall "Simulator"

    sleep 1

    # Open the iOS simulator
    open -a Simulator && xcrun simctl boot "$TEST_DEVICE"

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
    
    printf "\n"
    echo -n "### Will open Simulator: Done"
	printf "\n"
}

################################################################################

printf "\n"

displayCompilerInfo

build

openSimulator
testUsingBootedSimulator