//
//  CharacterDetailsViewModel.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/24/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RxSwift

class CharacterDetailsViewModel {
    
    let character: Character
    private let dataSource: DataSource
    private let stateVariable = Variable<State>(.fetching)
    private let disposeBag = DisposeBag()
    private var currentPage = 0
    var state: Observable<State> {
        return stateVariable.asObservable()
    }
    
    init(dataSource: DataSource, character: Character) {
        self.character = character
        self.dataSource = dataSource
        getComics()
    }
    
    func getComics(){
        dataSource.getComics(characterId: character.id ?? 0).subscribe(onNext: {
            guard $0.data.count > 0 else {
                self.stateVariable.value = .noDataAvailable
                return
            }
            
            switch $0.source {
            case .local:
                self.stateVariable.value = .localDataAvailable(data: $0.data)
            case .remote:
                self.stateVariable.value = .remoteDataAvailable(data: $0.data)
            }
        }).disposed(by: disposeBag)
    }
    
    enum State: Equatable {
        case fetching
        case localDataAvailable(data: [Comic])
        case remoteDataAvailable(data: [Comic])
        case noDataAvailable
        
        static func ==(lhs: CharacterDetailsViewModel.State, rhs: CharacterDetailsViewModel.State) -> Bool {
            switch (lhs,rhs) {
            case (.fetching,.fetching): return true
            case (.localDataAvailable(let lhsData), .localDataAvailable(let rhsData)) where lhsData == rhsData: return true
            case (.remoteDataAvailable(let lhsData), .remoteDataAvailable(let rhsData)) where lhsData == rhsData: return true
            case (.noDataAvailable,.noDataAvailable): return true
            default: return false
            }
        }
    }
}
