//
//  ACGNCharacterSet.swift
//  App
//
//  Created by CaptainYukinoshitaHachiman on 2018/8/7.
//

import Foundation
import Vapor
import FluentMySQL

final class ACGNCharacterSet: Codable {
    
    var id: UUID?
    
    var name: String
    
    var shortName: String?
    
    var picPack: PicPack?
    
}

// - MARK: WithoutPicPack Declaration

extension ACGNCharacterSet {
    
    struct WithoutPicPack: Codable{
        
        var id: UUID?
        
        var name: String
        
        var shortName: String?
        
    }
    
    var withoutPicPack: WithoutPicPack {
        return WithoutPicPack(id: id, name: name, shortName: shortName)
    }
    
}

extension Future where T: ACGNCharacterSet {
    
    var withoutPicPack: Future<ACGNCharacterSet.WithoutPicPack> {
        return map { characterSet in
            return characterSet.withoutPicPack
        }
    }
    
}

extension ACGNCharacterSet.WithoutPicPack: Content {}

// - MARK: PicPack Related
extension Future where T: ACGNCharacterSet {
    
    var picPack: Future<PicPack> {
        return map { characterSet in
            guard let picPack = characterSet.picPack else { throw Abort(.notFound) }
            return picPack
        }
    }
    
}

extension ACGNCharacterSet: MySQLUUIDModel {}

extension ACGNCharacterSet: Migration {}

extension ACGNCharacterSet: Parameter {}

extension ACGNCharacterSet {
    
    var characters: Children<ACGNCharacterSet, ACGNCharacter> {
        return children(\.characterSetID)
    }
    
}
