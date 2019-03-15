//
//  User.swift
//  App
//
//  Created by CaptainYukinoshitaHachiman on 2018/8/14.
//

import Vapor
import FluentMySQL
import Authentication

final class User: Codable {
    
    var id: UUID?
    
    var username: String
    
    var nickname: String
    
    /// Password stored in hash
    var password: String
    
    var permission: Permission
    
    private init() { fatalError() }
    
    init(username: String, nickname: String? = nil, password: String, permission: Permission = .user) {
        self.username = username
        self.nickname = nickname ?? username
        self.password = password
        self.permission = permission
    }
    
}

// - MARK: `User.Permission` Declaration and `Codable` Conformance
extension User {
    
    enum Permission: Int {
        case user
        case contributer
        case admin
        case root
    }
    
}

extension User.Permission: Codable {
    
    enum CodingKeys: CodingKey {
        case rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        guard let instance = User.Permission(rawValue: rawValue) else { throw Abort(.badRequest) }
        self = instance
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
    
}

// - MARK: Public User Info Declaration
extension User {
    
    struct Public: Codable {
        
        var id: UUID?
        
        var username: String
        
        var nickname: String
        
        var permission: Permission
        
    }
    
    var `public`: Public {
        return Public(id: id, username: username, nickname: nickname, permission: permission)
    }
    
}

extension Future where T: User {
    
    var `public`: Future<User.Public> {
        return map { return $0.public }
    }
    
}

extension User.Public: Content {}

// - MARK: Authentication Related
extension User: BasicAuthenticatable {
    
    static var usernameKey: WritableKeyPath<User, String> = \.username
    
    static var passwordKey: WritableKeyPath<User, String> = \.password
    
}

extension User: TokenAuthenticatable {
    
    typealias TokenType = Token
    
}

// - MARK: `User` Fluent Related
extension User: MySQLUUIDModel {}

extension User: Parameter {}

extension User: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
    
}
