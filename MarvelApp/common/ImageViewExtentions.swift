//
//  ImageViewExtentions.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/24/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func loadFromURL(_ _url: String) {
        let url = URL(string: _url)!
        self.kf.indicatorType = .activity
        self.kf.setImage(with: ImageResource(downloadURL: url), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
    }
}
