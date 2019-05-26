//
//  Trip.swift
//  TripList
//
//  Created by Roman Shveda on 5/23/19.
//  Copyright © 2019 Roman Shveda. All rights reserved.
//

import Foundation

protocol Identifiable {
    var id: String? { get set }
}

struct Trip: Codable, Identifiable {
    var id: String?
    var name: String?
    var startDate: Date?
    var endDate: Date?
}
