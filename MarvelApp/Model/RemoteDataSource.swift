//
//  RemoteDataSource.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/22/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class RemoteDataSource: DataSource {
    func getCharactersList(offset: Int, limit: Int) -> Observable<(data: [Character], source: DataSources)> {
        return Observable<(data: [Character], source: DataSources)>.create { (observer) -> Disposable in
            let requestReference = Alamofire.request("https://gateway.marvel.com/v1/public/characters",
                                                     method: .get,
                                                     parameters: self.generateRequestParameters(with: ["offset" : offset, "limit":limit]))
                .validate()
                .responseJSON { (response) in
                    switch response.result{
                    case .success:
                        guard let json = response.result.value as? [String:Any] else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        
                        guard let data = json["data"] as? [String:Any] else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        
                        guard let characters = data["results"] as? [[String:Any]] else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        
                        observer.onNext((data: characters.map { Character(jsonRepresentation: $0) }, source: DataSources.remote))
                        observer.onCompleted()
                    case .failure:
                        observer.onError(Errors.remoteError)
                    }
            }
            return Disposables.create(with: {
                requestReference.cancel()
            })
        }
    }
    
    func getCharacterDetails(characterId: Int) -> Observable<(data: Character, source: DataSources)> {
        return Observable<(data: Character, source: DataSources)>.create { (observer) -> Disposable in
            let requestReference = Alamofire.request("https://gateway.marvel.com/v1/public/characters/\(characterId)",
                method: .get,
                parameters: self.generateRequestParameters())
                .validate()
                .responseJSON { (response) in
                    switch response.result{
                    case .success:
                        guard let json = response.result.value as? [String:Any] else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        
                        guard let data = json["data"] as? [String:Any] else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        
                        guard let characters = data["results"] as? [[String:Any]], characters.first != nil else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        
                        observer.onNext((data: Character(jsonRepresentation: characters.first!), source: DataSources.remote))
                        observer.onCompleted()
                    case .failure:
                        observer.onError(Errors.remoteError)
                    }
            }
            return Disposables.create(with: {
                requestReference.cancel()
            })
        }
    }
    
    func getComics(characterId: Int) -> Observable<(data: [Comic], source: DataSources)> {
        return Observable<(data: [Comic], source: DataSources)>.create { (observer) -> Disposable in
            let requestReference = Alamofire.request("https://gateway.marvel.com/v1/public/characters/\(characterId)/comics",
                method: .get,
                parameters: self.generateRequestParameters())
                .validate()
                .responseJSON { (response) in
                    switch response.result{
                    case .success:
                        guard let json = response.result.value as? [String:Any] else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        
                        guard let data = json["data"] as? [String:Any] else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        
                        guard let count = data["count"] as? Int, count > 0 else {
                            observer.onCompleted()
                            return
                        }
                        
                        guard let comics = data["results"] as? [[String:Any]] else {
                            self.onJsonParsingError(observer)
                            return
                        }
                        observer.onNext((data: comics.map { Comic(jsonRepresentation: $0) }, source: DataSources.remote))
                        observer.onCompleted()
                    case .failure:
                        observer.onError(Errors.remoteError)
                    }
            }
            return Disposables.create(with: {
                requestReference.cancel()
            })
        }
    }
    
    private func generateRequestParameters(with params: [String:Any] = [:]) -> [String:Any] {
        let ts = "\(Int64(Date().timeIntervalSince1970 * 1000))"
        let apiKey = "621433ba46b49c075a2a6aa97dda05bc"
        let hash = "\(ts)31065cb6c2ea675299d45850d7e18ad7439e9fb4\(apiKey)".toMd5()
        var requestParams = params
        requestParams["ts"] = ts
        requestParams["apikey"] = apiKey
        requestParams["hash"] = hash
        return requestParams
    }
    
    private func onJsonParsingError<T>(_ observer: AnyObserver<T>) {
        observer.onError(Errors.remoteError)
    }
}
