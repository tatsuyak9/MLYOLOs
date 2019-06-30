//
//  ObjectDetectUtil.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import UIKit
import Vision

final class ObjectDetectUtil: NSObject {

    static func calculateIoU(_ alpha: CGRect, _ beta: CGRect) -> Float {
        let intersection = alpha.intersection(beta)
        let union = alpha.union(beta)
        return Float((intersection.width * intersection.height) /
            (union.width * union.height))
    }
    
    static func nonMmaximumSuppression(_ objects: [VNRecognizedObjectObservation])
        -> [VNRecognizedObjectObservation] {
            let nmsThreshold: Float = 0 // IoU値の閾値
            var results: [VNRecognizedObjectObservation] = [] // 結果配列
            var keep = [Bool](repeating: true, count: objects.count) // 保持フラグ
            
            // 信頼度順（高い順）でソート
            let orderedObjects = objects.sorted { $0.confidence > $1.confidence }
            
            for i in 0 ..< orderedObjects.count {
                if keep[i] {
                    // 信頼度順に結果配列に追加
                    results.append(orderedObjects[i])
                    
                    // 信頼度順にIoU値の閾値以上の領域を抑制
                    let bbox1 = orderedObjects[i].boundingBox
                    for j in (i + 1) ..< orderedObjects.count {
                        if keep[j] {
                            let bbox2 = orderedObjects[j].boundingBox
                            if ObjectDetectUtil.calculateIoU(bbox1, bbox2) > nmsThreshold {
                                keep[j] = false
                            }
                        }
                    }
                }
            }
            return results
    }
}
