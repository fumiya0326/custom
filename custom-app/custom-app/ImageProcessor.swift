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
        Imgproc.threshold(src: dstMat, dst: binarizedMat, thresh: 150, maxval: 255, type: .THRESH_BINARY)
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
        
        // Canny変換でエッジを検出する
        Imgproc.Canny(image: mat, edges: dstMat, threshold1: 30, threshold2: 100)
        
        return dstMat.toUIImage()
    }
    
    /**
     輪郭検出
     @param image 画像
     @param source もとの画像
     */
    static func cutByContours(from image: UIImage, source: UIImage) -> UIImage {
        let mat = Mat(uiImage: image)
        
        let originMat = Mat(uiImage: source)
    
        let (contours, maxAreaIndex) = findContours(from: mat)
        
        var approx: [Point2f] = []
        let point2fArray = convertToPoint2fArray(from: contours[maxAreaIndex])
        
        // 近似矩形を検出
        Imgproc.approxPolyDP(curve: point2fArray, approxCurve: &approx, epsilon: 0.01 * Imgproc.arcLength(curve: point2fArray, closed: true), closed: true)
        
        // 輪郭に線を引く
        Imgproc.drawContours(image: originMat, contours: contours, contourIdx: Int32(maxAreaIndex), color: Scalar(0,244,0,255))
        
        let rect2 = Imgproc.boundingRect(array: MatOfPoint(array: contours[maxAreaIndex]) as Mat)
        let minXPoint = Int(rect2.x)
        let maxXPoint = Int(rect2.x + rect2.width)
        let minYPoint = Int(rect2.y)
        let maxYPoint = Int(rect2.y + rect2.height)
        
    
        // 切り抜き位置
        let rect = CGRect(x: minXPoint, y: minYPoint, width: maxXPoint-minXPoint, height: maxYPoint-minYPoint)
        
        // 切り抜き後の画像を返す
        return UIImage(cgImage: originMat.toCGImage().cropping(to: rect)!)
    }
    
    /**
     輪郭検出
     @param sourceMat 輪郭を検出する画像を表す行列
     @return 輪郭格納する配列、一番広い輪郭のインデックス
     */
    static func findContours(from sourceMat: Mat ) -> ([[Point2i]], Int) {
        let dstMat = Mat()
        // 検出された輪郭を格納する配列
        var contours: [[Point2i]] = [[]]
        
        // 輪郭検出
        Imgproc.findContours(image: sourceMat, contours: &contours, hierarchy: dstMat, mode: .RETR_TREE, method: .CHAIN_APPROX_TC89_L1)

        var maxArea: Double = 0
        var maxAreaIndex = 0
        var maxRectArea: Double = 0
        var maxRectAreaIndex: Int = 0
        for i in 1...contours.count - 1 {
            let matOfContour = MatOfPoint(array: contours[i]) as Mat
            let tmpArea = Imgproc.contourArea(contour: matOfContour)
            if(tmpArea > maxArea) {
                maxArea = tmpArea
                maxAreaIndex = i
            }
            var approx: [Point2f] =  []
            let point2fContour: [Point2f] = convertToPoint2fArray(from: contours[i])
            Imgproc.approxPolyDP(curve: convertToPoint2fArray(from: contours[i]), approxCurve: &approx, epsilon: 0.01 * Imgproc.arcLength(curve: point2fContour, closed: true), closed: true)
            if approx.count == 4 {
                print(contours[i])
                Imgproc.drawContours(image: sourceMat, contours: contours, contourIdx: Int32(i), color: Scalar(0,255,255,255))
                let matOfContourRect = MatOfPoint(array: contours[i]) as Mat
                let tmpArea = Imgproc.contourArea(contour: matOfContour)
                if(tmpArea > maxArea) {
                    maxRectAreaIndex = i
                    maxRectArea = tmpArea
                }
            }
        }
        
        print(contours[maxRectAreaIndex])
        
        // 輪郭格納の配列、一番広い輪郭の位置
        return (contours, maxRectAreaIndex)
    }
    
    /**
     Point2i配列をPoint2f配列へ変換
     @param from Point2i配列
     @return 要素をPoint2fにした配列
     */
    private static func convertToPoint2fArray(from point2iArray: [Point2i]) -> [Point2f] {
        var point2fArray: [Point2f] = []
        
        // point2fへ変換
        point2iArray.forEach({ point2i in
            let point = Point2f(x: Float(point2i.x), y: Float(point2i.y))
            point2fArray.append(point)
        })
        
        return point2fArray
    }
    
    
    /**
     カラーを調整
     @param image 画像
     @param alpha 彩度
     @beta 明度
     @returns 調整された画像
     */
    static func adjustColor(image: UIImage, alpha: Double, beta: Double) -> UIImage {
        let mat = Mat(uiImage: image)
        let dstMat = Mat()
        Core.convertScaleAbs(src: mat, dst: dstMat, alpha: alpha, beta: beta)
        return dstMat.toUIImage()
    }
}
