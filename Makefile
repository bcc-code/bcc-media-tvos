
gql.init:
	- cd ./Packages/Library && ./apollo-ios-cli init --schema-name API --module-type embeddedInTarget --target-name API

gql:
	- cd ./Packages/Library && ./apollo-ios-cli generate

gql.download:
	- cd ./Packages/Library && apollo client:download-schema --endpoint=https://api.brunstad.tv/query
