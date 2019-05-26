//
//  AddTripViewController.swift
//  TripList
//
//  Created by Roman Shveda on 5/23/19.
//  Copyright © 2019 Roman Shveda. All rights reserved.
//

import UIKit
import RxSwift

class AddTripViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    let viewModel = AddTripViewModel()
    let startDatepicker = UIDatePicker()
    let endDatepicker = UIDatePicker()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        initPicker()
    }
    
    private func bind() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        nameField.rx.text.asObservable().filter({ $0?.isEmpty != true }).subscribe(onNext: { text in
            self.viewModel.name.value = text ?? ""
        }).disposed(by: viewModel.disposeBag)
        saveButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.viewModel.addTrip()
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: viewModel.disposeBag)
        startDatepicker.rx.date.asObservable().skip(1).subscribe(onNext: { date in
            self.startDate.text = formatter.string(from: date)
            self.viewModel.startDate.value = date
        }).disposed(by: viewModel.disposeBag)
        endDatepicker.rx.date.asObservable().skip(1).subscribe(onNext: { date in
            self.endDate.text = formatter.string(from: date)
            self.viewModel.endDate.value = date
        }).disposed(by: viewModel.disposeBag)
    }
 
    private func initPicker() {
        startDatepicker.datePickerMode = .date
        endDatepicker.datePickerMode = .date
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .bordered, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([cancelButton], animated: false)
        startDate.inputAccessoryView = toolbar
        endDate.inputAccessoryView = toolbar
        startDate.inputView = startDatepicker
        endDate.inputView = endDatepicker
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }

}
