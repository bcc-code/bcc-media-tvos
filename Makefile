
include .env
export

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

ts.download:
	- cd ./BCC\ Media/Localization && CROWDIN_TOKEN=`cat .crowdin_token` && export CROWDIN_TOKEN && crowdin download bundle 3

ts.upload:
	- cd ./BCC\ Media/Localization && CROWDIN_TOKEN=`cat .crowdin_token` && export CROWDIN_TOKEN && crowdin upload sources -s /en.lproj/Localizable.strings -t /%two_letters_code%.lproj/Localizable.strings --dest=/BrunstadTV-4.0/Localizable.strings

deploy:
	- ./scripts/envsubst.sh
	- fastlane beta