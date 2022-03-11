//
//  FormViewController.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/11.
//

import UIKit

class FormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    /**
     カメラボタンタップ時
     */
    @IBAction func onTappedCameraButton(_ sender: Any) {
        print("onTappedCamera")
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            fatalError()
        }
    }
    
    
    /**
     撮影完了時
     @param pickerイメージピッカービュー
     @param didFinishPickingMediaWithInfo 撮影後情報
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            fatalError()
        }
    
        
    
    }
    
}
