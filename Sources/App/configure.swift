import FluentMySQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a MySQL database
    guard let url = Environment.get("MySQLDatabaseURL") else {
        fatalError("No database url set. Use `export MySQLDatabaseURL=mysql://username:password@host:port/database` to do it.")
    }
    
    #warning("Certificate not verified")
    let tlsConfiguration = TLSConfiguration.forClient(minimumTLSVersion: .tlsv11, certificateVerification: .none)
    let mysqlConfig = try MySQLDatabaseConfig(url: url, capabilities: .default, characterSet: .utf8mb4_unicode_ci, transport: .customTLS(tlsConfiguration))!
    let mysql = MySQLDatabase(config: mysqlConfig)
    
    /// Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: ACGNCharacterSet.self, database: .mysql)
    migrations.add(model: ACGNCharacter.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    services.register(migrations)
    
}
