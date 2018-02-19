//
//  Character.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/22/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation

struct Character {
    let id: Int?
    let name: String?
    let thumbnailURL: String?
    let description: String?
    
    init(id: Int?, name: String?, thumbnailURL: String?,
         description: String?) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbnailURL
        self.description = description
    }
}

extension Character: Equatable {
    static func ==(lhs: Character, rhs: Character) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.thumbnailURL == rhs.thumbnailURL
            && lhs.description == rhs.description
    }
}

// An extention for parsing Character JSON Reporesentation
extension Character {
    init(jsonRepresentation: [String: Any]) {
        id = jsonRepresentation["id"] as? Int
        name = jsonRepresentation["name"] as? String
        thumbnailURL = {
            guard let thumbnail = jsonRepresentation["thumbnail"] as? [String:String] else {
                return nil
            }
            
            guard let path = thumbnail["path"] else {
                return nil
            }

            return "\(path).\(thumbnail["extension"] ?? " ")"
        } ()
        
        description = jsonRepresentation["description"] as? String
    }
}

// Returning a new immutable copy with the some changed properites
extension Character {
    func copyWith(id: Int? = nil, name: String? = nil, thumbnailURL: String? = nil,
                       description: String? = nil) -> Character {
        return Character(id: id ?? self.id, name: name ?? self.name, thumbnailURL: thumbnailURL ?? self.thumbnailURL, description: description ?? self.description)
    }
}
