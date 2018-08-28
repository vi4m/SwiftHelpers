import Foundation
import CoreFoundation

internal var logger = LoggerManager.getLogger(name: "swidamio")

/// Use this function when debugging conditional guard expressions (`where`)
/// Example: guard ... where diagnose()
public func diagnose(file: String = #file, line: Int = #line) -> Bool {
    print("Testing \(file):\(line)")
    return true
}

/// Retry execution of closure,  when given closure throws any exception. Return true if succeeded.
/// - Parameters:
///     - retryMessage: If specified, will be logged with `error` level, for each failed attempt.
///     - closure: Execution block to run. Should be able to throw something in case of error.
///     - maxTries: Resign after `maxTries` attemps with `false` return code.
public func retry(maxTries: Int = 10, retryMessage: String = "Error", closure: () throws -> Void) -> Bool {
    var retryCount = 0
    var success = false

    repeat {
        do {
            try closure()
            success = true
        } catch {
            retryCount += 1
            logger.error("Retry() failed with: \(error)")
            logger.error(retryMessage + ". Retrying: \(retryCount) of \(maxTries)")
            if retryCount > maxTries {
                return false
            }
        }
    } while (success == false) && (retryCount < maxTries)
    if retryCount > 0 {
        logger.error("Retry finished with \(success ? "success" : "failure").")
    }
    return success
}

public typealias TimeProvider = () -> CFAbsoluteTime

/// Measure total execution time of given `closure`
/// - Parameters:
///     - title: Title of execution block, e.g. "calculation of square number"
///     - operation: Code block to execute.
public func measureExecutionTime(title:String, operation: () throws -> (), 
	timeProvider: @escaping TimeProvider = CFAbsoluteTimeGetCurrent) rethrows -> Double {
    let measurement = Measurement(timeProvider: timeProvider)
    try operation()
    return measurement.getElapsedTime()
}

/// Measurement object is used to measure time elapsed between two "snapshots"
/// Example:
/// let x = Measurement()
/// ... your code ...
/// print(x.getElapsedTime())
///
public class Measurement {

    var startTime: CFAbsoluteTime
    var timeProvider: TimeProvider

    public init(timeProvider: @escaping TimeProvider = CFAbsoluteTimeGetCurrent) {
        self.timeProvider = timeProvider
        self.startTime = timeProvider()
    }

    public func getElapsedTime() -> Double  {
        return timeProvider() - startTime
    }
}
