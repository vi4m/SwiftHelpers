import Foundation
import Vapor
import Sockets

public protocol Appender {
    var name: String { get }
    var levels: Logger.Level { get }
    func append(event: Logger.Event)
}

public final class Logger {
    public struct Level: OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let trace = Level(rawValue: 1 << 0)
        public static let debug = Level(rawValue: 1 << 1)
        public static let info = Level(rawValue: 1 << 2)
        public static let warning = Level(rawValue: 1 << 3)
        public static let error = Level(rawValue: 1 << 4)
        public static let fatal = Level(rawValue: 1 << 5)
        public static let all = Level(rawValue: ~0)
    }

    public struct Event {
        public let locationInfo: LocationInfo
        public let timestamp: String
        public let level: Logger.Level
        public let name: String
        public let logger: Logger
        public var message: Any?
        public var error: Error?
    }

    public struct LocationInfo {
        public let file: String
        public let line: Int
        public let column: Int
        public let function: String
    }

    var appenders = [Appender]()
    var name: String

    public init(name: String = "Logger", appenders: [Appender] = [StandardOutputAppender()]) {
        self.appenders.append(contentsOf: appenders)
        self.name = name
    }

    public static let logTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        let format = DateFormatter.dateFormat(fromTemplate: "yyMMdd HHmmssSSS", options: 0, locale: .current)
        formatter.dateFormat = format
        return formatter
    }()
}

extension Logger.LocationInfo: CustomStringConvertible {
    public var description: String {
        return "\(file):\(function):\(line):\(column)"
    }
}

extension Logger {
    private func log(level: Level, item: Any?, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        let event = Event(
            locationInfo: LocationInfo(
                file: file,
                line: line,
                column: column,
                function: function
            ),
            timestamp: currentTime,
            level: level,
            name: self.name,
            logger: self,
            message: item,
            error: error
        )
        for apender in appenders {
            apender.append(event: event)
        }
    }

    public func trace(_ item: Any?, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        log(
            level: .trace,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    public func debug(_ item: Any?, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        log(
            level: .debug,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    public func info(_ item: Any?, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        log(
            level: .info,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    public func warning(_ item: Any?, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        log(
            level: .warning,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    public func error(_ item: Any?, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        log(
            level: .error,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    public func fatal(_ item: Any?, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        log(
            level: .fatal,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    private var currentTime: String {
        return Logger.logTimeFormatter.string(from: Date())
    }
}

final class Weak<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}

public final class LoggerManager {

    static var appenders: [Appender] = []

    static var loggers: [String: Weak<Logger>] = [:]

    public class func configure(appenders: [Appender]) {
        self.appenders = appenders
        for (_, logger) in loggers {
            logger.value?.appenders = appenders
        }
    }

    public static func getLogger(name: String) -> Logger {
        if let logger = LoggerManager.loggers[name], logger.value != nil {
            return logger.value!
        } else {
            let logger = Logger(name: name, appenders: LoggerManager.appenders)
            loggers[name] = Weak(value: logger)
            return loggers[name]!.value!
        }
    }
}

public class StandardOutputAppender: Appender {
    public let name: String
    public var levels: Logger.Level

    public init(name: String = "Standard Output Appender", levels: Logger.Level = .all) {
        self.name = name
        self.levels = levels
    }

    public func append(event: Logger.Event) {
        var logMessage = ""

        guard levels.contains(event.level) else {
            return
        }

        logMessage += "[" + event.timestamp + "]"
        logMessage += "[" + String(describing: event.locationInfo) + "]"

        if let message = event.message {
            logMessage += ":" + String(describing: message)
        }

        if let error = event.error {
            logMessage += ":" + String(describing: error)
        }

        print(logMessage)
    }
}

/// Minimal output stdout appender

public class MinimalAppender: Appender {

    public let name: String
    public var levels: Logger.Level

    public init(name: String = "Minimal Stdout Appender", levels: Logger.Level = .all) {
        self.name = name
        self.levels = levels
    }

    public func append(event: Logger.Event) {
        var logMessage = ""

        guard levels.contains(event.level) else {
            return
        }

        if let message = event.message {
            logMessage += ":" + String(describing: message)
        }

        if let error = event.error {
            logMessage += ":" + String(describing: error)
        }

        print(logMessage)
        fflush(stdout)
    }
}
