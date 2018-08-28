import Foundation
import Vapor
import Transport
import Testing

public func testableDropletFactory<A: ClientProtocol>(httpClientClass: A.Type) throws -> Droplet {
    let config = try Config(arguments: ["vapor", "--env=test"])
    config.addConfigurable(client: httpClientClass.self, name: "fake")
    let drop = try Droplet(config)
    return drop
}

open class FakeClient: ClientProtocol {
    let hostname: String
    let port: Transport.Port
    let securityLayer: SecurityLayer
    let proxy: Proxy?

    public required init(hostname: String, port: Transport.Port, securityLayer: SecurityLayer, proxy: Proxy?) throws {
        self.hostname = hostname
        self.port = port
        self.securityLayer = securityLayer
        self.proxy = proxy
    }

    public static let factory = FakeClientFactory()

    open func respond(to _: Request) throws -> Response {
        fatalError("Didn't set responder")
    }
}

public typealias FakeClientFactory = ClientFactory<FakeClient>
