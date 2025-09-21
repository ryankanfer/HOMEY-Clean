.PHONY: lint format test build beta

lint:
	swiftlint || true

format:
	swiftformat . || true

test:
	bundle exec fastlane test

build:
	bundle exec fastlane build

beta:
	bundle exec fastlane beta
