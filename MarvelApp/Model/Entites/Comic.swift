//
//  Comic.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/22/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation

struct Comic{
    let title: String?
    let thumbnail: String?
    
    init(title: String?, thumbnail: String?) {
        self.title = title
        self.thumbnail = thumbnail
    }
}

extension Comic: Equatable {
    static func ==(lhs: Comic, rhs: Comic) -> Bool {
        return lhs.title == rhs.title && rhs.thumbnail == rhs.thumbnail
    }
}

extension Comic {
    init(jsonRepresentation: [String:Any]) {
        title = jsonRepresentation["title"] as? String
        thumbnail = {
            guard let thumbnail = jsonRepresentation["thumbnail"] as? [String:String] else {
                return nil
            }
            
            guard let path = thumbnail["path"] else {
                return nil
            }
            
            return "\(path).\(thumbnail["extension"] ?? " ")"
        } ()
    }
}

extension Comic {
    func copyWith(title: String? = nil, thumbnail: String? = nil) -> Comic {
        return Comic(title: title ?? self.title, thumbnail: thumbnail ?? self.thumbnail)
    }
}

