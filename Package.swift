// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "PerfectServer001",
	products: [
		.executable(
			name: "PerfectServer001",
			targets: ["PerfectServer001"])
		],
	dependencies: [
		.package(url: "https://github.com/swift-server/http/", from: "0.1.0"),
	],
	targets: [
		.target(
			name: "PerfectServer001",
			dependencies: ["HTTP"],
			path: "./Sources")
		]
)
