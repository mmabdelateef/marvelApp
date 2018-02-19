//
//  CharacterDetailsVMSpec.swift
//  MarvelAppTests
//
//  Created by Mostafa Abdellateef on 2/24/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RealmSwift
import RxTest
import RxBlocking

@testable import MarvelApp

class CharacterDetailsVMSpec : QuickSpec {
    override func spec() {
        describe("CharacterDetailsViewModel Class") {
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
            
            it("state should be fetching->remoteDataAvailable with a list of comics if remoteDataFormApi is available") {
                let remoteDataSource = RemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let character = FakeDataProvider.provideCharactersList().first!
                let vm = CharacterDetailsViewModel(dataSource: dataSource, character: character)
                let observer = testScheduler.createObserver(CharacterDetailsViewModel.State.self)
                _ = vm.state.subscribe(observer)
                testScheduler.start()
                
                expect(vm.character).to(equal(character))
                expect(observer.events[0].value.element!).to(equal(CharacterDetailsViewModel.State.fetching))
                expect(observer.events[1].value.element!).to(equal(CharacterDetailsViewModel.State.remoteDataAvailable(data: FakeDataProvider.provideComicsList())))
            }
            
            
            it("state should be fetching->localDataAvailable with a list of comics if remoteDataFormApi is not available and data is already cached before") {
                
                let remoteDataSource = FailedRemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let character = FakeDataProvider.provideCharactersList().first!
                dao.setComics(FakeDataProvider.provideComicsList(), forCharacterWithID: character.id!)
                let vm = CharacterDetailsViewModel(dataSource: dataSource, character: character)
                let observer = testScheduler.createObserver(CharacterDetailsViewModel.State.self)
                _ = vm.state.subscribe(observer)
                testScheduler.start()
                
                expect(observer.events[0].value.element!).to(equal(CharacterDetailsViewModel.State.fetching))
                expect(observer.events[1].value.element!).to(equal(CharacterDetailsViewModel.State.localDataAvailable(data: FakeDataProvider.provideComicsList())))
            }
            
            it("state should be fetching->noDataAvailable with a list of comics if remoteDataFormApi is not available and data is not cached before") {
                
                let remoteDataSource = FailedRemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let character = FakeDataProvider.provideCharactersList().first!
                let vm = CharacterDetailsViewModel(dataSource: dataSource, character: character)
                let observer = testScheduler.createObserver(CharacterDetailsViewModel.State.self)
                _ = vm.state.subscribe(observer)
                testScheduler.start()
                
                expect(observer.events[0].value.element!).to(equal(CharacterDetailsViewModel.State.fetching))
                expect(observer.events[1].value.element!).to(equal(CharacterDetailsViewModel.State.noDataAvailable))
            }
        }
    }
}
