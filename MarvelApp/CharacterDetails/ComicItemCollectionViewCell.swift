//
//  ComicItemCollectionViewCell.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/24/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import UIKit

class ComicItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var comic: Comic! {
        didSet {
            imageView.loadFromURL(comic.thumbnail ?? " ")
            label.text = comic.title ?? " "
        }
    }
}
