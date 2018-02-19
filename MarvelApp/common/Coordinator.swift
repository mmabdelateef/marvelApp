//
//  Coordinator.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/24/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation


class Coordinator {
    
    static let sharedInstance = Coordinator()
    private init () {}
    
    func provideHomeViewController() -> HomeViewController{
        let homeScreenVM = HomeViewModel(dataSource: ServiceFactory.sharedInstance.dataSource)
        return HomeViewController(homeViewModel: homeScreenVM)
    }
    
    func provideCharacterDetailsViewController(character: Character) -> CharacterDetailsViewController {
        let vm = CharacterDetailsViewModel(dataSource: ServiceFactory.sharedInstance.dataSource, character: character)
        let vc = CharacterDetailsViewController(viewModel: vm)
        vc.modalTransitionStyle = .crossDissolve
        return vc
    }
}
