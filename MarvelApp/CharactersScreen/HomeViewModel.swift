//
//  HomeViewModel.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/23/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel {
    
    private let dataSource : DataSource
    private let stateVariable = Variable<State>(.fetching)
    private let disposeBag = DisposeBag()
    private var currentPage = 0
    var state: Observable<State> {
        return stateVariable.asObservable()
    }
    private let pageLimit = 20
    
    init(dataSource : DataSource) {
        self.dataSource = dataSource
    }
    
    func requestNewPage() {
        dataSource.getCharactersList(offset: currentPage * pageLimit , limit: pageLimit).subscribe(onNext: {
            guard $0.data.count > 0 else {
                self.stateVariable.value = .noDataAvailable
                return
            }
            self.currentPage += 1
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
        case localDataAvailable(data: [Character])
        case remoteDataAvailable(data: [Character])
        case noDataAvailable
        
        static func == (lhs: HomeViewModel.State, rhs: HomeViewModel.State) -> Bool {
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
