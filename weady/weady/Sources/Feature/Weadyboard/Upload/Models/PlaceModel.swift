import Foundation

struct PlaceModel: Codable {
    var places: [Place] = []
}

struct Place: Identifiable, Hashable, Codable {
    var id = UUID()
    let placeName: String
    let placeAddress: String
}
