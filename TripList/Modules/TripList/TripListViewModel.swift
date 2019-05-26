//
//  TripListViewModel.swift
//  TripList
//
//  Created by Roman Shveda on 5/23/19.
//  Copyright © 2019 Roman Shveda. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore
import Firebase

class TripListViewModel {
    
    enum Queries: String {
        case active, upcoming, past
    }
    
    var trips = Variable<[Trip]>([])
    var selectedIndex = Variable<Int>(0)
    var disposeBag: DisposeBag = DisposeBag()
    
    private let collection = Firestore.firestore().collection("Trips")
    
    private var timeStamp: Double {
        return Date().timeIntervalSinceReferenceDate as Double
    }
    
    private var queries: [String: Query] {
        return [
            "active": collection.whereField("endDate", isGreaterThan: timeStamp),
            "upcoming": collection.whereField("startDate", isGreaterThan: timeStamp),
            "past": collection.whereField("endDate", isLessThan: timeStamp),
        ]
    }
    
    init() {
        initialBinding()
    }
    
    private func initialBinding() {
        selectedIndex.asObservable().subscribe(onNext: { index in
            switch index {
            case 1:
                self.getTripList(for: .upcoming, completion: { trips in
                    self.trips.value = trips
                })
            case 2:
                self.getTripList(for: .past, completion: { trips in
                    self.trips.value = trips
                })
            default:
                self.getTripList(for: .active, completion: { trips in
                    self.trips.value = trips
                })
            }
        }).disposed(by: disposeBag)
        
    }
    
    func getTripList(for query: Queries, completion: @escaping ([Trip]) -> Void) {
        guard let query = queries[query.rawValue] else { return }
        FireStoreService.shared.getTrips(with: query) { trips in
            completion(trips)
        }
    }
    
}
