//
//  RemoteThumb.swift
//  weady
//
//  Created by Yoonseo on 8/16/25.
//
import SwiftUI

struct RemoteThumb: View {
    let urlString: String?
    var placeholderAsset: String = "clothesIcon"

    var body: some View {
        if let s = urlString,
           let url = URL(string: s), !s.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .failure(_): Image(placeholderAsset).resizable().scaledToFit()
                case .empty: Color.gray.opacity(0.1)
                }
            }
        } else {
            Image(placeholderAsset).resizable().scaledToFit()
        }
    }
}
extension FashionSummary {
    static let dummy = FashionSummary(
        locationId: -1,
        recommendation: "선선해요. 얇은 아우터와 긴바지 추천!",
        imageUrl: ""
    )
}

