//
//  User.swift
//  AudioSound
//
//  Created by Olisemedua Onwuatogwu on 4/25/23.
//

import Foundation
import ParseSwift

struct User: ParseUser{
    
    // These are required by `ParseObject`.
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // These are required by `ParseUser`.
    var username: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?
    
    
}
