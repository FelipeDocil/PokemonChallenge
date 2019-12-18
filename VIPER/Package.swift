// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PokemonChallenge",
    dependencies: [
        .package(url: "https://github.com/shibapm/capriccio.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "PokemonChallenge",
            dependencies: [],
            path: "PokemonChallenge"
        )
    ]
)
