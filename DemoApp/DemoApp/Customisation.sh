#!/bin/sh

#fail on error
set -e


#debug log
#set -x

###
#
## Only enable these if running locally
## Run this from outside the root of App directory
#
export APP_IDENTIFIER=com.mkerekes.DemoApp
#
cd ..
###

if [ "$APP_IDENTIFIER" == "us.ios.develop" ]
then
    echo "Nothing to customise for $APP_IDENTIFIER."
    exit
fi

# Overwrite logo. It has to be located in the above path
cp -f "whitelabel/$APP_IDENTIFIER/Logo/General-logo.png" "DemoApp/DemoApp/Assets.xcassets/General-logo.imageset/General-logo.png"

# Overwrite app icon. Use this service to generate a new one:
# https://appicon.co
rm -r "DemoApp/DemoApp/Assets.xcassets/AppIcon.appiconset"
cp -r "whitelabel/$APP_IDENTIFIER/Icons/AppIcon.appiconset" "DemoApp/DemoApp/Assets.xcassets/AppIcon.appiconset"

# Overwrite verified tick
rm -r "DemoApp/DemoApp/Assets.xcassets/verified-tick.imageset"
cp -r "whitelabel/$APP_IDENTIFIER/Icons/verified-tick.imageset" "DemoApp/DemoApp/Assets.xcassets/verified-tick.imageset"

#Overwrite color file
cp -f "whitelabel/$APP_IDENTIFIER/Colors/Colors.swift" "DemoApp/DemoApp/Classes/Style/Colors.swift"

echo "White-labeling magic done"
