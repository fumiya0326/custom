//
//  CameraViewController.swift
//  custom-app
//
//  Created by ISN98 on 2022/04/02.
//

import UIKit
import AVKit
import opencv2

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.frame = cameraView.bounds
        cameraView.addSubview(previewView)
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: device!)
        
        captureSession.addInput(deviceInput)
        
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "myImageHandling.queue"))
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(videoDataOutput)
        
        captureSession.addOutput(photoDefaultOutput)
        
        videoDataOutput.connections.first?.isCameraIntrinsicMatrixDeliveryEnabled = true
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = previewView.bounds
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewView.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
    
    /**
     プレビューの画像の処理を行うdelegateメソッド
     */
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        let image = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        let rotated = ImageProcessor.rotateClockWise(image: image)
        
        let sharpImage = ImageProcessor.sharp(image: rotated)
        let adjustedColorImage = ImageProcessor.adjustColor(image: sharpImage, alpha: 1.1, beta: 0)
        let drawContoursImage = ImageProcessor.drawContours(image: adjustedColorImage)
        
        DispatchQueue.main.async {
            let imageView = UIImageView(image: drawContoursImage)
            imageView.frame = self.previewView.bounds
            let subviews = self.previewView.subviews
            for subview in subviews {
                subview.removeFromSuperview()
            }
            self.previewView.addSubview(imageView)
        }
    }
    
    /**
    写真撮影時のdelegate
     
     */
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: imageData)!
        let rotatedImage = ImageProcessor.rotateClockWise(image: image)
        images.append(rotatedImage)
        UIImageWriteToSavedPhotosAlbum(rotatedImage, nil, nil, nil)
    }
    
    /**
     撮影ボタンタップ時のハンドラ
     */
    @IBAction func onTappedCaptureButton(_ sender: Any) {
        self.photoDefaultOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
    }
    
    @IBAction func onTappedFinishButton(_ sender: Any) {
        var resultImages: [UIImage] = []
        
        
        self.images.forEach({ image in
            do {
                let binarizedImage = ImageProcessor.binarize(image: image)
                let result = try ImageProcessor.findContours(from: Mat(uiImage: binarizedImage))
                let transformedImage = ImageProcessor.transformPerspective(from: image, with: result.perspectiveMat, width: result.width, height: result.height)
                resultImages.append(transformedImage)
            } catch {
                // 何もしない
            }
        })
        
        if let formViewController = self.presentingViewController as? FormViewController {
            formViewController.images += resultImages
            formViewController.tableView.reloadData()
        }else {
            print("error")
        }
        self.dismiss(animated: true)
    }
    
    var images: [UIImage] = []
    /**
     写真撮影時の処理
     */
    func takePicture(){
        guard videoDataOutput.connection(with: AVMediaType.video) != nil else {
            return
        }
        guard let imageView = self.previewView.subviews.first as? UIImageView else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(imageView.image!, nil, nil, nil)
        images.append(imageView.image!)
        
    }
    
    var captureSession = AVCaptureSession()
    var previewView = UIView()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // videoDataの場合
    var videoDataOutput = AVCaptureVideoDataOutput()
    
    var photoDefaultOutput = AVCapturePhotoOutput()
    
    /**
     SampleBufferからUIImageの作成
     */
    func imageFromSampleBuffer(sampleBuffer :CMSampleBuffer) -> UIImage {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // イメージバッファのロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像情報を取得
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        
        // ビットマップコンテキスト作成
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext = CGContext(data: base, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerCompornent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)! as CGContext
        
        // イメージバッファのアンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像作成
        let imageRef = newContext.makeImage()!
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.right)
        
        return image
    }
    
}
