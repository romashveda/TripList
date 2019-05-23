//
//  FireStoreService.swift
//  TripList
//
//  Created by Roman Shveda on 5/23/19.
//  Copyright © 2019 Roman Shveda. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FireStoreService {
    
    let shared = FireStoreService()
    private init() {}
    
    func configure() {
        FirebaseApp.configure()
    }
    
    private var collection: CollectionReference {
        return Firestore.firestore().collection("Trip")
    }
    
    private var timeStamp: Double {
        return Date().timeIntervalSinceReferenceDate as Double
    }
    
    let queries: [String: Query] = [
        "active" : Firestore.firestore().collection("Trip").whereField("startDate", isLessThan: timeStamp).whereField("endDate", isGreaterThan: timeStamp)
    ]
    
    func add<T: Codable>(for encodedObject: T) {
        let data = encodedObject.toJson()
        guard !data.isEmpty else {
            print("Failed to encode object")
            return
        }
        collection.addDocument(data: data)
    }
    
    func getActiveTrips(completion: @escaping ([Trip]) -> Void) {
        let timeStamp = Date().timeIntervalSinceReferenceDate as Double
        collection.whereField("startDate", isLessThan: timeStamp).whereField("endDate", isGreaterThan: timeStamp).addSnapshotListener { (snapshot, _) in
            guard let snapshot = snapshot else { return }
            var trips: [Trip] = []
            snapshot.documents.forEach({ document in
                guard let trip = document.decode(as: Trip.self) else { return }
                trips.append(trip)
            })
            completion(trips)
        }
    }
    
    func getTrips(with query: Query, completion: @escaping ([Trip]) -> Void) {
        query.addSnapshotListener { (snapshot, _) in
            guard let snapshot = snapshot else { return }
            var trips: [Trip] = []
            snapshot.documents.forEach({ document in
                guard let trip = document.decode(as: Trip.self) else { return }
                trips.append(trip)
            })
            completion(trips)
        }
    }
}

extension Encodable {
    func toJson() -> [String: Any] {
        guard let objectData = try? JSONEncoder().encode(self),
            let jsonObject = try? JSONSerialization.jsonObject(with: objectData, options: []),
            let json = jsonObject as? [String: Any] else { return [:] }
        return json
    }
}

extension DocumentSnapshot {
    func decode<T: Decodable>(as objectType: T.Type, includingId: Bool = true) -> T? {
        guard let documentJson = data(),
            let documentData = try? JSONSerialization.data(withJSONObject: documentJson, options: []),
            let decodedObject = try? JSONDecoder().decode(objectType, from: documentData) else { return nil }
        return decodedObject
    }
}
