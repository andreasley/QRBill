// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRBill",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(
            name: "QRBill",
            targets: ["QRBill"]),
        .executable(
            name: "QRBillTestApp",
            targets: ["QRBillTestApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/fwcd/swift-qrcode-generator.git", from: "1.0.3")
    ],
    targets: [
        .target(
            name: "QRBill",
            dependencies: [.product(name: "QRCodeGenerator", package: "swift-qrcode-generator")]),
        .executableTarget(
            name: "QRBillTestApp",
            dependencies: ["QRBill"]),
    ]
)
