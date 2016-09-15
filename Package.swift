import PackageDescription

let package = Package(
    name: "PostgreSQL",
    dependencies: [
   		 .Package(url: "https://github.com/qutheory/cpostgresql.git", majorVersion: 0),
   		 .Package(url: "https://github.com/vapor/node.git", majorVersion: 1),
         .Package(url: "https://github.com/vapor/core.git", majorVersion: 1)
    ]
)
