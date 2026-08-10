# unittests

Swift unit tests for pure logic in the app target: URL/string parsing, stream
selection — anything that can be checked without a running app.

The bundle has **no test host**. Rather than launching the app (which would boot
Firebase, Sentry, Rudder and hit the API before a single assertion ran), the target
compiles the individual app sources it exercises into the test bundle. When a test
needs a new app source file, add that file to the `unittests` target's *Compile
Sources* phase alongside the app target.

UI tests live in `../Tests` and run in the separate `uitests` bundle.

Run them from the repo root — via the workspace, since the project on its own resolves
package versions the pinned ones don't match:

```sh
xcodebuild test -workspace "BCC Media.xcworkspace" -scheme unittests \
  -destination 'platform=tvOS Simulator,name=Apple TV'
```

The SwiftPM packages have their own tests, which need no simulator and run on the host:

```sh
(cd FeatureFlags && swift test) && (cd Authentication && swift test) && (cd API && swift test)
```
