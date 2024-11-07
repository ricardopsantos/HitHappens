#!/bin/bash

#######################################################################################################
#
# Usage
#
# ./genericArchive.sh "GoodToGo.xcodeproj" "MyAppName.AppStore"   "Release"  "[V2.0.2]" "~/Desktop/" "exportPlist.enterprise.plist"
# ./genericArchive.sh "GoodToGo.xcodeproj" "MyAppName.Enterprise" "Debug"    "[V2.0.2]" "~/Desktop/" "exportPlist.appStore"
#
#######################################################################################################

clear

#######################################################################################################
#
# Utils functions
#
#######################################################################################################

# Function to block the domain
# https://dimillian.medium.com/why-is-xcodebuild-slower-than-the-xcode-gui-38f3d7b0c0bc
block_domain() {
    echo "127.0.0.1 http://developerservices2.apple.com" | sudo tee -a /etc/hosts > /dev/null
    echo "Domain blocked"
}

# Function to unblock the domain
# https://dimillian.medium.com/why-is-xcodebuild-slower-than-the-xcode-gui-38f3d7b0c0bc
unblock_domain() {
    sudo sed -i '' '/developerservices2\.apple\.com/d' /etc/hosts
    echo "Domain unblocked"
}

displayCompilerInfo() {
    printf "\n"
    echo -n "### Current Compiler"
    printf "\n"
    eval xcrun swift -version
    eval xcode-select --print-path
}

printMessage() {
    local message="$1"
    local green="\033[0;32m"
    local reset="\033[0m"
    
    printf "\n\n"
    echo -e "${green}#######################################################################################################"
    echo -e "# $message"
    echo -e "#######################################################################################################${reset}"
    printf "\n\n"
}

#######################################################################################################
#
# Params Parse
#
#######################################################################################################

PROJECT_PATH="$1"  # "Source/HitHappens.xcodeproj"
SCHEME="$2"        #
CONFIGURATION="$3" # "Release" | "Debug"
APP_VERSION="$4"   # "[V2.0.2]"
OUTPUT_PATH="$5"   # "~/Desktop/"
PLIST_PATH="$6"    # ""Source/exportPlist.enterprise.plist" | ""Source/exportPlist.appStore.plist"

if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH="Source/HitHappens.xcodeproj"
fi

if [ -z "$SCHEME" ]; then
    #SCHEME="HitHappens Dev"
    SCHEME="HitHappens Production"
fi

if [ -z "$CONFIGURATION" ]; then
    CONFIGURATION="Release"
fi

if [ -z "$APP_VERSION" ]; then
    APP_VERSION="1.0"
fi

if [ -z "$OUTPUT_PATH" ]; then
    OUTPUT_PATH="~/Desktop/"
fi

if [ -z "$PLIST_PATH" ]; then
    PLIST_PATH="Source/exportPlist.appStore.plist"
fi

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
EXPORT_FOLDER_NAME="$SCHEME"_["$CONFIGURATION"]_"$APP_VERSION"
EXPORT_FOLDER_NAME=$(echo "$EXPORT_FOLDER_NAME" | tr -d ' ')
OUTPUT_FOLDER="$OUTPUT_PATH$EXPORT_FOLDER_NAME""/""$TIMESTAMP""/"

echo ""
echo ""

echo "# PROJECT_PATH        :" $PROJECT_PATH
echo "# SCHEME              :" $SCHEME
echo "# CONFIGURATION       :" $CONFIGURATION
echo "# APP_VERSION         :" $APP_VERSION
echo "# OUTPUT_PATH         :" $OUTPUT_PATH
echo "# EXPORT_FOLDER_NAME  :" $EXPORT_FOLDER_NAME
echo "# PLIST_PATH          :" $PLIST_PATH
echo "# OUTPUT_FOLDER       :" $OUTPUT_FOLDER

echo ""
echo ""

TEST_SIMULATOR_ID=""
TEST_SIMULATOR_NAME="iPhone 16"

#######################################################################################################
#
# Build/Archive functions
#
#######################################################################################################

