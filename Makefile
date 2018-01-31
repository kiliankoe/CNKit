SWIFTCMD=swift

test:
	$(SWIFTCMD) test --parallel

docs:
	jazzy --xcodebuild-arguments -target,CNKit --theme fullwidth

.PHONY: test, docs
