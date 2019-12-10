#  Demo Project

# Installation:


Create your ssh key [here](https://gitlab.cloud/profile/keys)
        

Set up [carthage](https://github.com/Carthage/Carthage) dependencies:

        carthage update --platform iOS --no-use-binaries --cache-builds
	
- or in case you already update carthage, use 

         carthage bootstrap [optional: ProjectName] --platform ios --no-use-binaries --cache-builds
         carthage bootstrap --platform ios --no-use-binaries --cache-builds
	
To run tests using [fastlane](https://docs.fastlane.tools/getting-started/ios/setup/) from command line:
	
        fastlane tests	
