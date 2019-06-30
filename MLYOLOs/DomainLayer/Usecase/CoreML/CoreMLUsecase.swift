//
//  CoreMLUsecase.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import CoreML
import Vision

final class CoreMLUsecase {
    
    private let repository = CoreMLRepository()
    
    init() {
        
    }
    
    func requestML(model: VNCoreMLModel, completion: @escaping (VNRequest) -> Void) -> VNRequest {
        let request = self.repository.requestML(model: model, completion: completion)
        return request
    }
    
}
