//
//  FormViewController.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/11.
//

import UIKit

class FormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                          UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editButton: UIButton!
    
    // セルの高さ
    let cellHeight: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isEditing = true
    }
    
    @IBOutlet var overlayView: UIView!
    
    let imagePicker = UIImagePickerController()
    
    /**
     カメラボタンタップ時
     */
    @IBAction func onTappedCameraButton(_ sender: Any) {
        print("onTappedCamera")
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            overlayView.frame = (imagePicker.cameraOverlayView?.frame)!
            imagePicker.cameraOverlayView = overlayView
            imagePicker.showsCameraControls = false
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            fatalError()
        }
    }
    
    // 撮影画像一覧
    var images: [UIImage] = []
    
    
    /**
     撮影ボタンタップ時
     */
    @IBAction func onTappedtakePicture(_ sender: Any) {
        imagePicker.takePicture()
    }
    
    @IBAction func onTappedFininshButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTappedEditButton(_ sender: UIButton) {
        tableView.isEditing = !tableView.isEditing
        if(tableView.isEditing) {
            sender.setTitle("Done", for: .normal)
            print("DONE")
        }else {
            sender.setTitle("Edit", for: .normal)
            print("Edit")
        }
    }
    
    @IBAction func onTappedExitButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    /**
     撮影完了時のimage
     @param pickerイメージピッカービュー
     @param didFinishPickingMediaWithInfo 撮影後情報
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            fatalError()
        }
        
        // 撮影した画像を追加する
        images.append(image)
        
        // 表示の更新のためテーブルビューを更新する
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDelegateMethod
    
    /**
     セル設定のdelegateメソッド
     @param tableView テーブルビュー
     @param cellForRowAt セルの位置
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
        
        cell.photoView.image = images[indexPath.row]
        
        return cell
    }
    
    /**
     セクション数
     @param in テーブルビュー
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     セクションの列数
     @param tableView テーブルビュー
     @param numberOfRowsInSection セクションの位置
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    /**
     セルの高さ
     @param tableView テーブルビュー
     @param heightForRowAt セルの位置
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    /**
     編集可能状態
     @param tableView テーブルビュー
     @param canEditRowAt セルの位置
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // テーブルビューの編集状態を許可
        return true
    }
    
    /**
     セルの編集
     @param tableView テーブルビュー
     @param commit 編集スタイル
     @param forRowAt セルの位置
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        images.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        
    }
    
    /**
     セルの移動可否
     @param tableView テーブルビュー
     @param canMoveRowAt 移動可能なセルの位置
     */
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     セルの移動を管理
     @param tableView テーブルビュー
     @param sourceIndexPath 移動前のセルの位置
     @param destinationIndexPath 移動先のセルの位置
     */
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let image = images[sourceIndexPath.row]
        images.remove(at: sourceIndexPath.row)
        images.insert(image, at: destinationIndexPath.row)
    }
    
    /**
     セルの編集スタイルを設定
     @param tableView テーブルビュー
     @param editingStyleForRowAt 編集スタイル
     */
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}
