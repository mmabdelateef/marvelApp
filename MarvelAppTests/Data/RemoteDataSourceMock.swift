//
//  RemoteDataSourceMock.swift
//  MarvelAppTests
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RxSwift
import RxTest

@testable import MarvelApp

class RemotDataSourceMock : DataSource {
    
    var testScheduler: TestScheduler
    init(scheduler: TestScheduler) {
        self.testScheduler = scheduler
    }
    
    func getCharactersList(offset: Int, limit: Int) -> Observable<(data: [MarvelApp.Character], source: DataSources)> {
        return returnScheduledResult(data: (data:FakeDataProvider.provideCharactersList(startIndex: offset, count: limit), source: DataSources.remote),
                                     scheduler: testScheduler)
    }
    
    func getCharacterDetails(characterId: Int) -> Observable<(data: MarvelApp.Character, source: DataSources)> {
        return returnScheduledResult(data: (data:FakeDataProvider.provideCharactersList(startIndex: 1).first!, source: DataSources.remote),
                                     scheduler: testScheduler)
    }
    
    func getComics(characterId: Int) -> Observable<(data: [Comic], source: DataSources)> {
        return returnScheduledResult(data: (data:FakeDataProvider.provideComicsList(), source: DataSources.remote),
                                     scheduler: testScheduler)
    }
    
    private func returnScheduledResult<T>(data: T, virtualTime: Int = 100,
                                         scheduler: TestScheduler) -> Observable<T>{
        return scheduler.createHotObservable([next(virtualTime, true)]).map{ result in
            return data
        }
    }
}

