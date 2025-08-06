// PlaceViewModel.swift
import Foundation
import Observation

@Observable
final class PlaceViewModel {
    private let maxSelection = 3

    var searchQuery: String = ""
    var searchResults: [Place] = []
    var selectedPlaces: [Place] = []

    func searchPlaces() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }

        // TODO: - API 연결 (현재 더미 데이터)
        searchResults = (1...10).map {
            Place(placeName: "\(searchQuery) 장소 \($0)", placeAddress: "서울시 가상구 가상동 \($0)번지")
        }
    }

    func addPlace(_ place: Place) {
        guard !selectedPlaces.contains(place), selectedPlaces.count < maxSelection else { return }
        selectedPlaces.append(place)
    }

    func removePlace(_ place: Place) {
        selectedPlaces.removeAll { $0 == place }
    }
}
