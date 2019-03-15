@testable import App
import XCTest
import Vapor
import FluentMySQL
import Foundation
import Authentication

final class UserTests: XCTestCase {
    
    func clear(table tableName: String, condition: String? = nil, on connection: MySQLConnection) throws {
        _ = try connection.simpleQuery("DELETE FROM `\(tableName)` \(condition ?? "");").wait()
    }
    
    func prepare() throws -> (app: Application, connection: MySQLConnection, responder: Responder) {
        let application = try app(.testing)
        let connection = try application.newConnection(to: .mysql).wait()
        let responder = try application.make(Responder.self)
        return (application, connection, responder)
    }
    
    func testRegister() throws {
        let preparations = try prepare()
        
        // Clear previous user
        try clear(table: "User", condition: "WHERE `username` = 'otakuHacker'", on: preparations.connection)
        
        let user = User(username: "otakuHacker", nickname: "変態紳士", password: "I'm Super Hacker!")
        let jsonEncoder = JSONEncoder()
        let encoded = try jsonEncoder.encode(user)
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        let httpRequest = HTTPRequest(method: .POST,
                                      url: URL(string: "/users")!,
                                      headers: headers,
                                      body: encoded)
        let wrappedRequest = Request(http: httpRequest, using: preparations.app)
        
        let response = try preparations.responder.respond(to: wrappedRequest).wait()
        
        let receivedData = response.http.body.data!
        let jsonDecoder = JSONDecoder()
        let receivedUser = try jsonDecoder.decode(User.Public.self, from: receivedData)
        
        XCTAssertEqual(receivedUser.username, user.username)
        XCTAssertEqual(receivedUser.nickname, user.nickname)
        XCTAssertEqual(receivedUser.permission, user.permission)
    }
    
    func testLogin() throws {
        let preparations = try prepare()
        
        var loginHeaders = HTTPHeaders()
        loginHeaders.basicAuthorization = BasicAuthorization(username: "root", password: "password")
        let loginHTTPRequest = HTTPRequest(method: .POST,
                                           url: URL(string: "/users/login")!,
                                           headers: loginHeaders)
        let wrappedLoginRequest = Request(http: loginHTTPRequest, using: preparations.app)
        let loginResponse = try preparations.responder.respond(to: wrappedLoginRequest).wait()
        let receivedTokenData = loginResponse.http.body.data!
        let jsonDecoder = JSONDecoder()
        let token = try? jsonDecoder.decode(Token.self, from: receivedTokenData)
        XCTAssertNotNil(token)
    }
    
    func testQuery() throws {
        let preparations = try prepare()
        
        let httpRequest = HTTPRequest(method: .GET,
                                      url: URL(string: "/users/search?username=root")!)
        let wrappedRequest = Request(http: httpRequest, using: preparations.app)
        let response = try preparations.responder.respond(to: wrappedRequest).wait()
        let responseData = response.http.body.data!
        
        let jsonDecoder = JSONDecoder()
        let user = try jsonDecoder.decode([User.Public].self, from: responseData).first
        XCTAssertNotNil(user)
    }
    
    static let allTests = [
        ("register", testRegister),
        ("login", testLogin),
        ("testQuery", testQuery)
    ]
    
}
