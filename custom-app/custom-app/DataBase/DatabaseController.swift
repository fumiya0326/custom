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
     永続コンテナ
     */
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /**
     Contextを保存
     */
    func saveContext() {
        let context = persistentContainer.viewContext
        do {
            try context.save()
        } catch {
           fatalError("\(error)")
        }
    }
    
    /*
     DBに保存
     @param entity エンティティ
     */
    func insert(entity: Entity) {
        let managedObjectContext = persistentContainer.viewContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entity.entityName, in: managedObjectContext) else {
            fatalError()
        }
        
        let managedObject = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        
        // 属性の値をセットする
        entity.attributes.forEach({ key, value in
            managedObject.setValue(value, forKey: key)
        })
        
        // Contextを保存
        saveContext()
    }
    
    /**
     DBから取得
     @param entity エンティティ
     @return 取得したオブジェクトの配列
     */
    func fetch(_ entityName: String, with condition: String?) -> [NSManagedObject] {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if(condition == nil) {
            // 何もしない
        } else {
            fetchRequest.predicate = NSPredicate(format: condition!)
        }
        
        do {
            let managedObjects = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            return managedObjects
        } catch {
            fatalError()
        }
    }

    
    /**
     条件で削除する
     @param entityName エンティティの名前
     @param condition 条件式
     */
    func deleteWith(_ entityName: String,condition: String?){
        let managedObjects = fetch(entityName, with: condition)
        let managedObjectContext = persistentContainer.viewContext
        managedObjects.forEach({ managedObject in
            managedObjectContext.delete(managedObject)
        })
        saveContext()
    }
}
