//
//  ACGNCharacter.swift
//  App
//
//  Created by CaptainYukinoshitaHachiman on 2018/8/7.
//

import Foundation
import Vapor
import FluentMySQL

final class ACGNCharacter: Codable {
    
    var id: UUID?
    
    var name: String
    
    var shortName: String?
    
    var birthday: Birthday

    var picPack: PicPack?
    
    var characterSetID: ACGNCharacterSet.ID
    
}

// - MARK: WithoutPicPack Declaration
extension ACGNCharacter {
    
    struct WithoutPicPack: Codable {
        
        var id: UUID?
        
        var name: String
        
        var shortName: String?
        
        var birthday: Birthday
        
    }
    
    var withoutPicPack: WithoutPicPack {
        return WithoutPicPack(id: id, name: name, shortName: shortName, birthday: birthday)
    }
    
}

extension Future where T: ACGNCharacter {
    
    var withoutPicPack: Future<ACGNCharacter.WithoutPicPack> {
        return map { character in
            return character.withoutPicPack
        }
    }
    
}

extension ACGNCharacter.WithoutPicPack: Content {}

// - MARK: PicPack Related
extension Future where T: ACGNCharacter {
    
    var picPack: Future<PicPack> {
        return map { character in
            guard let picPack = character.picPack else { throw Abort(.notFound) }
            return picPack
        }
    }
    
}

// - MARK: Fluent Related
extension ACGNCharacter: MySQLUUIDModel {}

extension ACGNCharacter: Parameter {}

extension ACGNCharacter {
    
    var anime: Parent<ACGNCharacter, ACGNCharacterSet> {
        return parent(\.characterSetID)
    }
    
}

extension ACGNCharacter: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.characterSetID, to: \ACGNCharacterSet.id, onDelete: ._cascade)
        }
    }
    
}
