//
//  Entity.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/19.
//

import Foundation

protocol Entity {
    var entityName: String {get set}
    var attributes: Dictionary<String,Any> {get set}
    func insert()
    static func fetchAll() -> [Entity]
    func fetchById(_ id: UUID) -> Entity
}
