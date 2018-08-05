//
//  PicPack.swift
//  App
//
//  Created by CaptainYukinoshitaHachiman on 2018/8/8.
//

import Foundation
import Vapor
import FluentMySQL

// - MARK: `PicPack` Declaration and Fluent Related
struct PicPack: Codable {
    
    var pictureData: Data
    
    var description: String
    
}

extension PicPack: Content {}
