import XCTest
@testable import SwiftHelpers
import Foundation
import CoreFoundation

enum PlanetEarthError: Error {
    case tooManyHabitants
}

@available(OSX 10.12, *)
class ClosureHelpersTests: XCTestCase {

    func testRetryFailedEverything() {
        var count = 0
        let result = retry(maxTries: 3, retryMessage: "Retrying") {
            count += 1
            throw PlanetEarthError.tooManyHabitants
        }
        XCTAssertEqual(count, 3)
        XCTAssertEqual(result, false)
    }

    @available(OSX 10.12, *)
    func testMeasureExecutionTime() {

        let now = CFAbsoluteTime()
        var count = 0

        let timeProvider: TimeProvider = {
            // first invocation returns time 0, second invocation returns +1000 ms
            if count == 0 {
                count += 1
                return now
            } else {
                return now + 1000 // 1s
            }
        }

        let time = measureExecutionTime(title: "Sleeps for 1 sec", operation: {
            // noop

        }, timeProvider: timeProvider)
        XCTAssertEqual(time, 1000.0)
    }

    func testwithArrayOfCStrings() {
        let array = ["planet", "earth"]
        withArrayOfCStrings(array) { cArray in
            XCTAssertEqual(String(cString: cArray[0]!), "planet")
            XCTAssertEqual(String(cString: cArray[1]!), "earth")
            XCTAssertEqual(cArray[2], nil) //end
        }
    }

    static var allTests: [(String, (ClosureHelpersTests) -> () throws -> Void)] {
        return [
            ("testRetry", testRetryFailedEverything),
            ("testwithArrayOfCStrings", testwithArrayOfCStrings),
            ("testMeasureExecutionTime", testMeasureExecutionTime)
        ]
    }
}
