//
//  ServiceFactory.swift
//  MarvelApp
//
//  Created by Mostafa Abdellateef on 2/24/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import RealmSwift

class ServiceFactory {
    static let sharedInstance = ServiceFactory()
    
    let remoteDataSource: DataSource
    let dao: DAO
    let localDataSource: DataSource
    let dataSource : DataSource
    
    private init() {
        remoteDataSource = RemoteDataSource()
        dao = DAOImpl(realm: try! Realm())
        localDataSource = LocalDataSource(dao: dao)
        dataSource = DataSourceImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource, dao: dao)
    }
}
