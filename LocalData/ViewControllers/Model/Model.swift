//
//  Model.swift
//  LocalData
//
//  Created by Sathish on 29/04/24.
//

import Foundation

class User: Codable {
    var name: String?
    var mobile: String?
    var email: String?
    var gender: String?
    var id: String?
    
    enum CodingKeys: String, CodingKey {
        case name, mobile, email, gender
        case id = "_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
    }
    
    init() {
        // Initialize properties if needed
    }
}
