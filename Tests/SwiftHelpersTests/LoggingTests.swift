import XCTest
import Foundation
@testable import SwiftHelpers


var executedAppender: Bool = false

class FakeAppender: Appender {
    public func append(event _: Logger.Event) {
        executedAppender = true
    }

    public var name: String = "fake"
    public var levels: Logger.Level = []
}

class LoggingTests: XCTestCase {


    func testLoggerManagerUnconfigured() {
        LoggerManager.configure(appenders: [FakeAppender()])
        let logger = LoggerManager.getLogger(name: "test") // could be freed when reference = 0
        logger.debug("test")
        XCTAssert(executedAppender)
    }

    func testLoggerManagerConfigured() {
        LoggerManager.configure(appenders: [MinimalAppender(levels: [.debug])])
        let logger = LoggerManager.getLogger(name: "test")
        let logger2 = LoggerManager.getLogger(name: "test")
        XCTAssert(logger === logger2)
    }

    static var allTests: [(String, (LoggingTests) -> () -> Void)] {
        return [
            ("testLoggerManagerConfigured", testLoggerManagerConfigured),
            ("testLoggerManagerUnconfigured", testLoggerManagerUnconfigured)
        ]
    }
}
