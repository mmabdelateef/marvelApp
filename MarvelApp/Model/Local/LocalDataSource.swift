//
//  LocalDataSource.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RxSwift

class LocalDataSource: DataSource {
    
    private let dao: DAO
    init(dao: DAO) {
        self.dao = dao
    }
    
    func getCharactersList(offset: Int, limit: Int) -> Observable<(data: [Character], source: DataSources)> {
        let characters = dao.getCharacters(offset: offset, limit: limit)
        return Observable<(data:[Character],source:DataSources)>.just((data: characters, source: DataSources.local))
    }
    
    func getCharacterDetails(characterId: Int) -> Observable<(data: Character, source: DataSources)> {
        if let character = dao.getCharacter(withID: characterId) {
            return Observable<(data: Character, source: DataSources)>.just((data: character, source: DataSources.local))
        } else {
            return Observable<(data: Character, source: DataSources)>.empty()
        }
    }
    
    func getComics(characterId: Int) -> Observable<(data: [Comic], source: DataSources)> {
        let comics = dao.getComicsForCharacter(withID: characterId)
        return Observable<(data: [Comic], source: DataSources)>.just((data: comics, source: DataSources.local))
    }
}
