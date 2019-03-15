//
//  CharacterSetController.swift
//  App
//
//  Created by CaptainYukinoshitaHachiman on 2018/8/7.
//

import Vapor
import Fluent

struct CharacterSetController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: getAllHandler)
        router.get(ACGNCharacterSet.parameter, use: getHandler)
        router.get(ACGNCharacterSet.parameter,"picPack", use: getPicPackHandler)
        router.get(ACGNCharacterSet.parameter,"characters", use: getCharactersHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let protectedRoute = router.grouped([tokenAuthMiddleware,guardAuthMiddleware])
        protectedRoute.delete(ACGNCharacterSet.parameter, use: deleteHandler)
        protectedRoute.post(use: createHandler)
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[ACGNCharacterSet.WithoutPicPack]> {
        return ACGNCharacterSet
            .query(on: request)
            .all()
            .map { $0.map { $0.withoutPicPack } }
    }
    
    func getPicPackHandler(_ request: Request) throws -> Future<PicPack> {
        return try request
            .parameters
            .next(ACGNCharacterSet.self)
            .picPack
    }
    
    func getHandler(_ request: Request) throws -> Future<ACGNCharacterSet.WithoutPicPack> {
        return try request
            .parameters
            .next(ACGNCharacterSet.self)
            .withoutPicPack
    }
    
    func getCharactersHandler(_ request: Request) throws -> Future<[ACGNCharacter.WithoutPicPack]> {
        return try request
            .parameters
            .next(ACGNCharacterSet.self)
            .flatMap { characterSet in
                return try characterSet
                    .characters
                    .query(on: request)
                    .all()
            }.map { $0.map { $0.withoutPicPack } }
    }
    
    func createHandler(_ request: Request) throws -> Future<String> {
        let user = try request.requireAuthenticated(User.self)
        guard user.permission.rawValue >= User.Permission.contributer.rawValue else {
            throw Abort(.forbidden, reason: "You don't have the permission to delete it.")
        }
        
        return try request
            .content
            .decode(ACGNCharacterSet.self)
            .flatMap { set in
                return set
                    .save(on: request)
                    .map { savedSet in
                        guard let id = savedSet.id else { throw Abort(.internalServerError) }
                        return id.uuidString
                }
        }
    }
    
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        let user = try request.requireAuthenticated(User.self)
        guard user.permission.rawValue >= User.Permission.admin.rawValue else {
            throw Abort(.forbidden, reason: "You don't have the permission to delete it.")
        }
        
        return try request
            .parameters
            .next(ACGNCharacterSet.self)
            .flatMap(to: HTTPStatus.self) { anime in
                return anime.delete(on: request).transform(to: HTTPStatus.ok)
        }
    }
    
}
