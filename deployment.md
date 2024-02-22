# Deployment

This document should explain how to deploy the app to the tvOS App Store

## Dependencies

-   [fastlane](https://github.com/fastlane/fastlane)
    -   `brew install fastlane`
-   xcode

You might need some other dependencies, but fastlane should let you know what you need.

## Do deployment

`fastlane beta` will build and upload the archive to App Store Connect for testing via Testflight.

You also need to specify the changes in the changelog prompted by fastlane to allow external testers access to the build.
