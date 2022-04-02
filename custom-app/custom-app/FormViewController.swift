//
//  FormViewController.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/11.
//

import UIKit
import opencv2
import PDFKit

class FormViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    // セルの高さ
    let cellHeight: CGFloat = 300
    
    // ノートのタイトル
    var noteTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isEditing = false
        
        textField.delegate = self
        
        saveButton.isEnabled = false
    }
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet var overlayView: UIView!
    
    let imagePicker = UIImagePickerController()
    
    /**
     画面タップ時
     */
    @IBAction func tapGestureRecognizer(_ sender: Any) {
        noteTitle = textField.text
        textField.resignFirstResponder()
        if(noteTitle?.count != 0) {
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
    }
    
    /**
     カメラボタンタップ時
     */
    @IBAction func onTappedCameraButton(_ sender: Any) {
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
    
    /**
     カメラの撮影終了ボタンタップ時
     */
    @IBAction func onTappedFininshButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     編集ボタンタップ時
     */
    @IBAction func onTappedEditButton(_ sender: UIButton) {
        tableView.isEditing = !tableView.isEditing
        if(tableView.isEditing) {
            sender.setTitle("DONE", for: .normal)
        }else {
            sender.setTitle("EDIT", for: .normal)
        }
    }
    
    /**
     終了ボタンタップ時
     */
    @IBAction func onTappedExitButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     保存ボタンタップ時
     */
    @IBAction func onTappedSaveButton(_ sender: Any) {
        
        let pdfDocument: PDFDocument = PDFDocument()
        
        var index = 0
        images.forEach({ image in
            guard let page = PDFPage(image: image) else {
                fatalError()
            }
            pdfDocument.insert(page, at: index)
            index += 1
        })
        
        guard let title = noteTitle else {
            fatalError()
        }
        
        // ノートのエンティティ
        
        guard let pdfDocumentData = pdfDocument.dataRepresentation() else {
            fatalError("pdfDocument data representation is failed")
        }
        
        let noteEntity = NoteEntity(id: UUID(), title: title, pdfDocumentData: pdfDocumentData, updateDate: Date())
        
        // ノートの保存
        NoteEntityController().insert(entity: noteEntity)
        
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
        
        //TODO: 保存ボタンを押したときに表示はしないようにする？
        // 少なくともaddSubViewではない
        let pdfView: PDFView = PDFView(frame: self.view.bounds)
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pdfView)
        
    }
}

// MARK: UIImagePickerControllerDelegate

extension FormViewController: UIImagePickerControllerDelegate {
    
    /**
     撮影完了時のimage
     @param pickerイメージピッカービュー
     @param didFinishPickingMediaWithInfo 撮影後情報
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            fatalError()
        }
        
        let rotatedImage = ImageProcessor.rotate(image: image)
        
        let cannyImage = ImageProcessor.canny(image: rotatedImage)
        
        let binarizedImage = ImageProcessor.binarize(image: rotatedImage)
        
        // 輪郭検出
        let result = ImageProcessor.findContours(from: Mat(uiImage: binarizedImage))
        let perspectiveMat = result.perspectiveMat
        let width = result.width
        let height = result.height
        
        // 透視変換を行う
        let transformedPerspectiveImage = ImageProcessor.transformPerspective(from: rotatedImage, with: perspectiveMat,width: width, height: height)
        // カットする
//        let cornours = ImageProcessor.cutByContours(from: binarizedImage,origin: rotatedImage, by: contours, maxAreaIndex: maxAreaIndex)
        
        let adjustColorImage = ImageProcessor.adjustColor(image: transformedPerspectiveImage, alpha: 1.9, beta: 0)
        
        // 撮影した画像を追加する
//        images.append(binarizedImage)
//        images.append(cornours)
        images.append(adjustColorImage)
        images.append(transformedPerspectiveImage)
        // 表示の更新のためテーブルビューを更新する
        self.tableView.reloadData()
    }
}

// MARK: UITableViewDelegateMethod

extension FormViewController: UITableViewDelegate, UITableViewDataSource {
    
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

extension FormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        noteTitle = textField.text
        textField.resignFirstResponder()
        if(noteTitle?.count != 0){
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
        return true
    }
}
