#!/bin/bash

clear

#
# ./genericArchive.sh "GoodToGo.xcodeproj" "MyAppName.AppStore"   "Release"  "[V2.0.2]" "~/Desktop/" "exportPlist.enterprise.plist"
# ./genericArchive.sh "GoodToGo.xcodeproj" "MyAppName.Enterprise" "Debug"    "[V2.0.2]" "~/Desktop/" "exportPlist.appStore"
#

displayCompilerInfo() {
    printf "\n"
    echo -n "### Current Compiler"
    printf "\n"
    eval xcrun swift -version
    eval xcode-select --print-path
}

displayCompilerInfo

PROJECT_PATH="$1"  # "Source/HitHappens.xcodeproj"
SCHEME="$2"        #
CONFIGURATION="$3" # "Release" | "Debug"
APP_VERSION="$4"   # "[V2.0.2]"
OUTPUT_PATH="$5"   # "~/Desktop/"
PLIST_PATH="$6"    # "exportPlist.enterprise.plist" | "exportPlist.appStore.plist"

if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH="Source/HitHappens.xcodeproj"
fi

if [ -z "$SCHEME" ]; then
    SCHEME="HitHappens Dev"
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
    PLIST_PATH="exportPlist.appStore.plist"
fi

EXPORT_FILE_NAME="$SCHEME"_["$CONFIGURATION"]_"$APP_VERSION"
EXPORT_FILE_NAME=$(echo "$EXPORT_FILE_NAME" | tr -d ' ')
EXPORT_ARCHIVE_PATH=""$OUTPUT_PATH""$EXPORT_FILE_NAME""

echo ""
echo ""

echo "# PROJECT_PATH        :" $PROJECT_PATH
echo "# SCHEME              :" $SCHEME
echo "# CONFIGURATION       :" $CONFIGURATION
echo "# APP_VERSION         :" $APP_VERSION
echo "# OUTPUT_PATH         :" $OUTPUT_PATH
echo "# EXPORT_FILE_NAME    :" $EXPORT_FILE_NAME
echo "# EXPORT_ARCHIVE_PATH :" $EXPORT_ARCHIVE_PATH
echo "# PLIST_PATH          :" $PLIST_PATH

echo ""
echo ""


TEST_SIMULATOR_ID=""
TEST_SIMULATOR_NAME="iPhone 16"

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


doArquive() {
    #to_run="xcodebuild PRODUCT_NAME='$SCHEME' -verbose archive -project '$PROJECT_PATH' -configuration '$CONFIGURATION' -scheme '$SCHEME' -archivePath '$ARCHIVE_PATH'.xcarchive -UseModernBuildSystem=NO"
    to_run="xcodebuild PRODUCT_NAME='$SCHEME' -quiet archive -project '$PROJECT_PATH' -configuration '$CONFIGURATION' -scheme '$SCHEME' -archivePath '$ARCHIVE_PATH'.xcarchive -UseModernBuildSystem=NO"

    echo "#"
    echo "# Will run: "$to_run
    echo "#"
    eval $to_run
    
   #xcodebuild PRODUCT_NAME="$SCHEME" -verbose archive -project "$PROJECT_PATH" -configuration "$CONFIGURATION" -scheme "$SCHEME" -archivePath "$ARCHIVE_PATH".xcarchive -UseModernBuildSystem=NO
   #xcodebuild PRODUCT_NAME="$SCHEME" -quiet archive -project "$PROJECT_PATH" -configuration "$CONFIGURATION" -scheme "$SCHEME" -archivePath "$ARCHIVE_PATH".xcarchive -UseModernBuildSystem=NO

 #   var_zip="ditto -c -k --sequesterRsrc --keepParent "$ARCHIVE_PATH".xcarchive "$ARCHIVE_PATH".xcarchive.zip"
  #  echo "#"
   # echo "# Will run: "$var_zip
    #echo "#"
    #eval $var_zip

}

doGenerateIPA() {
    to_run="xcodebuild -exportArchive -allowProvisioningUpdates -verbose -exportOptionsPlist "$var_plist" -archivePath "$ARCHIVE_PATH".xcarchive -exportPath "$ARCHIVE_PATH""
    echo "#"
    echo "# Will run: "$to_run
    echo "#"
    eval $to_run

    var_zip="ditto -c -k --sequesterRsrc --keepParent "$ARCHIVE_PATH" "$ARCHIVE_PATH".ipa.zip"
    echo "#"
    echo "# Will run: "$var_zip
    echo "#"

    eval $var_zip
}

buildForSimulator() {
	timestamp=$(date +"%Y%m%d%H%M%S")
	xcodebuild ARCHS\=arm64 VALID_ARCHS\=arm64 ONLY_ACTIVE_ARCH\=NO -scheme "$SCHEME" -configuration "$CONFIGURATION" -project "$PROJECT_PATH" -destination "platform=iOS Simulator,name=""$TEST_SIMULATOR_NAME"",OS=latest" -resultBundlePath "$EXPORT_ARCHIVE_PATH""/Build/Build_$timestamp" -allowProvisioningUpdates build
}

echo ""

echo "### Build for Simulator?"
echo " [1] : Yes (Default)"
echo " [2] : No"
echo -n "Option? "
read option
case $option in
    [1] ) buildForSimulator ;;
    [2]  )echo "Ignored...." ;;
   *) buildForSimulator 
;;
esac

echo ""

echo "### Archive?"
echo " [1] : Yes"
echo " [3] : No (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) doArquive ;;
   *) echo "Ignored...."
;;
esac

echo ""

echo "### Generate IPA?"
echo " [1] : Yes"
echo " [3] : No (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) doGenerateIPA ;;
   *) echo "Ignored...."
;;
esac

