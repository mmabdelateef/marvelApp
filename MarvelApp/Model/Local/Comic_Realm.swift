//
//  Comic_Realm.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RealmSwift

class Comic_Realm : Object{
    @objc dynamic var title: String?
    @objc dynamic var thumbnail: String?
    @objc dynamic var characterID = 0
    
    convenience init(comic: Comic) {
        self.init()
        self.title = comic.title
        self.thumbnail = comic.thumbnail
    }
    
    func toComic() -> Comic {
        return Comic(title: self.title, thumbnail: self.thumbnail)
    }
}
