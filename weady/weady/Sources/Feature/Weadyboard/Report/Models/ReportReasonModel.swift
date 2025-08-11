//
//  ReportReasonModel.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import Foundation

struct ReportReason: Identifiable, Hashable {
    let id: UUID
    let listTitle: String
    let detailTitle: String
    let details: [String]
    let isCustomInput: Bool
    
    init(listTitle: String, detailTitle: String, details: [String], isCustomInput: Bool) {
        self.id = UUID()
        self.listTitle = listTitle
        self.detailTitle = detailTitle
        self.details = details
        self.isCustomInput = isCustomInput
    }
}

enum ReportTag {
    
    static func reportTypeEnglish(for id: Int) -> String {
        switch id {
        case 0: return "Spam"
        case 1: return "Harmful_Content"
        case 2: return "Disinformation"
        case 3: return "Hate_Activity"
        case 4: return "Offensive_Content"
        case 5: return "Illegal_Photo"
        case 6: return "Other"
        default: return "Other"
        }
    }
    
    static func reportTypeKorean(for id: Int) -> String {
        switch id {
        case 0: return "스팸"
        case 1: return "유해 콘텐츠"
        case 2: return "잘못된 정보"
        case 3: return "혐오 활동"
        case 4: return "모욕적인 내용"
        case 5: return "불법 촬영물"
        case 6: return "기타"
        default: return ""
        }
    }
}
