//
//  WeadyBoardItem.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

import SwiftUI

struct WeadyBoardItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let boardId: Int
    let imageName: String
    let weather: String
}
