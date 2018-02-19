//
//  FailedRemotDataSourceMock.swift
//  MarvelAppTests
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RxSwift
import RxTest

@testable import MarvelApp

class FailedRemotDataSourceMock : DataSource {
    
    var testScheduler: TestScheduler
    init(scheduler: TestScheduler) {
        self.testScheduler = scheduler
    }
    
    func getCharactersList(offset: Int, limit: Int) -> Observable<(data: [MarvelApp.Character], source: DataSources)> {
        return returnScheduledError(scheduler: testScheduler)
    }
    
    func getCharacterDetails(characterId: Int) -> Observable<(data: MarvelApp.Character, source: DataSources)> {
        return returnScheduledError(scheduler: testScheduler)
    }
    
    func getComics(characterId: Int) -> Observable<(data: [Comic], source: DataSources)> {
        return returnScheduledError(scheduler: testScheduler)
    }
    
    private func returnScheduledError<T>(virtualTime: Int = 100,
                                         scheduler: TestScheduler) -> Observable<T>{
        return scheduler.createHotObservable([next(virtualTime, true)]).map{ result in
            throw Errors.remoteError
        }
    }
}
