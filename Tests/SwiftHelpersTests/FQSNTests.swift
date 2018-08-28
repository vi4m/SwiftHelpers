import XCTest
@testable import SwiftHelpers

import Foundation

class FullyQualifiedServiceNameTests: XCTestCase {

    func testInitException() {
        try XCTAssertThrowsError(FullyQualifiedServiceName(string: "incompleteprefix"), "Should throw PrefixIsMissing (prefix consist of 2 parts: pl.company)", { (error) in
             XCTAssertEqual(error as? FullyQualifiedServiceNameError, .PrefixIsMissing)
        })
        try XCTAssertThrowsError(FullyQualifiedServiceName(string: "pl.company"), "Should throw DomainIsMissing", { (error) in
            XCTAssertEqual(error as? FullyQualifiedServiceNameError, .DomainIsMissing)
        })
        try XCTAssertThrowsError(FullyQualifiedServiceName(string: "pl.company.tech"), "Should throw ContextIsMissing", { (error) in
            XCTAssertEqual(error as? FullyQualifiedServiceNameError, .ContextIsMissing)
        })
        try XCTAssertThrowsError(FullyQualifiedServiceName(string: "pl.company.tech.ads"), "Should throw ApplicationNameIsMissing", { (error) in
            XCTAssertEqual(error as? FullyQualifiedServiceNameError, .ApplicationNameIsMissing)
        })
        try XCTAssertNoThrow(FullyQualifiedServiceName(string: "pl.company.tech.ads.generator"))
        try XCTAssertNoThrow(FullyQualifiedServiceName(string: "pl.company.tech.ads.generator.console"))
    }

    func testInitParsing() throws {
        let result = try FullyQualifiedServiceName(string: "pl.company.tech.ads.generator.console")


        XCTAssertEqual(result.applicationName, "generator")
        XCTAssertEqual(result.boundedContext, "ads")
        XCTAssertEqual(result.domain, "tech")
    }

    static var allTests: [(String, (FullyQualifiedServiceNameTests) -> () throws -> Void)] {
        return [
            ("testInitException", testInitException),
            ("testInitParsing", testInitParsing)
        ]
    }
}
