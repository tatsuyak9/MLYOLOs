//
//  TopViewController.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TopViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - InternalProperty
    
    // MARK: - PrivteProperty
    
    // MARK: Presenter
    private let presenter = TopPresenter()
    
    // MARK: Rx
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialize()
        self.bind()
    }
    
    // MARK: - PrivateMethods
    // MARK: Init

    private  func initialize() {
        
    }

    // MARK: Rx

    private func bind() {
        
        self.presenter.titlesObservable.bind(to: self.tableView.rx.items(cellIdentifier: "CellIdentifier")){ _, title, cell -> Void in
            cell.textLabel?.text = title
            }.disposed(by: self.disposeBag)
        
        
        self.tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            let title = self.presenter.titles[indexPath.row]

            if let selectedType = CateogoryType(rawValue: title) {
                self.presenter.selectedType(type: selectedType)
 
                let storyboard: UIStoryboard = UIStoryboard(name: "Render", bundle: nil)
                if let renderViewController: UIViewController = storyboard.instantiateInitialViewController() {
                    self.navigationController?.pushViewController(renderViewController, animated: true)
                }
            }
            
        }).disposed(by: disposeBag)
    }
}

