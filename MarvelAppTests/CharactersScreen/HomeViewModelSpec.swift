//
//  HomeViewModelSpec.swift
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

class HomeViewModelSpec : QuickSpec {
    override func spec() {
        describe("HomeViewModel Class") {
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
            
            it("state should be fetching->remoteDataAvailable with a list of characters if remoteDataFormApi is available") {
                let remoteDataSource = RemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let vm = HomeViewModel(dataSource: dataSource)
                let observer = testScheduler.createObserver(HomeViewModel.State.self)
                _ = vm.state.subscribe(observer)
                testScheduler.scheduleAt(100, action: {
                    vm.requestNewPage()
                })
                testScheduler.start()
                
                expect(observer.events[0].value.element!).to(equal(HomeViewModel.State.fetching))
                expect(observer.events[1].value.element!).to(equal(HomeViewModel.State.remoteDataAvailable(data: FakeDataProvider.provideCharactersList(startIndex: 0, count: 20))))
            }
            
            it("should be able to request new page of characters if needed") {
                let remoteDataSource = RemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let vm = HomeViewModel(dataSource: dataSource)
                let observer = testScheduler.createObserver(HomeViewModel.State.self)
                _ = vm.state.subscribe(observer)
                testScheduler.scheduleAt(100, action: {
                    vm.requestNewPage()
                })
                testScheduler.scheduleAt(200, action: {
                    vm.requestNewPage()
                })
                testScheduler.start()
                
                expect(observer.events[0].value.element!).to(equal(HomeViewModel.State.fetching))
                expect(observer.events[1].value.element!).to(equal(HomeViewModel.State.remoteDataAvailable(data: FakeDataProvider.provideCharactersList(startIndex: 0, count: 20))))
                expect(observer.events[2].value.element!).to(equal(HomeViewModel.State.remoteDataAvailable(data: FakeDataProvider.provideCharactersList(startIndex: 20, count: 20))))
            }
            
            
            it("state should be fetching->localDataAvailable with a list of characters if remoteDataFormApi is not available and data is already cached before") {
                
                let remoteDataSource = FailedRemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                dao.addNewOrUpdateExistingCharacters(FakeDataProvider.provideCharactersList())
                let vm = HomeViewModel(dataSource: dataSource)
                let observer = testScheduler.createObserver(HomeViewModel.State.self)
                _ = vm.state.subscribe(observer)
                testScheduler.scheduleAt(100, action: {
                    vm.requestNewPage()
                })
                testScheduler.start()
                expect(observer.events[0].value.element!).to(equal(HomeViewModel.State.fetching))
                expect(observer.events[1].value.element!).to(equal(HomeViewModel.State.localDataAvailable(data: FakeDataProvider.provideCharactersList())))
            }
            
            it("state should be fetching->noDataAvailable with a list of characters if remoteDataFormApi is not available and data is not cached before") {
                
                let remoteDataSource = FailedRemotDataSourceMock(scheduler: testScheduler)
                let localDataSource = LocalDataSource(dao: dao)
                let dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
                let vm = HomeViewModel(dataSource: dataSource)
                let observer = testScheduler.createObserver(HomeViewModel.State.self)
                _ = vm.state.subscribe(observer)
                testScheduler.scheduleAt(100, action: {
                    vm.requestNewPage()
                })
                testScheduler.start()
                expect(observer.events[0].value.element!).to(equal(HomeViewModel.State.fetching))
                expect(observer.events[1].value.element!).to(equal(HomeViewModel.State.noDataAvailable))
            }
        }
    }
}
