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
        // デリゲートの設定
        habitationCollectionView.delegate = self
        // データソースの設定
        habitationCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        // TODO: マージンの値を設定
        layout.sectionInset = UIEdgeInsets(top: 10, left: sideMargin, bottom: 10, right: sideMargin)
        
        // TODO: スペースの値を適切に設定
        layout.minimumLineSpacing = 10
        
        habitationCollectionView.collectionViewLayout = layout
        
    }
    
    // 両サイドのマージン
    let sideMargin: CGFloat = 25
    // 一列あたりのアイテム数
    let itemPerWidth: CGFloat = 2
    // アイテム間のスペース
    let spaceBetweenItem: CGFloat = 10
    // 一行あたりのアイテム数
    let itemPerHeight: CGFloat = 4
    
    
    
    @IBOutlet weak var habitationCollectionView: UICollectionView!
    
    // TODO: DB用意する
    // 仮のデータ
    var TODO: [String] = ["a", "b", "c"]
    

    /**
     セルの設定
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "habitationCell", for: indexPath) as! HabitationCollectionViewCell
        cell.dueTimeLabel.text = "6:00"
        cell.titleLable.text = TODO[indexPath.row]
        return cell
    }
    
    /**
     セクションあたりのItem数
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TODO.count
    }
    
    /**
     選択時
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    /**
     編集可否
     */
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     セクション数
     */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     変更可否
     */
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     item変更
     */
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tmpTODO = TODO.remove(at: sourceIndexPath.row)
        TODO.insert(tmpTODO, at: destinationIndexPath.row)
    }
    
    

}

// コレクションビューのレイアウトを設定する
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    /**
     アイテムのサイズ
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = (view.frame.width - sideMargin * 2) - spaceBetweenItem * (itemPerWidth-1)
        let width = availableWidth / itemPerWidth
        
        let availableHeight = (view.frame.height - sideMargin * 2) - spaceBetweenItem * (itemPerHeight-1)
        let height = availableHeight / itemPerHeight
        
        return CGSize(width: width, height: height)
    }

}

