
gql.init:
	- ./Pods/Apollo/apollo-ios-cli init --schema-name API --module-type embeddedInTarget --target-name API

gql:
	- ./Pods/Apollo/apollo-ios-cli generate --ignore-version-mismatch

gql.download:
	- apollo client:download-schema --endpoint=https://api.brunstad.tv/query

lint:
	- ./Pods/SwiftLint/swiftlint

format:
	- swiftformat ./BCC\ Media
	- swiftformat ./Top\ Shelf