// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Luciq-gRPC",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Luciq-gRPC-Swift",
            targets: ["Luciq-gRPC-Swift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.27.6"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.36.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.31.0"),
        .package(url: "https://github.com/luciqai/luciq-ios-sdk.git", "18.0.0"..<"20.0.0")
    ],
    targets: [
        .target(
            name: "Luciq-gRPC-Swift",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "NIO", package: "swift-nio"),
                // Holds NIOHPACK too. GRPC links only NIOHTTP2, so a separate NIOHPACK product breaks GRPC's link.
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Luciq", package: "luciq-ios-sdk")
            ],
            path: "Luciq-grpc-swift"
        )
    ]
)
