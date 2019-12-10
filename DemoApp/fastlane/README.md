fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios prepare_for_upload
```
fastlane ios prepare_for_upload
```
Description of what the lane does

Standard Test lane
### ios tests
```
fastlane ios tests
```

### ios build_app_for_testflight
```
fastlane ios build_app_for_testflight
```

### ios test_flight_manual
```
fastlane ios test_flight_manual
```

### ios fabric
```
fastlane ios fabric
```
Upload to Crashlytics Testers
### ios bumpPatch
```
fastlane ios bumpPatch
```

### ios bumpMinor
```
fastlane ios bumpMinor
```

### ios bumpMajor
```
fastlane ios bumpMajor
```

### ios bumpBuildNumber
```
fastlane ios bumpBuildNumber
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
