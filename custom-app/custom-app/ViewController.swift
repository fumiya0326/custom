//
//  ViewController.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/04.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    /**
     ビュー描画終了時
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        habitationCollectionView.delegate = self
        habitationCollectionView.dataSource = self
    }
    
    @IBOutlet weak var habitationCollectionView: UICollectionView!
    // 仮のデータ
    var TODO: [String] = ["a", "b", "c"]
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "habitationCell", for: indexPath) as! HabitationCollectionViewCell
        cell.dueTimeLabel.text = "6:00"
        cell.titleLable.text = TODO[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TODO.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tmpTODO = TODO.remove(at: sourceIndexPath.row)
        TODO.insert(tmpTODO, at: destinationIndexPath.row)
    }
    
    

}

