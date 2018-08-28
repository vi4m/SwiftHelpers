import Foundation

extension String {
    public func write(toFile path: String) throws {
        try self.write(toFile: path, atomically: false, encoding: .utf8)
    }

    public init(fromFile filename: String) throws {
        try self.init(contentsOfFile: filename, encoding: .utf8)
    }
}

public func getEnv(_ variable: String) -> String? {
    return ProcessInfo.processInfo.environment[variable]
}
