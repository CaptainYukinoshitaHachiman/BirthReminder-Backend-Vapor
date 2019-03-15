import Vapor
import Crypto

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // Add default users
    let rootPassword = Environment.get("rootPassword") ?? "password"
    let adminPassword = Environment.get("adminPassword") ?? "password"
    let contributerPassword = Environment.get("contributerPassword") ?? "password"
    let userPassword = Environment.get("userPassword") ?? "password"
    
    try add(defaultUser: User(username: "root",
                          password: rootPassword,
                          permission: .root), for: app)
    try add(defaultUser: User(username: "admin",
                          password: adminPassword,
                          permission: .admin), for: app)
    try add(defaultUser: User(username: "contributer",
                          password: contributerPassword,
                          permission: .contributer), for: app)
    try add(defaultUser: User(username: "user",
                          password: userPassword,
                          permission: .user), for: app)
}

func add(defaultUser: User, for app: Application) throws {
    try defaultUser.password = BCrypt.hash(defaultUser.password)
    let connection = try app.newConnection(to: .mysql).wait()
    _ = defaultUser.create(on: connection)
}