openSimulator() {
    local message="openSimulator"
    printMessage "Will start: $message"

    # Check if the Simulator app is already running
    if pgrep -x "Simulator" > /dev/null; then
        echo "Simulator is already open."

        # Set the TEST_SIMULATOR_ID for the running simulator
        TEST_SIMULATOR_ID=$(xcrun simctl list | grep -m1 '(Booted)' | awk -F '[()]' '{print $2}')

        # Check if we successfully retrieved a booted simulator ID
        if [ -n "$TEST_SIMULATOR_ID" ]; then
            echo "Booted Simulator ID: $TEST_SIMULATOR_ID"
        else
            echo "Warning: No booted simulator ID found despite Simulator being open."
        fi
    else
        echo "Simulator is not open. Launching Simulator..."

        # Open the iOS simulator
        open -a Simulator && xcrun simctl boot "$TEST_DEVICE"

        # Wait a few seconds to ensure the simulator is fully opened
        sleep 3

        # Retrieve the ID of the newly booted simulator
        TEST_SIMULATOR_ID=$(xcrun simctl list | grep -m1 '(Booted)' | awk -F '[()]' '{print $2}')

        # Confirm that the simulator booted successfully
        if [ -n "$TEST_SIMULATOR_ID" ]; then
            echo "Booted Simulator ID: $TEST_SIMULATOR_ID"
        else
            echo "No booted simulator found."
        fi
    fi

    printMessage "Did end: $message"
}


#######################################################################################################
#
# ARCHS=arm64               : Targets the arm64 architecture, for Apple Silicon and newer iOS devices.
# VALID_ARCHS=arm64         : Limits valid architectures to arm64, excluding others like x86_64.
# ONLY_ACTIVE_ARCH=NO       : Builds for all specified architectures (arm64), not just the current one, for broader compatibility.
# CODE_SIGNING_ALLOWED=NO   : Tells Xcode to skip code signing, speeding up builds. It's useful for simulator-only builds or CI testing, where signing isn’t needed.
# CODE_SIGNING_REQUIRED=NO  : Allows the build to skip mandatory code signing. Useful for simulator or CI builds, it prevents errors related to missing certificates, simplifying non-deployment builds
# CODE_SIGN_IDENTITY        : specifies the certificate for signing the app: 'Apple Development': For debugging on devices. 'Apple Distribution': For App Store or ad-hoc distribution
# -allowProvisioningUpdates : Lets Xcode automatically update or download provisioning profiles and certificates if needed, useful in CI/CD to avoid manual intervention.
# -resultBundlePath         : Specifies the location where Xcode saves the build results, including logs, test results, and other build artifacts, in a .xcresult bundle.
#######################################################################################################

buildForSimulator() {
	openSimulator

	message="buildForSimulator"
	printMessage  "Will start: $message"

    xcodebuild clean build \
    	-project "$PROJECT_PATH" \
    	-scheme "$SCHEME" \
    	ARCHS=arm64 \
    	VALID_ARCHS=arm64 \
    	ONLY_ACTIVE_ARCH=NO \
    	CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    	-destination "platform=iOS Simulator,name=""$TEST_SIMULATOR_NAME"",OS=latest" \
    	-allowProvisioningUpdates \
    	-resultBundlePath "$OUTPUT_FOLDER""xcresult.xcresult"

	printMessage  "Did end: $message"

}

doArquive() {

	message="doArquive"
	printMessage  "Will start: $message"
	
	xcodebuild archive \
    	-project "$PROJECT_PATH" \
    	-scheme "$SCHEME" \
    	-archivePath "$OUTPUT_FOLDER""xcarchive.xcarchive" \
    	-quiet

	xcodebuild archive \
    	-project "$PROJECT_PATH" \
    	-scheme "$SCHEME" \
    	-archivePath "$OUTPUT_FOLDER""xcarchive_allowProvisioningUpdates.xcarchive" \
    	-allowProvisioningUpdates \
    	-quiet
    	    	    	
	printMessage  "Did end: $message"
}

doGenerateIPA() {

	message="doGenerateIPA"
	printMessage  "Will start: $message"
	
	xcodebuild -exportArchive \
   		-archivePath "$OUTPUT_FOLDER""xcarchive.xcarchive" \
    	-exportPath "$OUTPUT_FOLDER""IPA" \
   	 	-exportOptionsPlist "$PLIST_PATH" \
   	 	-allowProvisioningUpdates \
   	 	-verbose
   	 
	 printMessage  "Did end: $message"

}

#######################################################################################################
#
# Control
#
#######################################################################################################

#displayCompilerInfo

rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild clean -project "$PROJECT_PATH"

echo ""

echo "### Build for Simulator?"
echo " [1] : Yes"
echo " [2] : No (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) buildForSimulator ;;
    [2] ) echo "Ignored...." ;;
    * ) echo "Ignored...." ;;
esac

echo ""

echo "### Archive?"
echo " [1] : Yes (Default)"
echo " [2] : No"
echo -n "Option? "
read option
case $option in
    [1] ) doArquive ;;
    [2] ) echo "Ignored...." ;;
    * ) doArquive ;;
esac

echo ""

echo "### IPA?"
echo " [1] : Yes"
echo " [2] : No (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) doGenerateIPA ;;
    [2] ) echo "Ignored...." ;;
    * ) doGenerateIPA ;;
esac

echo ""

echo "*** END ***"