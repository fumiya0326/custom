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
        // threshは低くするほど
        Imgproc.threshold(src: dstMat, dst: binarizedMat, thresh: 180, maxval: 255, type: .THRESH_BINARY)
        return binarizedMat.toUIImage()
    }
    
    /**
     画面回転
     @param image 画像
     @returns 回転後の画像
     */
    static func rotateClockWise(image: UIImage) -> UIImage {
        let mat = Mat(uiImage: image)
        let dstMat = Mat()
        Core.rotate(src: mat, dst: dstMat, rotateCode: .ROTATE_90_CLOCKWISE)
        return dstMat.toUIImage()
    }
    
    static func rotateCounterClockWise(image: UIImage) -> UIImage {
        let src = Mat(uiImage: image)
        let dstMat = Mat()
        Core.rotate(src: src, dst: dstMat, rotateCode: .ROTATE_180)
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
     指定の位置で切り取り
     @param image 画像
     @param source もとの画像
     */
    static func cutByContours(from image: UIImage,  origin: UIImage,by contours: [[Point2i]], maxAreaIndex: Int) -> UIImage {
        let mat = Mat(uiImage: image)
        
        let originMat = Mat(uiImage: origin)
        do {
            
        
        // 輪郭検出
        let findContoursResult = try findContours(from: mat)
        let contours = findContoursResult.contours
        let maxAreaIndex = findContoursResult.maxRectAreaIndex
        
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
        } catch {
            return image
        }
    }
    
    struct FindContoursResult {
        var contours: [[Point2i]]
        var maxRectAreaIndex: Int
        var perspectiveMat: Mat
        var width: Int32
        var height: Int32
    }
    
    /**
     輪郭検出
     @param sourceMat 輪郭を検出する画像を表す行列
     @return 輪郭格納する配列、一番広い輪郭のインデックス
     */
    static func findContours(from sourceMat: Mat) throws -> FindContoursResult {
        let dstMat = Mat()
        // 検出された輪郭を格納する配列
        var contours: [[Point2i]] = [[]]
        
        // 輪郭検出
        Imgproc.findContours(image: sourceMat, contours: &contours, hierarchy: dstMat, mode: .RETR_TREE, method: .CHAIN_APPROX_TC89_L1)

        var maxArea: Double = 0
        var maxRectArea: Double = 0
        var maxRectAreaIndex: Int = 0
        var maxApprox: [Point2f] = []
        guard contours.count > 1 else {
            throw NSError()
        }

        for i in 1...contours.count - 1 {
            let matOfContour = MatOfPoint(array: contours[i]) as Mat
            let tmpArea = Imgproc.contourArea(contour: matOfContour)
            if(tmpArea > maxArea) {
                maxArea = tmpArea
            }else{
                // 面積が更新されない場合は何もしない
                continue
            }
            
            var approx: [Point2f] =  []
            let point2fContour: [Point2f] = convertToPoint2fArray(from: contours[i])
            
            // 矩形検出処理
            Imgproc.approxPolyDP(curve: convertToPoint2fArray(from: contours[i]), approxCurve: &approx, epsilon: 0.05 * Imgproc.arcLength(curve: point2fContour, closed: true), closed: true)
            if approx.count == 4 {
                Imgproc.drawContours(image: sourceMat, contours: contours, contourIdx: Int32(i), color: Scalar(0,255,255,255))
                let tmpArea = Imgproc.contourArea(contour: matOfContour)
                if(tmpArea > maxRectArea) {
                    maxApprox = approx
                    maxRectAreaIndex = i
                    maxRectArea = tmpArea
                }
            }
        }
        guard maxApprox.count == 4 else {
            throw NSError()
        }
        
        // 座標の位置をソートする
        let sorted = sortRectPoint(from: maxApprox)
        let height = sorted[1].y - sorted[0].y
        let width = sorted[2].x - sorted[0].x
        // 補正後のポイント
        let points = [Point2f(x: 0, y: 0), Point2f(x: 0, y: height), Point2f(x: width, y: 0), Point2f(x:width,y:height)]
        
        // 視点の行列
        let perspectiveMat = Imgproc.getPerspectiveTransform(src: MatOfPoint2f(array: sorted) as Mat, dst: MatOfPoint2f(array: points) as Mat)
        
        // 輪郭格納の配列、一番広い輪郭の位置, 視点の行列
        return FindContoursResult(
            contours: contours,
            maxRectAreaIndex: maxRectAreaIndex,
            perspectiveMat: perspectiveMat,
            width: Int32(width),
            height: Int32(height)
        )
    }
    
    /**
     輪郭を描画
     @param image 画像
     */
    static func drawContours(image: UIImage) -> UIImage{
        let originMat = Mat(uiImage: image)
        let binarizedMat = Mat(uiImage: binarize(image: image))
        do {
            let result = try findContours(from: binarizedMat)
            let contours = result.contours
            let index = result.maxRectAreaIndex
            guard index != -1 else {
                return image
            }
            // 輪郭に線を引く
            Imgproc.drawContours(image: originMat, contours: contours, contourIdx: Int32(index), color: Scalar(255,0,0,255))
            return originMat.toUIImage()
        } catch {
            return originMat.toUIImage()
        }
    }
    
    /**
     画像をシャープにする
     @param image 画像
     @return シャープにした画像
     */
    static func sharp(image: UIImage) -> UIImage {
        let mat = Mat(uiImage: image)
        let dstMat = Mat()
        Imgproc.GaussianBlur(src: mat, dst: dstMat, ksize: Size2i(width: 0, height: 0), sigmaX: 3)
        let alpha = 1.6
        let outMat = Mat()
        Core.addWeighted(src1: mat, alpha: alpha, src2: dstMat, beta: 1-alpha, gamma: 0, dst: outMat)
        return outMat.toUIImage()
    }
    
    /**
     透視変換
     @param 画像
     @param 視点行列
     */
    static func transformPerspective(from image: UIImage, with perspeciveMat: Mat, width: Int32, height: Int32) -> UIImage {
        let sourceMat = Mat(uiImage: image)
        let dstMat = Mat()
        print("transform")
        print(perspeciveMat)
        Imgproc.warpPerspective(src: sourceMat, dst: dstMat, M: perspeciveMat, dsize: Size2i(width: width, height: height))
        return dstMat.toUIImage()
    }

    /**
     四角のポイントをソート
     @param from point2f配列
     */
    private static func sortRectPoint(from pointArray: [Point2f]) -> [Point2f]{
        // TODO: より適切な方法でソートする
        let temp = pointArray.sorted(by: { a, b in
            return a.x < b.x
        })
        var sum: (Float,Float) = (0,0)
        pointArray.forEach({ point in
            sum.0 += point.x
            sum.1 += point.y
        })
        let gravityX = sum.0 / 4
        let gravityY = sum.1 / 4
        print(gravityX)
        print(gravityY)
        print(temp)
        
        var sorted: [Point2f] = []
        
        // ひし形の場合は当てはまらない
        if(temp[0].y < temp[1].y){
            sorted.append(temp[0])
            sorted.append(temp[1])
        }else{
            sorted.append(temp[1])
            sorted.append(temp[0])
        }
        
        if(temp[2].y < temp[3].y){
            sorted.append(temp[2])
            sorted.append(temp[3])
        }else{
            sorted.append(temp[3])
            sorted.append(temp[2])
        }
        // 左上、左下、右上、右下
        return sorted
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
     Point2f配列をPoint２i配列へ変換
     @param from Point2f配列
     @return Point２i配列
     */
    private static func convertToPoint2iArray(from piont2fArray: [Point2f]) -> [Point2i] {
        var point2iArray: [Point2i] = []
        
        // point2fへ変換
        piont2fArray.forEach({ point2f in
            let point = Point2i(x: Int32(point2f.x), y: Int32(point2f.y))
            point2iArray.append(point)
        })
        
        return point2iArray
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
