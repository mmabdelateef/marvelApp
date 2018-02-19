//
//  HomeViewController.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    private var characters = [Character]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    private var viewModel: HomeViewModel!
    private let disposeBag = DisposeBag()
    
    init(homeViewModel: HomeViewModel){
        self.viewModel = homeViewModel
        super.init(nibName: "HomeViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        bindVM()
        viewModel.requestNewPage()
    }
    
    func bindVM() {
        viewModel.state.subscribe(onNext: {
            switch $0 {
            case .localDataAvailable(let data), .remoteDataAvailable(let data):
                self.characters += data
                self.tableView.isHidden = false
            default: break
            }
        }).disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell : CharacterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CharacterTableViewCell
            cell.character = characters[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == characters.count - 5 {
            viewModel.requestNewPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.present(Coordinator.sharedInstance.provideCharacterDetailsViewController(character: characters[indexPath.row]),
                     animated: true)
    }
}
