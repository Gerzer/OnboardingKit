// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "OnboardingKit",
	platforms: [
		.iOS(.v13),
		.watchOS(.v6),
		.tvOS(.v13),
		.macOS(.v10_15),
		.macCatalyst(.v13)
	],
	products: [
		.library(
			name: "OnboardingKit",
			targets: [
				"OnboardingKit"
			]
		)
	],
	targets: [
		.target(
			name: "OnboardingKit"
		)
	]
)
