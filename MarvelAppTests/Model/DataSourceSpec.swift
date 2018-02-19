//
//  DataSourceSpec.swift
//  MarvelAppTests
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RealmSwift
import RxTest
import RxBlocking

@testable import MarvelApp

class DataSourceSpec : QuickSpec {
    override func spec() {
        describe("DAO Class") {
            var testRealm: Realm!
            var dao: DAO!
            var testScheduler: TestScheduler!
            
            beforeEach{
                Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
                testRealm = try! Realm()
                dao = DAOImpl(realm: testRealm)
                testScheduler = TestScheduler(initialClock: 0)
            }
            
            afterEach {
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
            it("should retrieve characters list form remote and update cache if remote data is available") {
                let remoteDataSource = RemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let observer = testScheduler.createObserver((data: [MarvelApp.Character], source: DataSources).self)
                _ = dataSource.getCharactersList(offset: 0, limit: 20).subscribe(observer)
                testScheduler.start()
                
                let expectedResponse = FakeDataProvider.provideCharactersList(startIndex: 0, count: 20)
                expect(observer.events.last?.value.element?.data.count).to(equal(20))
                expect(observer.events.last?.value.element?.source).to(equal(DataSources.remote))
                
                observer.events.last!.value.element!.data.enumerated().forEach {
                    expect($0.element).to(equal(expectedResponse[$0.offset]))
                }
                
                dao.getCharacters(offset: 0, limit: 20).enumerated().forEach {
                    expect($0.element).to(equal(expectedResponse[$0.offset]))
                }
            }
            
            it("should retrieve characters list form local cache if remote data is not available") {
                
                dao.addNewOrUpdateExistingCharacters(FakeDataProvider.provideCharactersList(startIndex: 0, count: 20))
                
                let remoteDataSource = FailedRemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let observer = testScheduler.createObserver((data: [MarvelApp.Character], source: DataSources).self)
                _ = dataSource.getCharactersList(offset: 0, limit: 20).subscribe(observer)
                testScheduler.start()
                
                let expectedResponse = FakeDataProvider.provideCharactersList(startIndex: 0, count: 20)
                expect(observer.events.first?.value.element?.data.count).to(equal(20))
                expect(observer.events.first?.value.element?.source).to(equal(DataSources.local))
                
                observer.events.first!.value.element!.data.enumerated().forEach {
                    expect($0.element).to(equal(expectedResponse[$0.offset]))
                }
            }
            
            it("should retrieve character details form remote and update cache if remote data is available") {
                let remoteDataSource = RemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let observer = testScheduler.createObserver((data: MarvelApp.Character, source: DataSources).self)
                _ = dataSource.getCharacterDetails(characterId: 1).subscribe(observer)
                testScheduler.start()
                
                let expectedResponse = FakeDataProvider.provideCharactersList(startIndex: 1).first!
                expect(observer.events.first?.value.element?.data).to(equal(expectedResponse))
                expect(observer.events.first?.value.element?.source).to(equal(DataSources.remote))
                expect(dao.getCharacter(withID: expectedResponse.id!)).to(equal(expectedResponse))
            }
            
            it("should retrieve character details form local cache if remote data is not available") {
                dao.addNewOrUpdateExistingCharacters([FakeDataProvider.provideCharactersList(startIndex: 1).first!])
                let remoteDataSource = FailedRemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let observer = testScheduler.createObserver((data: MarvelApp.Character, source: DataSources).self)
                _ = dataSource.getCharacterDetails(characterId: 1).subscribe(observer)
                testScheduler.start()
                
                let expectedResponse = FakeDataProvider.provideCharactersList(startIndex: 1).first!
                expect(observer.events.first?.value.element?.data).to(equal(expectedResponse))
                expect(observer.events.first?.value.element?.source).to(equal(DataSources.local))
                expect(dao.getCharacter(withID: expectedResponse.id!)).to(equal(expectedResponse))
            }
            
            it("should retrieve comics for character form remote and update cache if remote data is available") {
                let remoteDataSource = RemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let observer = testScheduler.createObserver((data: [Comic], source: DataSources).self)
                _ = dataSource.getComics(characterId: 1).subscribe(observer)
                testScheduler.start()
                
                let expectedResponse = FakeDataProvider.provideComicsList()
                observer.events.first?.value.element?.data.enumerated().forEach {
                    expect($0.element).to(equal(expectedResponse[$0.offset]))
                }
                
                dao.getComicsForCharacter(withID: 1).enumerated().forEach {
                    expect($0.element).to(equal(expectedResponse[$0.offset]))
                }
                expect(observer.events.first?.value.element?.source).to(equal(DataSources.remote))
            }
            
            it("should retrieve comics for character form local cache if remote data is not available") {
                dao.setComics(FakeDataProvider.provideComicsList(), forCharacterWithID: 1)
                let remoteDataSource = FailedRemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let observer = testScheduler.createObserver((data: [Comic], source: DataSources).self)
                _ = dataSource.getComics(characterId: 1).subscribe(observer)
                testScheduler.start()
                
                let expectedResponse = FakeDataProvider.provideComicsList()
                observer.events.first?.value.element?.data.enumerated().forEach {
                    expect($0.element).to(equal(expectedResponse[$0.offset]))
                }
                expect(observer.events.first?.value.element?.source).to(equal(DataSources.local))
            }
        }
    }
}

