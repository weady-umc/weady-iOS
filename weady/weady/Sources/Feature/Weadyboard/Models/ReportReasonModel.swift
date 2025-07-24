//
//  ReportReasonModel.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import Foundation

struct ReportReason: Identifiable, Hashable {
    let id = UUID()
    let listTitle: String
    let detailTitle: String
    let details: [String]
    let isCustomInput: Bool
}
