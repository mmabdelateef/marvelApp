//
//  RemoteDataSourceSpec.swift
//  MarvelAppTests
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxBlocking
@testable import MarvelApp
class RemoteDataSourceSpec: QuickSpec {
    
    override func spec() {
        
        describe("RemoteDataSource Integration with Marvel API") {
            
            var character : MarvelApp.Character? = nil

            it("should recieve response for a list of charachters") {
                let result = RemoteDataSource().getCharactersList(offset: 0, limit: 5).toBlocking().materialize()
                switch result {
                case .completed(let elements):
                    expect(elements.first?.data.count).to(equal(5))
                    elements.first?.data.forEach {
                        expect($0.id).notTo(beNil())
                        expect($0.description).notTo(beNil())
                        expect($0.name).notTo(beNil())
                        expect($0.thumbnailURL).notTo(beNil())
                    }
                    character = elements.first?.data.last
                case .failed(_, let error):
                    XCTFail("Expected result to complete without error, but received \(error).")
                }
                
                let antherResult = RemoteDataSource().getCharactersList(offset: 4, limit: 10).toBlocking().materialize()
                switch antherResult {
                case .completed(let elements):
                    expect(elements.first?.data.count).to(equal(10))
                    expect(elements.first?.data.first).to(equal(character))
                case .failed(_, let error):
                    XCTFail("Expected result to complete without error, but received \(error).")
                }
            }
            
            it("should receive character details") {
                let result = RemoteDataSource().getCharacterDetails(characterId: character?.id ?? 0).toBlocking().materialize()
                switch result {
                case .completed(let elements):
                        expect(elements.first?.data.id).notTo(beNil())
                        expect(elements.first?.data.description).notTo(beNil())
                        expect(elements.first?.data.name).notTo(beNil())
                        expect(elements.first?.data.thumbnailURL).notTo(beNil())
                case .failed(_, let error):
                    XCTFail("Expected result to complete without error, but received \(error).")
                }
            }
            
            it("should receive comics list for a specific character") {
                let result = RemoteDataSource().getComics(characterId: character?.id ?? -1).toBlocking().materialize()
                switch result {
                case .completed(let elements):
                    elements.first?.data.forEach {
                        expect($0.title).notTo(beNil())
                        expect($0.thumbnail).notTo(beNil())
                    }
                case .failed(_, let error):
                    XCTFail("Expected result to complete without error, but received \(error).")
                }
            }
        }
    }
    
    
}

