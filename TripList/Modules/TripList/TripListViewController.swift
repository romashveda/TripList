//
//  ViewController.swift
//  TripList
//
//  Created by Roman Shveda on 5/23/19.
//  Copyright © 2019 Roman Shveda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TripListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterControl: UISegmentedControl!
    @IBOutlet weak var addTripButton: UIButton!
    
    var viewModel: TripListViewModel = TripListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        filterControl.rx.selectedSegmentIndex.asObservable().subscribe(onNext: { index in
            self.viewModel.selectedIndex.value = index
        }).disposed(by: viewModel.disposeBag)
        viewModel.trips.asObservable().bind(to: tableView.rx.items(cellIdentifier: "cell")){ _, element, cell in
            guard let startDate = element.startDate, let endDate = element.endDate else { return }
            cell.textLabel?.text = element.name
            cell.detailTextLabel?.text = "\(startDate.getFormattedDate())-\(endDate.getFormattedDate())"
            }.disposed(by: viewModel.disposeBag)
        addTripButton.rx.tap.bind {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTripViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: viewModel.disposeBag)
    }


}

extension Date {
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
}
