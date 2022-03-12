//
//  HabitationCollectionViewCell.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/05.
//

import UIKit

class HabitationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dueTimeLabel: UILabel!
    
    @IBOutlet weak var titleLable: UILabel!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 10
    }
}
