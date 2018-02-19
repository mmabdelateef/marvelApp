//
//  FakeDataProvider.swift
//  MarvelAppTests
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation

@testable import MarvelApp

class FakeDataProvider {
    static func provideCharactersList(startIndex: Int = 0, count: Int = 10) -> [MarvelApp.Character]{
        return (startIndex...startIndex+count-1).map {
            MarvelApp.Character(id: $0, name: "NAME \($0)", thumbnailURL: "THUMBNAIL_URL \($0)", description: "DESCRIPTION \($0)")
        }
    }
    
    static func provideComicsList(startIndex: Int = 0, count: Int = 10) -> [Comic]{
        return (startIndex...startIndex+count-1).map {
            Comic(title: "TITLE \($0)", thumbnail: "THUBNAIL_URL \($0)")
        }
    }
}
