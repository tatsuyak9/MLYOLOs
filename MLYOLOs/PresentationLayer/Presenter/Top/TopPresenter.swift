//
//  TopPresenter.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import RxSwift
import RxCocoa

final class TopPresenter {
    
    // MARK: - InternalProperty
    
    var titlesObservable: Observable<[String]> {
        return titleRelay.asObservable()
    }

    var titles: [String] {
        return titleRelay.value
    }

    // MARK: - privateProperty
    
    private let usecase = CategoryUsecase()
    
    private var titleRelay = BehaviorRelay<[String]>(value: [])
    
    init() {
        self.titleRelay.accept(["Car", "Human", "Pixels"])
    }
    
    func selectedType(type: CateogoryType) {
        self.usecase.selectType(type: type)
    }
}
