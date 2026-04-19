.PHONY: project open clean test lint help

help:
	@echo "make project  : Generate Xcode project via XcodeGen"
	@echo "make open     : Open Xcode project"
	@echo "make clean    : Remove generated Xcode project"
	@echo "make test     : Run iOS unit tests on Simulator"

project:
	@which xcodegen > /dev/null || (echo 'Install XcodeGen: brew install xcodegen' && exit 1)
	xcodegen generate

open: project
	open WakeAtStation.xcodeproj

clean:
	rm -rf WakeAtStation.xcodeproj build/ DerivedData/

test: project
	xcodebuild -project WakeAtStation.xcodeproj \
	  -scheme WakeAtStation \
	  -destination 'platform=iOS Simulator,name=iPhone 15' \
	  test
