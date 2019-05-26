//
//  AddTripViewModel.swift
//  TripList
//
//  Created by Roman Shveda on 5/23/19.
//  Copyright © 2019 Roman Shveda. All rights reserved.
//

import Foundation
import RxSwift

class AddTripViewModel {
    
    var name = Variable<String>("")
    var startDate = Variable<Date?>(nil)
    var endDate = Variable<Date?>(nil)
    var trip = Variable<Trip?>(nil)
    
    init() {
        initialBinding()
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private func initialBinding() {
        trip.asObservable().subscribe(onNext: { trip in
            guard let trip = trip else { return }
            FireStoreService.shared.add(for: trip)
        }).disposed(by: disposeBag)
    }
    
    func addTrip() {
        trip.value = Trip(id: nil, name: name.value, startDate: startDate.value, endDate: endDate.value)
    }
}
