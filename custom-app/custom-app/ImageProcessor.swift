//
//  ImageProcessor.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/14.
//

import Foundation
import UIKit
import opencv2

class ImageProcessor {
    /**
     二値化
     @param image 画像
     @return 二値化後の画像
     */
    static func binarize(image: UIImage) -> UIImage {
        let mat = Mat(uiImage: image)
        let dstMat = Mat()
        Imgproc.cvtColor(src: mat, dst: dstMat, code: .COLOR_BGR2GRAY)
        let binarizedMat = Mat()
        Imgproc.threshold(src: dstMat, dst: binarizedMat, thresh: 100, maxval: 255, type: .THRESH_BINARY_INV)
        return binarizedMat.toUIImage()
    }
    
    /**
     画面回転
     @param image 画像
     @returns 回転後の画像
     */
    static func rotate(image: UIImage) -> UIImage {
        let mat = Mat(uiImage: image)
        let dstMat = Mat()
        Core.rotate(src: mat, dst: dstMat, rotateCode: .ROTATE_90_CLOCKWISE)
        return dstMat.toUIImage()
    }
    
    /**
     エッジ検出
     @param 画像
     @returns エッジ検出後の画像
     */
    static func canny(image: UIImage) -> UIImage {
        let mat = Mat(uiImage: image)
        let dstMat = Mat()
    
        Imgproc.Canny(image: mat, edges: dstMat, threshold1: 30, threshold2: 100)
        
        print("EDGES \(dstMat)")
        return dstMat.toUIImage()
    }
    
    /**
     輪郭検出
     @param image 画像
     @param source もとの画像
     */
    static func findContours(image: UIImage, source: UIImage) -> UIImage {
        let mat = Mat(uiImage: image)
        let dstMat = Mat()
        var contours: [[Point2i]] = [[]]

        Imgproc.findContours(image: mat, contours: &contours, hierarchy: dstMat, mode: .RETR_TREE, method: .CHAIN_APPROX_TC89_L1)
        print(contours.count)
        let originMat = Mat(uiImage: source)
        contours.forEach({ contour in
            print(contour)
        })
    
        for i in 0...contours.count-1 {
            let matOfContour = MatOfPoint(array: contours[i]) as Mat
            let area = Imgproc.contourArea(contour: matOfContour)
            if area > 1000 {
                var approx: [Point2f] = []
                var point2fArray: [Point2f] = []
                
                contours[i].forEach({ point in
                    let point = Point2f(x: Float(point.x), y: Float(point.y))
                    point2fArray.append(point)
                })
                Imgproc.approxPolyDP(curve: point2fArray, approxCurve: &approx, epsilon: 0.01 * Imgproc.arcLength(curve: point2fArray, closed: true), closed: true)
                if approx.count == 3 {
                    Imgproc.drawContours(image: originMat, contours: contours, contourIdx: Int32(i), color: Scalar(0,244,0,255))
                    print(area)
                }
            }
        }
        return originMat.toUIImage()
    }
}
