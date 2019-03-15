//
//  Token.swift
//  App
//
//  Created by CaptainYukinoshitaHachiman on 2018/8/17.
//

import Vapor
import FluentMySQL
import Authentication

final class Token: Codable {
    
    var id: UUID?
    
    var token: String
    
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    
}

extension Token {
    
    static func generate(for user: User) throws -> Token {
        let randomData = try CryptoRandom().generateData(count: 32)
        return try Token(token: randomData.base64EncodedString(), userID: user.requireID())
    }
    
}

extension Token: MySQLUUIDModel {}

extension Token: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
    
}

extension Token: Content {}

// - MARK: Authentication Related
extension Token: Authentication.Token {
    
    typealias UserType = User
    
    static var userIDKey: WritableKeyPath<Token, UUID> = \.userID
    
}

extension Token: BearerAuthenticatable {
    
    static var tokenKey: WritableKeyPath<Token, String> = \.token
    
}
