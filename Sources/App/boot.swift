import Vapor
import Crypto

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // Add default root user
    let plainPassword = Environment.get("rootPassword") ?? ""
    let user = try User(username: "root", nickname: "Administrator", password: BCrypt.hash(plainPassword), permission: .root)
    let connection = try app.newConnection(to: .mysql).wait()
    _ = user.create(on: connection)
}
