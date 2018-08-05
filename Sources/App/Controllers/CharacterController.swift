//
//  CharacterController.swift
//  App
//
//  Created by CaptainYukinoshitaHachiman on 2018/8/15.
//

import Vapor
import Fluent
import Crypto

class CharacterController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(ACGNCharacter.parameter, use: getCharacterHandler)
        router.get(ACGNCharacter.parameter, use: getPicPackHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let protectedRoute = router.grouped([basicAuthMiddleware,guardAuthMiddleware])
        
        protectedRoute.post(use: createCharacterHandler)
    }
    
    func createCharacterHandler(_ request: Request) throws -> Future<String> {
        return try request
            .content
            .decode(ACGNCharacter.self)
            .flatMap { character in
                character
                    .save(on: request)
                    .map { saved in
                        guard let id = saved.id else { throw Abort(.internalServerError) }
                        return id.uuidString
                }
        }
    }
    
    func getCharacterHandler(_ request: Request) throws -> Future<ACGNCharacter.WithoutPicPack> {
        return try request
            .parameters
            .next(ACGNCharacter.self)
            .withoutPicPack
    }
    
    func getPicPackHandler(_ request: Request) throws -> Future<PicPack> {
        return try request
            .parameters
            .next(ACGNCharacter.self)
            .picPack
    }
    
}
