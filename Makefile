
include .env
export

ts.download:
	- cd ./BCC\ Media\ tvOS/Localization && CROWDIN_TOKEN=`cat .crowdin_token` && export CROWDIN_TOKEN && crowdin download bundle 3

ts.upload:
	- cd ./BCC\ Media\ tvOS/Localization && CROWDIN_TOKEN=`cat .crowdin_token` && export CROWDIN_TOKEN && crowdin upload sources -s /en.lproj/Localizable.strings -t /%two_letters_code%.lproj/Localizable.strings --dest=/BrunstadTV-4.0/Localizable.strings

deploy:
	- fastlane beta