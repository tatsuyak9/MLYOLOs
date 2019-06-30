//
//  CategoryUsecase.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

final class CategoryUsecase {
    
    private let repository = CateogoryRepository.shared
    
    init() {
        
    }
    
    func selectType(type: CateogoryType) {
        self.repository.selectCateogoryType(type: type)
    }
    
    func getType() -> CateogoryType {
        return self.repository.type
    }
}
