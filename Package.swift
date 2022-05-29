// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitProviders",
    platforms: [.iOS(.v14),.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GitProviders",
            targets: ["GitProviders", "GitClient", "GitAPI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(name: "SwiftGit2", url: "https://github.com/App-Maker-Software/SwiftGit3.git", from: "1.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GitProviders",
            dependencies: ["KeychainAccess","GitClient","GitAPI"]),
        .target(
            name: "GitClient",
            dependencies: ["SwiftGit2"]),
        .target(
            name: "GitAPI",
            dependencies: []),
        .testTarget(
            name: "GitAPITests",
            dependencies: ["GitAPI"],
            resources: [.copy("FakeCreds")]
        ),
    ]
)
