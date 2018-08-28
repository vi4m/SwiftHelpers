import Foundation
import Vapor


enum ServiceMetadataError: Error {
    case FileError
    case MetaDataMissing
}

public struct ServiceMetadata: Codable {

    // required
    public var title: String
    public var version: String
    public var domain: String
    public var boundedContext: String
    public var serviceId: String

    // optional
    public var builtBy: String?
    public var builtDate: String?
    public var builtHost: String?
    public var scmBranch: String?
    public var scmCommit: String?
    public var scmRepository: String?

    public func taskId() -> String {
        if let variable = getEnv("MESOS_TASK_ID") {
            return variable
        } else {
            return UUID().description
        }
    }
}

/// Builds ServiceMetadata struct from JSON file (usually project-properties.json)
public struct ServiceMetadataBuilder {

    public var projectPropertiesPath: String?
    public var metadata: ServiceMetadata

    public static var `default` = ServiceMetadataBuilder()

    /// If projectPropertiesPath is set to null, PROJECT_PROPERTIES_PATH will
    /// be used to discover project-properties.json file
    public init(projectPropertiesPath projectPropertiesPathParam: String? = nil) {
        let path = projectPropertiesPathParam ?? getEnv("PROJECT_PROPERTIES_PATH")!
        let contents = try! Data(
            contentsOf: URL(fileURLWithPath: path))
        
        self.init(projectPropertiesContents: contents)
        self.projectPropertiesPath = path
    }

    public init(projectPropertiesContents: Data) {
        metadata = try! JSONDecoder().decode(ServiceMetadata.self, from: projectPropertiesContents)
    }
}
