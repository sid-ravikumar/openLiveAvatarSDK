// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "openLiveAvatarSDK",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "openLiveAvatarSDK",
            targets: ["openLiveAvatarSDK", "SwiftCubismSdk", "ObjcCubismSdk"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/ably/ably-cocoa", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftCubismSdk",
            dependencies: ["ObjcCubismSdk"]
        ),
        .target(
            name: "ObjcCubismSdk",
            dependencies: ["CubismSdk"],
            cxxSettings: [
                .headerSearchPath("../CubismSdk/Core/include"),
                .headerSearchPath("../CubismSdk/Framework/src"),
            ]
        ),
        .target(
            name: "CubismSdk",
            dependencies: ["libLive2DCubismCore"],
            path: "Sources/CubismSdk",
            publicHeadersPath: "./Core/include",
            cxxSettings: [
                .define("CSM_TARGET_IPHONE_ES2"),
                .headerSearchPath("./Core/include"),
                .headerSearchPath("./Framework/src")
            ]
        ),
        .binaryTarget(name: "libLive2DCubismCore", path: "Sources/CubismSdk/Core/lib/ios/libLive2DCubismCore.xcframework"),
        .target(
            name: "openLiveAvatarSDK",
            dependencies: ["SwiftCubismSdk", "ObjcCubismSdk", .product(name: "Ably", package: "ably-cocoa")],
            resources: [
                .copy("resources/hiyori_pro_t10.pose3.json"),
                .copy("resources/hiyori_pro_t10.physics3.json"),
                .copy("resources/hiyori_pro_t10.model3.json"),
                .copy("resources/hiyori_pro_t10.moc3"),
                .copy("resources/hiyori_pro_t10.cdi3.json"),
                .copy("resources/motion/hiyori_m01.motion3.json"),
                .copy("resources/motion/hiyori_m02.motion3.json"),
                .copy("resources/motion/hiyori_m03.motion3.json"),
                .copy("resources/motion/hiyori_m04.motion3.json"),
                .copy("resources/motion/hiyori_m05.motion3.json"),
                .copy("resources/motion/hiyori_m06.motion3.json"),
                .copy("resources/motion/hiyori_m07.motion3.json"),
                .copy("resources/motion/hiyori_m08.motion3.json"),
                .copy("resources/motion/hiyori_m09.motion3.json"),
                .copy("resources/motion/hiyori_m10.motion3.json"),
                .copy("resources/hiyori_pro_t10.2048/texture_00.png"),
                .copy("resources/hiyori_pro_t10.2048/texture_01.png")
            ]
        )
    ]
)
