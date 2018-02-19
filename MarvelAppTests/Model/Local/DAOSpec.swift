//
//  DAOSpec.swift
//  MarvelAppTests
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RealmSwift

@testable import MarvelApp

class DAOSpec : QuickSpec {
    override func spec() {
        describe("DAO Class") {
            var testRealm: Realm!
            var dao: DAO!
            
            beforeEach{
                // Use an in-memory Realm identified by the name of the current test.
                // This ensures that each test can't accidentally access or modify the data
                // from other tests or the application itself, and because they're in-memory,
                // there's nothing that needs to be cleaned up.
                Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
                testRealm = try! Realm()
                dao = DAOImpl(realm: testRealm)
            }
            
            afterEach {
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
            describe("Handling Characters") {
                it("should store list of characters if no characters are stored before") {
                    let characters = FakeDataProvider.provideCharactersList(count: 20)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    let storedCharacters = testRealm.objects(Character_Realm.self).map{
                        $0.toCharacter()
                    }
                    expect(storedCharacters.count).to(equal(characters.count))
                    storedCharacters.enumerated().forEach {
                        expect($0.element).to(equal(characters[$0.offset]))
                    }
                }
                
                it("should append list of characters if not stored before") {
                    let characters = FakeDataProvider.provideCharactersList(count: 20)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    let charactersPatch2 = FakeDataProvider.provideCharactersList(startIndex: 21, count: 10)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    dao.addNewOrUpdateExistingCharacters(charactersPatch2)
                    let storedCharacters = testRealm.objects(Character_Realm.self).map{
                        $0.toCharacter()
                    }
                    expect(storedCharacters.count).to(equal((characters + charactersPatch2).count))
                    storedCharacters.enumerated().forEach {
                        expect($0.element).to(equal((characters + charactersPatch2)[$0.offset]))
                    }
                }
                
                it("should update character while adding characters list if character already exists before") {
                    let characters = FakeDataProvider.provideCharactersList(count: 20)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    let charactersPatch2 = FakeDataProvider.provideCharactersList(startIndex: 10, count: 20)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    dao.addNewOrUpdateExistingCharacters(charactersPatch2)
                    let expectedStoredCharacters = Array(characters[0...9])+charactersPatch2
                    
                    let storedCharacters = testRealm.objects(Character_Realm.self).map{
                        $0.toCharacter()
                    }
                    expect(storedCharacters.count).to(equal(expectedStoredCharacters.count))
                    storedCharacters.enumerated().forEach {
                        expect($0.element).to(equal(expectedStoredCharacters[$0.offset]))
                    }
                }
                
                it("should be able to clear all stored characters") {
                    let characters = FakeDataProvider.provideCharactersList(count: 20)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    dao.clearAllCharacters()
                    let storedCharacters = testRealm.objects(Character_Realm.self).map{
                        $0.toCharacter()
                    }
                    expect(storedCharacters.count).to(equal(0))
                }
                
                it("should get characters at specific offeset and limit") {
                    let characters = FakeDataProvider.provideCharactersList(count: 40)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    
                    let resultCharacters = dao.getCharacters(offset: 10, limit: 20)
                    let expectedCharacters = Array(characters[10...30])
                    expect(resultCharacters.count).to(equal(20))
                    resultCharacters.enumerated().forEach {
                        expect($0.element).to(equal(expectedCharacters[$0.offset]))
                    }
                }
                
                it("should return empty array if offset is not available in stored data") {
                    let characters = FakeDataProvider.provideCharactersList(count: 40)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    let resultCharacters = dao.getCharacters(offset: 60, limit: 20)
                    expect(resultCharacters.count).to(equal(0))
                }
                
                it("should return available data if limit exceeds stored characters size") {
                    let characters = FakeDataProvider.provideCharactersList(count: 40)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    
                    let resultCharacters = dao.getCharacters(offset: 30, limit: 20)
                    let expectedCharacters = Array(characters[30...39])
                    expect(resultCharacters.count).to(equal(10))
                    resultCharacters.enumerated().forEach {
                        expect($0.element).to(equal(expectedCharacters[$0.offset]))
                    }
                }
                
                it("Should get specific character by it's ID") {
                    let characters = FakeDataProvider.provideCharactersList(count: 20)
                    dao.addNewOrUpdateExistingCharacters(characters)
                    
                    let resultCharacter = dao.getCharacter(withID: characters[10].id!)
                    let expectedCharacter = characters[10]
                    expect(expectedCharacter).to(equal(resultCharacter))
                }
            }
            
            describe("Handling Comics") {
                it("shuould store and retreive comics for specific character") {
                    let characters = FakeDataProvider.provideCharactersList(count: 3)
                    characters.enumerated().forEach {
                        let comics = FakeDataProvider.provideComicsList(startIndex: $0.offset + 5, count: 5)
                        dao.setComics(comics, forCharacterWithID: $0.element.id!)
                    }
                    
                    characters.enumerated().forEach{
                        let expectedComics = FakeDataProvider.provideComicsList(startIndex: $0.offset + 5, count: 5)
                        let resultComics = dao.getComicsForCharacter(withID: $0.element.id ?? 0)
                        expect(resultComics.count).to(equal(expectedComics.count))
                        resultComics.enumerated().forEach {
                            expect(expectedComics[$0.offset]).to(equal($0.element))
                        }
                    }
                }
                
                it("should retrun empty array if character doesn't have any comics stored") {
                    let character = FakeDataProvider.provideCharactersList(count: 3).first!
                    let result = dao.getComicsForCharacter(withID: character.id!)
                    expect(result.count).to(equal(0))
                }
                
                it("shoudl override comics for character if setted more than one time") {
                    let characters = FakeDataProvider.provideCharactersList(count: 3)
                    characters.enumerated().forEach {
                        let comics = FakeDataProvider.provideComicsList(startIndex: $0.offset + 5, count: 5)
                        dao.setComics(comics, forCharacterWithID: $0.element.id!)
                        dao.setComics(comics, forCharacterWithID: $0.element.id!)
                    }
                    
                    characters.enumerated().forEach{
                        let expectedComics = FakeDataProvider.provideComicsList(startIndex: $0.offset + 5, count: 5)
                        let resultComics = dao.getComicsForCharacter(withID: $0.element.id ?? 0)
                        expect(resultComics.count).to(equal(expectedComics.count))
                        resultComics.enumerated().forEach {
                            expect(expectedComics[$0.offset]).to(equal($0.element))
                        }
                    }
                }
            }
            
        }
    }
}
