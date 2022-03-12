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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
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
        if(images.count > 1) {
            return 1
        }else {
            // もしも画像がない場合はセクションを表示しない
            return 0
        }
        
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
        return images[indexPath.row].size.height/10
    }
}
