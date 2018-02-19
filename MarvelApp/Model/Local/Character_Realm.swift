//
//  Character_Realm.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RealmSwift

class Character_Realm: Object {
    let id = RealmOptional<Int>()
    @objc dynamic var name: String?
    @objc dynamic var thumbnailURL: String?
    @objc dynamic var _description: String?

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(character: Character) {
        self.init()
        self.id.value = character.id
        self.name = character.name
        self.thumbnailURL = character.thumbnailURL
        self._description = character.description
    }
    
    func toCharacter() -> Character {
        return Character(id: self.id.value, name: self.name, thumbnailURL: self.thumbnailURL, description: self._description)
    }
}
