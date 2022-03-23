//
//  Entity.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/19.
//

import Foundation

protocol EntityConroller {
    var entityName: String {get set}
    func insert(entity:Entity)
    static func fetchAll() -> [Entity]
    func fetchById(_ id: UUID) -> Entity
}
