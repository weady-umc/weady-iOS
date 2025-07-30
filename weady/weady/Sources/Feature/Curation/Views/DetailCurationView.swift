//
//  DetailCurationView.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//

import SwiftUI

struct DetailCurationView: View {
    let cardID: String

    var body: some View {
        VStack {
            Text("Detail View for Card ID: \(cardID)")
                .font(.title)
                .padding()
            // TODO: - Moya를 통해 해당 cardID의 상세 데이터 요청 및 렌더링
        }
        .navigationTitle("상세 큐레이션")
        .navigationBarTitleDisplayMode(.inline)
    }
}

