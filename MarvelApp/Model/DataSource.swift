//
//  DataSource.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RxSwift

protocol DataSource {
    func getCharactersList(offset: Int, limit: Int) -> Observable<(data: [Character], source: DataSources)>
    func getCharacterDetails(characterId: Int) ->  Observable<(data: Character, source: DataSources)>
    func getComics(characterId: Int) ->  Observable<(data: [Comic], source: DataSources)>
}

class DataSourceImpl: DataSource{
    
    private let remoteDataSource: DataSource
    private let localDataSource: DataSource
    private let dao: DAO
    
    init(remoteDataSource: DataSource, localDataSource: DataSource, dao: DAO) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.dao = dao
    }
    
    func getCharactersList(offset: Int, limit: Int) -> Observable<(data: [Character], source: DataSources)> {
        return remoteDataSource.getCharactersList(offset: offset, limit: limit)
            .do(onNext: { remoteResponse in
                self.dao.addNewOrUpdateExistingCharacters(remoteResponse.data)
            })
            .catchError { remoteError in
                return self.localDataSource.getCharactersList(offset: offset, limit: limit)
        }
    }
    
    func getCharacterDetails(characterId: Int) -> Observable<(data: Character, source: DataSources)> {
        return remoteDataSource.getCharacterDetails(characterId: characterId)
            .do(onNext: { remoteResponse in
                self.dao.addNewOrUpdateExistingCharacters([remoteResponse.data])
            }).catchError { remoteError in
                return self.localDataSource.getCharacterDetails(characterId: characterId)
        }
    }
    
    func getComics(characterId: Int) -> Observable<(data: [Comic], source: DataSources)> {
        return remoteDataSource.getComics(characterId: characterId)
            .do(onNext: { remoteResponse in
                self.dao.setComics(remoteResponse.data, forCharacterWithID: characterId)
            }).catchError { remoteError in
                return self.localDataSource.getComics(characterId: characterId)
        }
    }
}

enum DataSources {
    case local
    case remote
}
