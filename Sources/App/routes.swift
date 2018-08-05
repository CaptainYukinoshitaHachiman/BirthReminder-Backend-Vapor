import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.grouped("characters").register(collection: CharacterController())
    try router.grouped("characterSets").register(collection: CharacterSetController())
    try router.grouped("users").register(collection: UserController())
}
