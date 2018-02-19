//
//  DAO.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RealmSwift

protocol DAO {
    func clearAllCharacters()
    func addNewOrUpdateExistingCharacters(_ characters: [Character])
    func getCharacters(offset: Int, limit: Int) -> [Character]
    func setComics( _ comics: [Comic], forCharacterWithID: Int)
    func getComicsForCharacter(withID: Int) -> [Comic]
    func getCharacter(withID id: Int) -> Character?
}

class DAOImpl : DAO {

    let realm: Realm
    init(realm:Realm) {
        self.realm = realm
    }

    func clearAllCharacters() {
        try! realm.write {
            realm.delete(realm.objects(Character_Realm.self))
        }
    }
    
    func addNewOrUpdateExistingCharacters(_ characters: [Character]) {
        try! realm.write {
            characters.forEach {
                realm.add(Character_Realm(character: $0), update: true)
            }
        }
    }
    
    func getCharacters(offset: Int, limit: Int) -> [Character] {
        let storedCharacters = realm.objects(Character_Realm.self)
        guard storedCharacters.count > offset else {
            return []
        }
        let upperBound = storedCharacters.count < offset+limit-1 ? storedCharacters.count-1 : offset+limit-1
        return storedCharacters[offset...upperBound].map{$0.toCharacter()}
    }
    
    func getCharacter(withID id: Int) -> Character? {
        return realm.objects(Character_Realm.self).filter("id = \(id)").first?.toCharacter()
    }
    
    func setComics( _ comics: [Comic], forCharacterWithID characterID: Int) {
        try! realm.write {
            realm.objects(Comic_Realm.self).filter("characterID = \(characterID)").forEach{
                realm.delete($0)
            }
            let realmComics: [Comic_Realm] = comics.map {
                let realmComic = Comic_Realm(comic: $0)
                realmComic.characterID = characterID
                return realmComic
            }
            realm.add(realmComics)
        }
    }
    
    func getComicsForCharacter(withID id: Int) -> [Comic]{
        return realm.objects(Comic_Realm.self).filter("characterID = \(id)").map{ $0.toComic() }
    }
}
