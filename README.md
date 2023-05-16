# BCC Media tvOS

This is the source code for the BCC Media tvOS app.

# Setup

Run `pod install` and open BCC Media.xcworkspace

# Generate queries

Run `make gql` to create query files for the Apollo Client. These files are not automatically added to the project, so you need to add the files to the project (and both targets: BCC Media & Top Shelf)