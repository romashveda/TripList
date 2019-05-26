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
    
    static let shared = FireStoreService()
    private init() { }
    
    func add<T: Codable>(for encodedObject: T) {
        let data = encodedObject.toJson(excluding: [])
        guard !data.isEmpty else {
            print("Failed to encode object")
            return
        }
        Firestore.firestore().collection("Trips").addDocument(data: data)
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
    
    func delete<T: Identifiable>(_ identifiableObject: T) {
        guard let id = identifiableObject.id else { return }
        Firestore.firestore().collection("Trips").document(id).delete()
    }
}

extension Encodable {
    func toJson(excluding keys: [String] = []) -> [String: Any] {
        guard let objectData = try? JSONEncoder().encode(self),
            let jsonObject = try? JSONSerialization.jsonObject(with: objectData, options: []),
            var json = jsonObject as? [String: Any] else { return [:] }
        keys.forEach { key in
            json[key] = nil
        }
        return json
    }
}

extension DocumentSnapshot {
    func decode<T: Decodable>(as objectType: T.Type, includingId: Bool = true) -> T? {
        var documentJson = data() ?? [:]
        if includingId { documentJson["id"] = documentID }
        guard let documentData = try? JSONSerialization.data(withJSONObject: documentJson, options: []),
            let decodedObject = try? JSONDecoder().decode(objectType, from: documentData) else { return nil }
        return decodedObject
    }
}
