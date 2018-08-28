import Foundation

public enum FullyQualifiedServiceNameError: Error {
    case PrefixIsMissing
    case DomainIsMissing
    case ContextIsMissing
    case ApplicationNameIsMissing
}

/// Type-safe microservices schema naming struct
public struct FullyQualifiedServiceName {
    public var boundedContext: String
    public var applicationName: String
    public var domain: String

    public init(string: String) throws {
        let components = string.split(separator: ".")
        switch components.count {
        case 0...1:
            // "pl.allegro"
            throw FullyQualifiedServiceNameError.PrefixIsMissing
        case 2:
            //"tech"
            throw FullyQualifiedServiceNameError.DomainIsMissing
        case 3:
             //"appengine"
            throw FullyQualifiedServiceNameError.ContextIsMissing
        case 4:
            //"appconsole"
            throw FullyQualifiedServiceNameError.ApplicationNameIsMissing
        default:
            self.domain = String(components[2])
            self.applicationName = String(components[4])
            self.boundedContext = String(components[3])
        }
    }

    public init(boundedContext: String, applicationName: String, domain: String) {
        self.applicationName = applicationName
        self.boundedContext = boundedContext
        self.domain = domain
    }
}
