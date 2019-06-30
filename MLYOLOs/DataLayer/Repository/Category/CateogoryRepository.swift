//
//  CateogoryRepository.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import RxSwift
import RxCocoa

enum CateogoryType: String {
    case None
    case Car
    case Human
    case Pixels
}

final class CateogoryRepository {
    
    // MARK: - InternalProperty
    static let shared = CateogoryRepository()

    var type: CateogoryType {
        return selectedType
    }
    
    // MARK: - PrivteProperty

    var selectedType: CateogoryType = .None

    private init() {
        
    }
    
    func selectCateogoryType(type: CateogoryType) {
        self.selectedType = type
    }
}
