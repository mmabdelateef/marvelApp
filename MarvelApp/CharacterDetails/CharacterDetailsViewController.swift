//
//  CharacterDetailsViewController.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/24/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import UIKit
import RxSwift

class CharacterDetailsViewController: BaseViewController {

    @IBOutlet var characterImageViews: [UIImageView]!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var comcisCollectionView: UICollectionView!
    @IBOutlet weak var comicsLabel: UILabel!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionTitleLabel: UILabel!
    private let disposeBag = DisposeBag()
    private var viewModel: CharacterDetailsViewModel!
    private var comics = [Comic]() {
        didSet {
            if comics.count > 0 {
                comicsLabel.isHidden = false
                comcisCollectionView.isHidden = false
                collectionViewHeightConstraint.constant = 210
            }
            comcisCollectionView.reloadData()
        }
    }
    
    init(viewModel: CharacterDetailsViewModel) {
        super.init(nibName: "CharacterDetailsViewController", bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindVM()
    }
    
    func configureUI(){
        characterImageViews.forEach {
            $0.loadFromURL(self.viewModel.character.thumbnailURL ?? " " )
        }
        nameLabel.text = viewModel.character.name
        descriptionLabel.text = viewModel.character.description
        descriptionTitleLabel.isHidden = viewModel.character.description?.count ?? 0 < 1
        
        collectionViewHeightConstraint.constant = 0
        
        mainContainerView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.mainContainerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainContainerView.insertSubview(blurEffectView, at: 0)
        
        comcisCollectionView.register(UINib(nibName: "ComicItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "comicCell")
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 130, height: 210)
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        comcisCollectionView.collectionViewLayout = flowLayout
    }
    
    func bindVM() {
        viewModel.state.subscribe(onNext: {
            switch $0 {
            case .localDataAvailable(let data), .remoteDataAvailable(let data):
                self.comics = data
            default: break
            }
        }).disposed(by: disposeBag)
    }
    
    @IBAction func backClicked() {
        self.dismiss(animated: true)
    }
}

extension CharacterDetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ComicItemCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "comicCell", for: indexPath) as! ComicItemCollectionViewCell
        cell.comic = comics[indexPath.row]
        return cell
    }
}
