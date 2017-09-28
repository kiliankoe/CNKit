SWIFTCMD=swift

test:
	$(SWIFTCMD) test

xcode:
	$(SWIFTCMD) package generate-xcodeproj

docs:
	jazzy --xcodebuild-arguments -target,CNKit --theme fullwidth

.PHONY: test, xcode, docs
