//
//  DatabaseController.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/04.
//

import Foundation
import CoreData

class DatabaseController {
    /**
     管理するコンテナ
     */
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "HitList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
