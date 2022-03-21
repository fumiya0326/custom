//
//  ViewController.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/04.
//

import UIKit
import PDFKit

class ViewController: UIViewController {
    
    /**
     ビュー描画終了時
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        noteCollectionView.delegate = self
        // データソースの設定
        noteCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        // TODO: マージンの値を設定
        layout.sectionInset = UIEdgeInsets(top: 10, left: sideMargin, bottom: 10, right: sideMargin)
        
        // TODO: スペースの値を適切に設定
        layout.minimumLineSpacing = 10
        
        noteCollectionView.collectionViewLayout = layout
        
        // 編集ボタンを設定
        navigationItem.leftBarButtonItem = editButtonItem
        
        // タイトルを設定
        navigationItem.title = "一覧"
        
        // イベントリスナーの登録
        addEventListener()
        
        // 複数選択を可能に
        self.noteCollectionView.allowsMultipleSelection = true
        
        // DBからデータ取得
        Notes = NoteEntity.fetchAll() as! [NoteEntity]
        
    }
    
    /**
     ビュー表示時
     */
    override func viewWillAppear(_ animated: Bool) {
        // DBから更新する
        Notes = NoteEntity.fetchAll() as! [NoteEntity]
        noteCollectionView.reloadData()
    }
    
    // ノート
    var Notes: [NoteEntity] = []
    
    // 両サイドのマージン
    let sideMargin: CGFloat = 25
    // 一列あたりのアイテム数
    let itemPerWidth: CGFloat = 2
    // アイテム間のスペース
    let spaceBetweenItem: CGFloat = 10
    // 一行あたりのアイテム数
    let itemPerHeight: CGFloat = 2
    
    
    
    
    @IBAction func onTapAddButton(_ sender: Any) {
        let storyBoard: UIStoryboard = self.storyboard!
        let nextView = storyBoard.instantiateViewController(withIdentifier: "formView")
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: true, completion: nil)
    }
    
    /**
     編集状態を管理
     @params editing 編集状態
     @params animated アニメーション
     */
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        noteCollectionView.isEditing = editing
    }
    
    //MARK: Gesture
    
    /**
     イベントリスナ
     */
    private func addEventListener() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        noteCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    /**
     ロングタップ時のジェスチャーを制御する
     @params gesture UILongPressGestureRecognizer
     */
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer){
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = noteCollectionView.indexPathForItem(at: gesture.location(in: noteCollectionView)) else {
                break
            }
            noteCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            noteCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
        case .ended:
            noteCollectionView.endInteractiveMovement()
        default:
            noteCollectionView.cancelInteractiveMovement()
        }
    }
    
    
    @IBOutlet weak var noteCollectionView: UICollectionView!
    
    let noteCellReuseIdentifier = "NoteCell"

}

// MARK: UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /**
     セルの設定を行うcollectionviewのdelegateメソッド
     @params collectionView コレクションビュー
     @paarms cellForItemAt アイテムのインデックス
     @returns セル
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noteCellReuseIdentifier, for: indexPath) as! NoteCollectionViewCell
        let note = Notes[indexPath.row]
        
        let pdfDocument = PDFDocument.init(data: note.pdfDocumentData)
        
        guard let pdfPage = pdfDocument?.page(at: 0) else {
            fatalError()
        }
        
        let thumbnailView = pdfPage.thumbnail(of: CGSize(width: cell.preViewImage.bounds.width, height: cell.preViewImage.bounds.height), for: .trimBox)
        cell.preViewImage.image = thumbnailView
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        cell.dueTimeLabel.text = dateFormatter.string(from: note.updateDate)
        cell.titleLable.text = note.title
        return cell
    }
    
    /**
     セクションあたりのItem数
     @params collectionView コレクションビュー
     @paarms numberOfItemsInSection セクションのアイテム数
     @returns アイテム数
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Notes.count
    }
    
    /**
     選択時のdelegateメソッド
     @params collectionView コレクションビュー
     @paarms didSelectItemAt 選択されたアイテムのインデックス
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedNote = Notes[indexPath.row]
        let storyBoard: UIStoryboard = self.storyboard!
        let noteView = storyBoard.instantiateViewController(withIdentifier: "NoteView") as! NoteViewController
        
        noteView.noteEntity = selectedNote
        
        navigationController?.pushViewController(noteView, animated: true)
    }
    
    
    /**
     編集可否のdelegateメソッド
     @params collectionView コレクションビュー
     @paarms canEditItemAt  編集可能なアイテムのインデックス
     */
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     セクション数を表すdelegateメソッド
     @params collectionView コレクションビュー
     @returns サクション数
     */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     変更可否
     @params collectionView コレクションビュー
     @paarms canMoveItemAt  移動可能なアイテムのインデックス
     */
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     item変更
     @params collectionView コレクションビュー
     @paarms moveItemAt  移動するアイテムのインデックス
     */
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tmpNotes = Notes.remove(at: sourceIndexPath.row)
        Notes.insert(tmpNotes, at: destinationIndexPath.row)
    }
    
    
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    /**
     アイテムのサイズを指定するdelegateメソッド
     @params collectionView コレクションビュー
     @paarms layout レイアウト
     @params sizeForItemAt サイズを指定するアイテムのインデックス
     @returns セルのサイズ
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = (view.frame.width - sideMargin * 2) - spaceBetweenItem * (itemPerWidth-1)
        let width = availableWidth / itemPerWidth
        
        let availableHeight = (view.frame.height - sideMargin * 2) - spaceBetweenItem * (itemPerHeight-1)
        let height = availableHeight / itemPerHeight
        
        return CGSize(width: width, height: height)
    }
    
}

