//
//  RenderViewController.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import RxSwift
import RxCocoa
import Vision
import SpriteKit

final class RenderViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var drawView: DrawView!
    
    // MARK: - InternalProperty
    
    // MARK: - PrivteProperty
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var handler = VNSequenceRequestHandler()
    private var canExecute = false
    private var timer: Timer?
    private let timeInterval: TimeInterval = 0.02
    
    private var captureSession: AVCaptureSession?

    
    // MARK: - VNCoreMLModel
    private var carModel = try! VNCoreMLModel(for: Car().model)
    private var humanModel = try! VNCoreMLModel(for: Human().model)
    
    // MARK: Presenter
    private let presenter = RenderPresenter()
    
    // MARK: Rx
    private let disposeBag = DisposeBag()
    
    // MARK: SpriteKit
    private var skView: SKView?
    private var image: UIImage?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initialize()
    }
    
    // MARK: - PrivateMethods
    // MARK: Init
    
    private  func initialize() {
        
        self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval,
                                          target: self,
                                          selector: #selector(self.executeTimer),
                                          userInfo: nil,
                                          repeats: true)
        
        // AVCaptureSession
        self.captureSession = AVCaptureSession()
        
        guard let captureSession = self.captureSession else { return }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        guard let captureDevice: AVCaptureDevice = DeviceUtil.getDevice(false) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(input) else { return }
        captureSession.addInput(input)
        
        let output: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        guard captureSession.canAddOutput(output) else { return }
        captureSession.addOutput(output)
        let videoConnection = output.connection(with: AVMediaType.video)
        videoConnection!.videoOrientation = .portrait
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // FragmengShaderを利用するのでAVCaptureVideoPreviewLayerは利用しない。
        if CateogoryRepository.shared.type == .Pixels {
            
            guard let scene = SKScene(fileNamed: "ShaderScene") else { return }
            
            if self.skView == nil {
                self.skView = SKView(frame: UIScreen.main.bounds)
                guard let skView = self.skView else { return }
                
                scene.scaleMode = .aspectFit
                scene.backgroundColor = .clear
                skView.presentScene(scene)
                skView.allowsTransparency = true
                self.view.addSubview(skView)
            }
            
        } else {
            if let previewLayer = previewLayer {
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer.frame = drawView.frame
                view.layer.insertSublayer(previewLayer, at: 0)
            }
        }
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.captureSession != nil {
            self.captureSession?.stopRunning()
            self.captureSession = nil
        }
    }
    
    // MARK: Rx
    
    private func bind() {
        
        self.presenter.requestSignal.emit(onNext: { [weak self] request in
            guard let `self` = self else { return }
            
            if let results = request.results {
                self.drawView.setShaderData(image: self.image, skView: self.skView)
                
                self.drawView.objects = results as? [VNRecognizedObjectObservation]
                self.drawView.setNeedsDisplay()
            }
        }).disposed(by: self.disposeBag)
    }
    
    // MARK: CoreML
    
    private func predict(_ sampleBuffer: CMSampleBuffer, completion: ((_ ciImage: CIImage?, _ image: UIImage?) -> Void)?) {
        
        DispatchQueue.main.async {
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            
            self.drawView.setImageSize(CGSize(
                width: CGFloat(CVPixelBufferGetWidth(imageBuffer!)),
                height: CGFloat(CVPixelBufferGetHeight(imageBuffer!))
            ))
            
            self.drawView.setShaderData(image: nil, skView: nil)
        }
        
        let pixelBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        var image = UIImage(ciImage: ciImage)

        DispatchQueue.main.async {
            let size = self.drawView.frame.size
            
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        self.image = image
        
        if CateogoryRepository.shared.type == .Pixels {
            DispatchQueue.main.async {
                let ss = self.skView?.scene as! ShaderScene
                ss.setShader(image: image, rect: CGRect.zero)
            }
        }
        
        completion?(ciImage, image)
    }
    
    @objc private func executeTimer() {
        self.canExecute = true
    }
}

extension RenderViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        self.predict(sampleBuffer, completion: { (ciImage, image) -> Void in
            
            guard let ciImage = ciImage else { return }
            guard let image = image else { return }
            
            if self.canExecute {
                var selectedModel: VNCoreMLModel?
                if CateogoryRepository.shared.type == .Car {
                    selectedModel = self.carModel
                } else {
                    selectedModel = self.humanModel
                }
                
                if let selectedModel = selectedModel {
                    let request = self.presenter.requestML(model: selectedModel)
                    
                    // 画像の向きの取得
                    let orientation = CGImagePropertyOrientation(
                        rawValue: UInt32(image.imageOrientation.rawValue)
                        )!
                    
                    // ハンドラの生成と実行
                    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                    guard (try? handler.perform([request])) != nil else { return }
                    self.canExecute = false
                }
            }
        })
    }
}
