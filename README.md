# BCC Media tvOS

This is the source code for the BCC Media tvOS app.

# Setup

Open BCC Media.xcworkspace and let xcode do the magic.

# Generate queries

Go to [API](./API) and run `make gql` to create query files for the Apollo Client.

# Release

```
make release
```

Should bump version and pushes a tag for the version. A CI/CD pipeline does the rest.
