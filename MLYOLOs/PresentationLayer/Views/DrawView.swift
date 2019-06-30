//
//  DrawView.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import UIKit
import Vision
import SpriteKit

// 描画ビュー
final class DrawView: UIView {
    // 定数
    let colorBlue: UIColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    let colorWhite: UIColor = UIColor.white
    
    // プロパティ
    var imageRect: CGRect = CGRect.zero
    var objects: [VNRecognizedObjectObservation]!
    
    var tmpImage: UIImage?
    var skView: SKView?
    
    // (4)検出結果の描画
    override func draw(_ rect: CGRect) {
        if objects == nil {
            return
        }
        
        // グラフィックスコンテキストの生成
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Non-maximum suppressionの適用
        objects = ObjectDetectUtil.nonMmaximumSuppression(objects)

        var shaderImage : UIImage? = nil
        if CateogoryRepository.shared.type == .Pixels {
            shaderImage = self.tmpImage
        }
        // 検出結果の描画
        for object in objects {
            // 領域の描画
            let rect = convertRect(object.boundingBox)
            
            if CateogoryRepository.shared.type == .Pixels {
                let shaderScene = skView?.scene as! ShaderScene
                if let shaderImage = shaderImage {
                    shaderScene.setShader(image: shaderImage, rect: rect)
                }
            } else {
                context.setStrokeColor(colorBlue.cgColor)
                context.setLineWidth(2)
                context.stroke(rect)
                
                // ラベルの表示
                let label = object.labels.first!.identifier
                drawText(context, text: label, rect: rect)
            }
        }
    }
    
    // 画像サイズの指定
    func setImageSize(_ imageSize: CGSize) {
        // (3)画像の表示領域の計算（AspectFit）
        let scale: CGFloat =
            (frame.width / imageSize.width < frame.height / imageSize.height) ?
                frame.width / imageSize.width :
                frame.height / imageSize.height
        let dw: CGFloat = imageSize.width * scale
        let dh: CGFloat = imageSize.height * scale
        imageRect = CGRect(
            x: (frame.width - dw) / 2,
            y: (frame.height - dh) / 2,
            width: dw, height: dh
        )
    }
    
    func setShaderData(image: UIImage?, skView: SKView?) {
        self.tmpImage = image
        self.skView = skView
    }
    
    func convertRect(_ rect: CGRect) -> CGRect {
        return CGRect(
            x: imageRect.minX + rect.minX * imageRect.width,
            y: imageRect.minY + (1 - rect.maxY) * imageRect.height,
            width: rect.width * imageRect.width,
            height: rect.height * imageRect.height
        )
    }
    
    // テキストの描画
    func drawText(_ context: CGContext, text: String, rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let attributedString = NSAttributedString(
            string: text, attributes: attributes
        )
        context.setFillColor(colorBlue.cgColor)
        let textRect = CGRect(x: rect.minX, y: rect.minY - 16, width: rect.width, height: 16)
        context.fill(textRect)
        attributedString.draw(in: textRect)
    }
}
