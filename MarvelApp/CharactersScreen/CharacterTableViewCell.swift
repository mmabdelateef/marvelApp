//
//  CharacterTableViewCell.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    private let layerGradient = CAGradientLayer()
    
    var character: Character! {
        didSet{
            backgroundImageView.loadFromURL(character.thumbnailURL ?? "")
            titleLabel.text = character.name ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundImageView.clipsToBounds = true
//        self.backgroundImageView.layer.addSublayer(layerGradient)
        layerGradient.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
        layerGradient.startPoint = CGPoint(x: 0.5, y: 0)
        layerGradient.endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layerGradient.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
}
