import XCTest
@testable import PostgreSQL

class PostgreSQLTests: XCTestCase {
    static let allTests = [
        ("testSelectVersion", testSelectVersion),
        ("testTables", testTables),
        ("testParameterization", testParameterization),
    ]

    var postgreSQL: PostgreSQL.Database!

    override func setUp() {
        postgreSQL = PostgreSQL.Database.makeTestConnection()
    }

    func testSelectVersion() {
        do {
            let results = try postgreSQL.execute("SELECT version()")
            guard let version = results.first?["version"] else {
                XCTFail("Version not in results")
                return
            }

            guard let string = version.string else {
                XCTFail("Version not in results")
                return
            }
            
            XCTAssert(string.hasPrefix("PostgreSQL"))
        } catch {
            XCTFail("Could not select version: \(error)")
        }
    }

    func testTables() {
        do {
            try postgreSQL.execute("DROP TABLE IF EXISTS foo")
    
            try postgreSQL.execute("CREATE TABLE foo (bar INTEGER, baz VARCHAR)")
//            try postgreSQL.execute("INSERT INTO foo (bar, baz) VALUES ($1, $2)", [42, "Life"])
            try postgreSQL.execute("INSERT INTO foo (bar, baz) VALUES ($1, $2)", [1337, "Elite"])
//            try postgreSQL.execute("INSERT INTO foo (bar) VALUES ($1)", [9])
            
            
            
//            if let resultBar = try postgreSQL.execute("SELECT * FROM foo WHERE bar = $1", [42]).first {
//                XCTAssertEqual(resultBar["bar"]?.int, 42)
//                XCTAssertEqual(resultBar["baz"]?.string, "Life")
//            } else {
//                XCTFail("Could not get bar result")
//            }


            if let resultBaz = try postgreSQL.execute("SELECT * FROM foo where baz = $1", ["Elite"]).first {
                XCTAssertEqual(resultBaz["bar"]?.int, 1337)
                XCTAssertEqual(resultBaz["baz"]?.string, "Elite")
            } else {
                XCTFail("Could not get baz result")
            }
//
//            if let resultBaz = try postgreSQL.execute("SELECT * FROM foo where bar = $1", [9]).first {
//                XCTAssertEqual(resultBaz["bar"]?.int, 9)
//                XCTAssertEqual(resultBaz["baz"]?.string, nil)
//            } else {
//                XCTFail("Could not get null result")
//            }
        } catch {
            XCTFail("Testing tables failed: \(error)")
        }
    }

    func testParameterization() {
        do {
            try postgreSQL.execute("DROP TABLE IF EXISTS parameterization")
            try postgreSQL.execute("CREATE TABLE parameterization (d DECIMAL, i INTEGER, s VARCHAR(16), u INTEGER)")

            try postgreSQL.execute("INSERT INTO parameterization VALUES ($1, $2, $3 ,$4)", [3.14, nil, "pi", nil])
//            try postgreSQL.execute("INSERT INTO parameterization VALUES ($1, $2, $3, $4)", [nil, nil, "life", 42])
//            try postgreSQL.execute("INSERT INTO parameterization (i, s) VALUES ($1, $2)", [-1, "test"])
        } catch {
            XCTFail("Failed to Setup Test: \(error)")
            return
        }
        
        do {
            if let result = try postgreSQL.execute("SELECT * FROM parameterization WHERE d = $1", [3.14]).first {
                XCTAssertEqual(result["d"]?.double, 3.14)
                XCTAssertEqual(result["i"]?.int, nil)
                XCTAssertEqual(result["s"]?.string, "pi")
                XCTAssertEqual(result["u"]?.int, nil)
            } else {
                XCTFail("Could not get pi result")
                return
            }
        } catch {
            XCTFail("Test Parameterization #1: failed \(error)")
            return
        }

        do {
            if let result = try postgreSQL.execute("SELECT * FROM parameterization WHERE u = $1", [42]).first {
                XCTAssertEqual(result["d"]?.double, nil)
                XCTAssertEqual(result["i"]?.int, nil)
                XCTAssertEqual(result["s"]?.string, "life")
                XCTAssertEqual(result["u"]?.int, 42)
            } else {
                XCTFail("Could not get life result")
                return
            }
        } catch {
            XCTFail("Test Parameterization #2: failed \(error)")
            return
        }
//
//        do {
//            if let result = try postgreSQL.execute("SELECT * FROM parameterization WHERE i = $1", [-1]).first {
//                XCTAssertEqual(result["d"]?.double, nil)
//                XCTAssertEqual(result["i"]?.int, -1)
//                XCTAssertEqual(result["s"]?.string, "test")
//                XCTAssertEqual(result["u"]?.int, nil)
//            } else {
//                XCTFail("Could not get test by int result")
//            }
//        } catch {
//            XCTFail("Test Parameterization #3: failed \(error)")
//            return
//        }
//        
//        do {
//            if let result = try postgreSQL.execute("SELECT * FROM parameterization WHERE s = $1", ["test"]).first {
//                XCTAssertEqual(result["d"]?.double, nil)
//                XCTAssertEqual(result["i"]?.int, -1)
//                XCTAssertEqual(result["s"]?.string, "test")
//                XCTAssertEqual(result["u"]?.int, nil)
//            } else {
//                XCTFail("Could not get test by string result")
//                return
//            }
//        } catch {
//            XCTFail("Test Parameterization #4: failed \(error)")
//            return
//        }
    }
}
