//
//  CoreMLRepository.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import CoreML
import Vision

final class CoreMLRepository {
    
    func requestML(model: VNCoreMLModel, completion: @escaping (VNRequest) -> Void) -> VNRequest {
        
        let request = VNCoreMLRequest(model: model) {
            request, error in
            // エラー処理
            if error != nil {
                return
            }
            completion(request)
        }
        request.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
        
        return request
    }
}
