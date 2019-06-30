//
//  ShaderScene.swift
//  Pixels
//
//  Created by 菊池達也 on 2019/03/17.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

final class ShaderScene: SKScene {
    
    var bgNode: SKSpriteNode?
    var bgNode2: SKSpriteNode?
    
    var cropNode: SKCropNode?
    var baseMaskNode: SKShapeNode?
    
    var isFadeout: Bool = false
    
    // MARK: - LifeCycle

    override func didMove(to view: SKView) {
        
        bgNode = SKSpriteNode(imageNamed: "bg")
        bgNode?.name = "shader"
        bgNode?.size = CGSize(width: frame.width, height: frame.height)
        bgNode?.position = CGPoint(x: frame.midX, y: frame.midY)
        bgNode?.zPosition = 0
        
        bgNode2 = SKSpriteNode(imageNamed: "bg")
        bgNode2?.name = "shader2"
        bgNode2?.size = CGSize(width: frame.width, height: frame.height)
        bgNode2?.position = CGPoint(x: frame.midX, y: frame.midY)
        bgNode2?.zPosition = 1
        
        baseMaskNode = SKShapeNode(rect: CGRect(x: -frame.width / 4, y: -frame.height / 4, width: frame.width / 2, height: frame.height / 2))
        baseMaskNode?.fillColor = UIColor.white
        baseMaskNode?.position = CGPoint(x: frame.midX, y: frame.midY)
        baseMaskNode?.glowWidth = 100
        
        guard let bgNode = bgNode else { return }
        guard let bgNode2 = bgNode2 else { return }
        
        cropNode = SKCropNode()
        cropNode?.maskNode = baseMaskNode
        cropNode?.addChild(bgNode2)
        cropNode?.position = CGPoint(x: 0, y: 0)
        cropNode?.zPosition = 100
        
        if let cropNode = cropNode {
            addChild(cropNode)
        }
        
        addChild(bgNode)
    }
    
    override func update(_ currentTime: TimeInterval) {}
    
    public func setShader(image: UIImage, rect: CGRect) {
        let texture = SKTexture(image: image)
        
        bgNode?.texture = texture
        
        guard let bgNode2 = bgNode2 else { return }
        
        if rect.size.width > 0, rect.size.height > 0 {
            let shader = SKShader(fileNamed: "colors.fsh")
            bgNode2.shader = shader
            bgNode2.texture = texture
            
            // Shaderからtextureを取得し、そのNodeにShaderをかけることでShaderを合成
            let shaderdTexture = view?.texture(from: bgNode2)
            bgNode2.texture = shaderdTexture
            
            let pixShader = SKShader(fileNamed: "pixelation.fsh")
            bgNode2.shader = pixShader

            updateCropNode(rect: rect)
        } else {
            bgNode?.shader = nil
            
            if isFadeout == false {
                isFadeout = true
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ShaderScene.startCalc), userInfo: nil, repeats: false)
            }
            // frameがない場合はしない。
        }
    }
    
    private func updateCropNode(rect: CGRect) {
        let cWidth = rect.size.width * 2
        let cHeight = rect.size.height * 2
        
        let cX = -cWidth
        let cY = -cHeight / 7
        
        let cPoint = CGPoint(x: rect.origin.x + cWidth / 2, y: rect.origin.y + cHeight / 2)
        
        let convSKPoint = convertPoint(fromView: cPoint)
        
        // サイズを指定
        baseMaskNode = SKShapeNode(rect: CGRect(x: cX, y: cY, width: cWidth, height: cHeight))
        baseMaskNode?.fillColor = UIColor.white
        
        // Pixelateの移動はここでやる
        baseMaskNode?.position = convSKPoint
        
        cropNode?.maskNode = baseMaskNode
        cropNode?.position = CGPoint(x: 0, y: 0)
    }
    
    @objc func startCalc() {
        updateCropNode(rect: CGRect.zero)
        isFadeout = false
    }
}
