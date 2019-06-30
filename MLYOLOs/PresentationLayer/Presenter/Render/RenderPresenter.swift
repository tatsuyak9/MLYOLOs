//
//  RenderPresenter.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import RxSwift
import RxCocoa
import CoreML
import Vision

final class RenderPresenter {
    
    // MARK: - InternalProperty
    
    var requestSignal: Signal<VNRequest> {
        return requestRelay.asSignal()
    }
    
    // MARK: - privateProperty
    
    private let coreMLUsecase = CoreMLUsecase()
    
    private var requestRelay: PublishRelay<VNRequest>
    
    init() {
        self.requestRelay = PublishRelay<VNRequest>()
    }
    
    // MARK: - InternalMethods

    func requestML (model: VNCoreMLModel) -> VNRequest {
        
        let request = self.coreMLUsecase.requestML(model: model, completion: { [weak self] request in
            self?.requestRelay.accept(request)
        })
        return request
    }
}
