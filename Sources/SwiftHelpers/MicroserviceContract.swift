import Vapor
import LeafProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]
        try setupProviders()
    }

    /// Configure providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
    }
}

public func addMicroserviceContractEndpoints(drop: Droplet, metadata info: ServiceMetadata) throws {

    let appId = info.taskId()

    drop.get("/status/ping/\(appId)") { _ in
        return "pong"
    }

    drop.get("/status/ping") { _ in
        return "pong"
    }

    drop.get("/status/info") { _ in
        var json = JSON()

        try! json.set("title", info.title)
        try! json.set("version", info.version)
        try! json.set("domain", info.domain)

        return json
    }
    drop.get("/status/ping/", ":service") { request in
        guard let service = request.parameters["service"]?.string else {
            return Response(status: .badRequest)
        }
        if service == info.serviceId {
            return "pong"
        } else {
            return Response(status: .notFound)
        }
    }
    drop.get("/status/public-endpoints") { _ in
        // FIXME(vi4m): implement this
        return "Not implemented yet"
    }
}
